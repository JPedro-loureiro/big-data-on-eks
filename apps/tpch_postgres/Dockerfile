FROM --platform=linux/amd64 postgres:15

RUN apt-get update && \
    apt-get install -y postgresql-15-cron && \
    echo "shared_preload_libraries = 'pg_cron'" >> /usr/share/postgresql/postgresql.conf.sample

COPY data/ /opt/tpch_data/