## Description

Generates and distributes the podcast *The Weather in Brooklyn*.

## Set up

### OS X

Expects Ruby 2.5.0.

1. Lame: `$ brew install lame`

2. SoX with Lame: `$ brew install sox --with-lame`

3. `$ bundle install`

4. Create `.env` in project root. This should contain `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `S3_BUCKET`.


## Running

To create and upload a new episode:

> `$ ruby bin/run.rb`

## Development

To launch an IRB session with the app environment loaded:

> `$ bin/irb.sh`

