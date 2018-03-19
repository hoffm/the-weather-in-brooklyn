## Description

Generates and distributes the podcast *The Weather in Brooklyn*.

## Set up

### OS X

Expects Ruby 2.5.0.

1. Lame: `$ brew install lame`

2. SoX with Lame: `$ brew install sox --with-lame`

3. `$ bundle install`

4. Create `.env` in project root. This should contain `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `S3_BUCKET`.


## To Run

This script creates and uploads a new episode:

> `ruby lib/twib.rb`


