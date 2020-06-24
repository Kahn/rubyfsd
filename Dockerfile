FROM ubuntu:20.04

WORKDIR /usr/src/rubyfsd

COPY . .

RUN apt-get update

RUN apt-get install -y ruby

RUN gem install geokit concurrent-ruby logging

EXPOSE 6809
EXPOSE 6820

CMD ["ruby", "./server.rb"]
