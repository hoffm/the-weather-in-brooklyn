# frozen_string_literal: true

RSpec.describe Twib do
  let(:public_bucket_name) { ENV['S3_PUBLIC_BUCKET'] }
  let(:private_bucket_name) { ENV['S3_PRIVATE_BUCKET'] }
  let(:episodes_folder) { ENV['S3_EPISODES_FOLDER'] }
  let(:feed_file_name) { ENV['S3_FEED_FILE_NAME'] }

  let(:s3_client) { Aws::S3::Client.new(stub_responses: true) }
  let(:poly_client) { Aws::Polly::Client.new(stub_responses: true) }

  let(:mixer_double) do
    object_double(
      Twib::Mixer.new(
        logo_path: Twib::LOGO_PATH,
        speech_path: Twib::SPEECH_PATH,
        music_path: Twib::MUSIC_PATH,
        target_path: Twib::MIX_PATH
      )
    )
  end

  let(:openai_client) { OpenAI::Client.new }

  let(:base_fake_s3) do
    {
      public_bucket_name => {
        episodes_folder => {}
      },
      private_bucket_name => {
        'music' => {
          'song.mp3' => 'some music'
        },
        'logo' => {
          'logo.mp3' => 'the audio logo'
        }
      }
    }
  end

  before do
    allow(Twib::Sox).to receive(:duration_in_seconds)
      .and_return(60)
    allow(Twib::Sox).to receive(:concatenate)

    stub_const('Twib::S3_CLIENT', s3_client)
    stub_s3_get_object
    stub_s3_list_objects

    stub_const('Twib::POLLY_CLIENT', poly_client)
    stub_polly_describe_voices

    stub_nws_api

    allow(Twib::Mixer).to receive(:new).and_return(mixer_double)

    allow(OpenAI::Client).to receive(:new)
      .and_return(openai_client)
  end

  context 'when no episodes have been published' do
    let(:fake_s3) { base_fake_s3 }

    it 'builds and publishes an episode' do
      expect_polly_call.exactly(5).times
      expect_openai_call
      expect(mixer_double).to receive(:mix)
      expect_episode_audio_upload do |params|
        expect(params[:key]).to match(episode_title_pattern(1))
      end

      expect_podcast_feed_upload do |rss|
        podcast_title = rss.xpath('rss/channel/title').text
        expect(podcast_title).to eq('The Weather in Brooklyn')

        episode_count = rss.xpath('rss/channel/item').count
        expect(episode_count).to eq(1)
        episode_title = rss.xpath('rss/channel/item/title').text

        expect(episode_title).to start_with('1: ')
      end

      silence_puts { described_class.run }
    end
  end

  context 'when an episode has been published already' do
    let(:fake_s3) do
      res = base_fake_s3
      res[public_bucket_name][episodes_folder] = {
        '00001_2021-12-03.mp3' => 'first episode audio'
      }

      existing_feed = File.read('spec/fixtures/feed.rss')
      res[public_bucket_name][feed_file_name] = existing_feed
      res
    end

    it 'builds and publishes another episode' do
      expect_polly_call.exactly(5).times
      expect_openai_call
      expect(mixer_double).to receive(:mix)
      expect_episode_audio_upload do |params|
        expect(params[:key]).to match(episode_title_pattern(2))
      end

      expect_podcast_feed_upload do |rss|
        podcast_title = rss.xpath('rss/channel/title').text
        expect(podcast_title).to eq('The Weather in Brooklyn')

        episode_count = rss.xpath('rss/channel/item').count
        expect(episode_count).to eq(2)

        episode_titles = rss.xpath('rss/channel/item/title').map(&:text)

        expect(episode_titles[0]).to start_with('2: ')
        expect(episode_titles[1]).to start_with('1: ')
      end

      silence_puts { described_class.run }
    end
  end

  # STUBBING

  def stub_s3_get_object
    s3_client.stub_responses(
      :get_object,
      lambda do |context|
        params = context.params
        bucket = params[:bucket]
        key = params[:key]
        bucket_contents = fake_s3[bucket]

        if bucket_contents.present?
          object = bucket_contents.dig(*key.split('/'))
          if object.present?
            { body: object }
          else
            'NoSuchKey'
          end
        else
          'NoSuchBucket'
        end
      end
    )
  end

  def stub_s3_list_objects
    s3_client.stub_responses(
      :list_objects_v2,
      lambda do |context|
        params = context.params

        bucket = params[:bucket]
        prefix = params[:prefix]

        bucket_contents = fake_s3[bucket]

        if bucket_contents.present?
          folder = bucket_contents.dig(*prefix.split('/'))

          if folder.nil?
            'NoSuchPrefix'
          else
            {
              contents: folder.keys.map do |key|
                { key: prefix + key, size: 1 }
              end
            }
          end
        else
          'NoSuchBucket'
        end
      end
    )
  end

  def stub_polly_describe_voices
    poly_client.stub_responses(
      :describe_voices,
      {
        voices: [
          { id: 'Emma', language_code: 'en-GB' },
          { id: 'Ruben', language_code: 'nl-NL' }
        ]
      }
    )
  end

  def stub_nws_api
    stub_request(:get, /api.weather.gov/)
      .to_return(
        body: File.read('spec/fixtures/nws_response.json')
      )
  end

  # EXPECTATIONS

  def expect_polly_call
    expect(poly_client).to receive(:synthesize_speech) do |params|
      expect(params[:output_format]).to eq('mp3')
      expect(params[:voice_id]).to eq('Emma')
      expect(params[:engine]).to eq('neural')
      expect(params[:text]).to match(/<speak xmlns/)
      expect(params[:response_target]).to match(/^#{ENV['SPEECH_PATH']}/)
    end
  end

  def expect_openai_call
    expect(openai_client).to receive(:completions) do |params|
      expect(params[:engine]).to eq('davinci')

      openai_params = params[:parameters]

      expect(openai_params).to include(Twib::Advice::OPENAI_PARAMS)
      expect(openai_params[:prompt]).to include(Twib::Advice::PROMPT_BASE)
    end.and_return(
      JSON.parse(
        File.read('spec/fixtures/openai_response.json')
      )
    )
  end

  def expect_episode_audio_upload
    expect(s3_client).to receive(:put_object) do |params|
      expect(params[:content_type]).to eq('audio/mpeg')
      expect(params[:bucket]).to eq(ENV['S3_PUBLIC_BUCKET'])
      yield(params)
    end
  end

  def expect_podcast_feed_upload
    expect(s3_client).to receive(:put_object) do |params|
      expect(params[:content_type]).to eq('application/xml')
      expect(params[:bucket]).to eq(ENV['S3_PUBLIC_BUCKET'])
      expect(params[:key]).to match(ENV['S3_FEED_FILE_NAME'])

      rss = Nokogiri::XML(params[:body])

      yield(rss)
    end
  end

  # UTILITY

  def silence_puts
    allow($stdout).to receive(:puts)
    yield
    allow($stdout).to receive(:puts).and_call_original
  end

  def episode_title_pattern(number)
    folder_name = ENV['S3_EPISODES_FOLDER']
    episode_number = number.to_s.rjust(5, '0')
    date_pattern = '([0-9]{4})-([0-9]{2})-([0-9]{2})'
    %r{^#{folder_name}/#{episode_number}_#{date_pattern}\.mp3$}
  end
end
