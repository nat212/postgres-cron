FROM postgres:12
LABEL version="1.2"
LABEL maintainer="Natasha Draper <natasha@draper.net.za>"

RUN apt update \
      && apt install -y --no-install-recommends \
      git \
      make \
      build-essential \
      ca-certificates \
      postgresql-server-dev-$PG_MAJOR \
      postgresql-plpython3-$PG_MAJOR \
      python3 \
      python3-dev \
      python3-pip \
      python3-setuptools \
      python3-wheel \
      cmake \
      && pip3 install face-recognition==1.3.0

RUN git clone https://github.com/citusdata/pg_cron.git \
      && cd pg_cron && make && make install
RUN echo "shared_preload_libraries = 'pg_cron'" | tee -a /usr/lib/tmpfiles.d/postgresql.conf

RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./initdb-cron.sh /docker-entrypoint-initdb.d/002-setup-cron.sh
COPY ./create-extension.sql /docker-entrypoint-initdb.d/003-cron.sql
COPY ./create-plpython.sql /docker-entrypoint-initdb.d/004-plpython.sql
