FROM ubuntu:16.04

RUN apt-get update && apt-get upgrade -y
RUN apt-get -y install curl
RUN curl -sL https://apt.vapor.sh | bash
RUN apt-get -y install swift vapor git mysql-client
WORKDIR /vapor
COPY Package.swift Package.resolved ./
COPY Tests ./Tests
COPY Sources ./Sources
RUN swift build -c release
RUN rm -rf Package.swift Package.resolved Tests Sources
COPY docker-entrypoint.sh ./
ENV ["SERVER_LISTEN", "SERVER_PORT", "SERVER_MAX_BODY_SIZE"]
ENV ["MYSQL_HOSTNAME", "MYSQL_USER", "MYSQL_PASSWORD", "MYSQL_DATABASE"]
ENV ["REDIS_HOSTNAME", "REDIS_PASSWORD"]
VOLUME ["/vapor/Public", "/vapor/Resources"]
ENTRYPOINT ["/vapor/docker-entrypoint.sh"]
