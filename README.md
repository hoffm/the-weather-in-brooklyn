# The Weather in Brooklyn

## Description

This code generates and distributes the podcast [*The Weather in Brooklyn*](https://michaelshoffman.com/the-weather-in-brooklyn). It is intended to be run as a daily cron job.

Running the application executes the following steps:


1. Pull the current forecast for Brooklyn from the [National Weather Service API](https://www.weather.gov/documentation/services-web-api).
2. Incorporate this forecast to build a script for the podcast episode in [SSML](https://www.w3.org/TR/speech-synthesis11/) format.
3. Use [Amazon Polly](https://aws.amazon.com/polly/) to convert the script SSML into an audio file of spoken words.
4. Download the audio logo and music for the podcast episode from a designated S3 bucket.
5. Using [SoX](http://sox.sourceforge.net/), mix the audio components—logo, music, and speech—into the final episode audio.
6. Upload the episode audio to S3.
7. Update the podcast RSS feed on S3 with the new episode data.

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

### Dependencies

If running with Docker, simply build the docker image:

```
$ ./bin/docker/build
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
$ ./bin/docker/run
```

Running on OS X:

```
$ ruby bin/run.rb
```

## Development

To launch an IRB session with the app environment loaded:

> `$ bin/irb.sh`

