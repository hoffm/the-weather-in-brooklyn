# frozen_string_literal: true

RSpec.describe Twib do
  let(:s3_client) { Twib::S3_CLIENT }
  let(:poly_client) { Twib::POLLY_CLIENT }
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

  let(:fake_s3) do
    {
      ENV['S3_PUBLIC_BUCKET'] => {
        ENV['S3_EPISODES_FOLDER'] => {}
      },
      ENV['S3_PRIVATE_BUCKET'] => {
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
    stub_const(
      'Twib::S3_CLIENT',
      Aws::S3::Client.new(stub_responses: true)
    )

    stub_const(
      'Twib::POLLY_CLIENT',
      Aws::Polly::Client.new(stub_responses: true)
    )

    s3_client.stub_responses(
      :get_object,
      lambda { |context|
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
      }
    )

    s3_client.stub_responses(
      :list_objects_v2,
      lambda { |context|
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
      }
    )

    poly_client.stub_responses(
      :describe_voices,
      {
        voices: [
          { id: 'Emma', language_code: 'en-GB' },
          { id: 'Ruben', language_code: 'nl-NL' }
        ]
      }
    )

    allow(Twib::Mixer).to receive(:new).and_return(mixer_double)

    allow(OpenAI::Client).to receive(:new)
      .and_return(openai_client)

    stub_request(:get, /api.weather.gov/)
      .to_return(body: File.read('spec/fixtures/nws_response.json'))
  end

  it 'Full run from zero state' do
    expect_polly_call.exactly(5).times
    expect_openai_call
    expect(mixer_double).to receive(:mix)
    expect_episode_audio_upload
    expect_podcast_feed_upload
    described_class.run
  end

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
      expect(params[:key]).to match(
        %r{^#{ENV['S3_EPISODES_FOLDER']}/00001_([0-9]{4})-([0-9]{2})-([0-9]{2})\.mp3$}
      )
    end
  end

  def expect_podcast_feed_upload
    expect(s3_client).to receive(:put_object) do |params|
      expect(params[:content_type]).to eq('application/xml')
      expect(params[:bucket]).to eq(ENV['S3_PUBLIC_BUCKET'])
      expect(params[:key]).to match(ENV['S3_FEED_FILE_NAME'])
      expect(params[:body]).to match(
        %r{<title>The Weather in Brooklyn</title>}
      )
      expect(params[:body]).to match(/<item>/)
    end
  end
end
