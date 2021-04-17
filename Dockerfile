ARG ruby_version
FROM ruby:$ruby_version

RUN apk add --no-cache build-base ruby-dev sqlite sqlite-dev nodejs npm yarn

RUN mkdir -p /opt/hivemind/app
WORKDIR /opt/hivemind/app

COPY $PWD/Gemfile .
COPY $PWD/Gemfile.lock .

RUN bundle install

COPY $PWD/package.json .

RUN npm install

COPY $PWD/css/style.css ./css/style.css
RUN npm run css:build

COPY $PWD .

ENTRYPOINT ["rackup"]
