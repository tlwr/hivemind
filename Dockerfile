ARG ruby_version
FROM ruby:$ruby_version

RUN apk add --no-cache build-base ruby-dev sqlite sqlite-dev

RUN mkdir -p /opt/hivemind/app
WORKDIR /opt/hivemind/app

COPY $PWD/Gemfile .
COPY $PWD/Gemfile.lock .

RUN bundle install

COPY $PWD .

ENTRYPOINT ["rackup"]
