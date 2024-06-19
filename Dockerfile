FROM ruby:3.1

RUN apt-get update -qq && apt-get install -y nodejs yarn sqlite3

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]