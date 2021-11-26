# syntax = docker/dockerfile:1.2

FROM ruby:3.0.2 AS base

RUN apt-get update

RUN apt-get install \
    bc \
    sox \
    libsox-fmt-mp3 \
    --yes

RUN gem install bundler:2.2.31

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . ./

CMD ["bundle", "exec", "ruby", "bin/run.rb"]
