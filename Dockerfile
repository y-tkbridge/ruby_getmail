FROM ruby:2.5.1

# Initial command
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs && \
    apt-get install -y locales

# WORKDIR ENV
ENV work_dir /app

#locales setting
RUN echo "ja_JP UTF-8" > /etc/locale.gen
RUN locale-gen && locale-gen ja_JP.UTF-8
ENV LC_ALL ja_JP.UTF-8


# Rails setting
RUN mkdir ${work_dir}
WORKDIR ${work_dir}

COPY ./app ${work_dir}
