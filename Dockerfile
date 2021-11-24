FROM ruby:3.0.2 AS base

RUN apt-get update

RUN apt-get install libsox-fmt-mp3 -y


FROM base AS dependencies

RUN gem install bundler:2.2.31

COPY Gemfile Gemfile.lock ./
RUN bundle install

FROM base

RUN adduser twib
USER twib

WORKDIR /home/twib
COPY --from=dependencies /usr/local/bundle/ /usr/local/bundle/
COPY --chown=twib . ./

CMD ["bundle", "exec", "ruby", "bin/run.rb"]
