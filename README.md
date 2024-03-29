[![Test](https://github.com/hoffm/the-weather-in-brooklyn/actions/workflows/test.yml/badge.svg)](https://github.com/hoffm/the-weather-in-brooklyn/actions/workflows/test.yml) [![Lint](https://github.com/hoffm/the-weather-in-brooklyn/actions/workflows/lint.yml/badge.svg)](https://github.com/hoffm/the-weather-in-brooklyn/actions/workflows/lint.yml)

# The Weather in Brooklyn

## Description

This code generates and distributes the podcast [*The Weather in Brooklyn*](https://michaelshoffman.com/the-weather-in-brooklyn). It is intended to be run as a daily cron job. For the story behind this code, check out [Could a Podcast Make Itself?](https://hoffm.medium.com/the-weather-in-brooklyn-ddc18439caa).

Running the application executes the following steps:


1. Pull the current forecast for Brooklyn from the [National Weather Service API](https://www.weather.gov/documentation/services-web-api).
2. Generate an editorial description of today's weather using [OpenAI's completions endpoint](https://beta.openai.com/docs/guides/completion/introduction) (GPT-3 model).
3. Incorporate this forecast and description into a script for the podcast episode in [SSML](https://www.w3.org/TR/speech-synthesis11/) format.
4. Use [Amazon Polly](https://aws.amazon.com/polly/) to convert the script SSML into an audio file of spoken words.
5. Download the audio logo and music for the podcast episode from a designated S3 bucket.
6. Using [SoX](http://sox.sourceforge.net/), mix the audio components—logo, music, and speech—into the final episode audio.
7. Upload the episode audio to S3.
8. Update the podcast RSS feed on S3 with the new episode data.

## Setup

### S3

The application expects two S3 bucket to exist, one private and one publicly readable.

The private bucket should contain a `music/` folder that contains `.mp3` files with source music, as well as the audio logo at `logo/logo.mp3`.

The public bucket should contain the podcast art as `art.jpg`. The podcast RSS feed and audio files will also be hosted here once the application creates them.


### Environment Variables

The application requires several environment variables to be defined. These can defined in `./.env`.

* `AWS_ACCESS_KEY_ID`: AWS key
* `AWS_SECRET_ACCESS_KEY`: AWS secret key
* `AWS_REGION`: AWS region for the S3 buckets
* `S3_PUBLIC_BUCKET`: Name of publicly readable S3 bucket
* `S3_PRIVATE_BUCKET`: Name of private S3 bucket
* `S3_EPISODES_FOLDER`: Name of folder in the public bucket where episode audio files live.
* `S3_FEED_FILE_NAME`: Name of the file in the public bucket where the public RSS feed lives.
* `OPENAI_ACCESS_TOKEN`: OpenAI API token.

### Dependencies

If running with Docker, simply build the docker image:

```
$ ./bin/docker/build.sh
```


If running natively on OS X:

1. Install [brew](https://brew.sh/).
2. Install Lame: `$ brew install lame`
3. Install SoX with Lame: `$ brew install sox --with-lame`
4. Install Bundler: `$ gem install bundler`
5. Install Ruby gems: `$ bundle install`


## Running the Application

Running with Docker:

```
$ ./bin/docker/run.sh
```

Running on OS X:

```
$ ruby bin/run.rb
```

## Development

To launch an IRB session with the app environment loaded:

> `$ bin/irb.sh`

Tests exercise the app's behavior with all netwrok requests stubbed out. To run tests:

> `$ bundle exec rspec`

