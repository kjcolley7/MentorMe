FROM ubuntu:16.04

RUN apt-get update && apt-get upgrade -y
RUN apt-get -y install curl
RUN curl -sL https://apt.vapor.sh | bash
RUN apt-get -y install swift vapor git mysql-client
WORKDIR /vapor
COPY Package.swift ./
RUN swift package update
COPY Tests ./Tests
# WORKDIR /vapor/Sources/Run
# WORKDIR /vapor/Sources/App
# WORKDIR /vapor
# RUN touch Sources/Run/fake.swift Sources/App/fake.swift
# RUN swift build -c release
# RUN rm -rf Sources/
COPY Sources ./Sources
RUN swift build -c release
RUN rm -rf Sources Package.resolved Package.swift
COPY docker-entrypoint.sh ./
ENV ["SERVER_LISTEN", "SERVER_PORT", "SERVER_MAX_BODY_SIZE"]
ENV ["MYSQL_HOSTNAME", "MYSQL_USER", "MYSQL_PASSWORD", "MYSQL_DATABASE"]
ENV ["REDIS_HOSTNAME", "REDIS_PASSWORD"]
VOLUME ["/vapor/Public", "/vapor/Resources"]
ENTRYPOINT ["/vapor/docker-entrypoint.sh"]
