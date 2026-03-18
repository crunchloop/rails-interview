FROM ruby:3.1.6

RUN apt-get update && apt-get install -y \
  build-essential \
  libsqlite3-dev \
  sqlite3 \
  nodejs \
  git \
  curl

WORKDIR /workspaces/app

RUN gem install bundler

ENV BUNDLE_PATH=/usr/local/bundle

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .