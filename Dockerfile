FROM python:3.12

ENV OPENSSL_VERSION 3.3.1
ENV OPENSSL_SHA1 7376042523b6a229bc697b8099c2af369d1a84c6
ENV BUILD_DEPS autoconf file gcc git libc-dev make pkg-config zlib1g-dev
ENV OPENSSL_URL https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz

RUN set -x && \
    apt-get update && apt-get install -y \
        $BUILD_DEPS \
        bsdmainutils \
        ldnsutils \
        --no-install-recommends

RUN set -x && \
    mkdir -p /tmp/src && \
    cd /tmp/src && \
    curl -sSL $OPENSSL_URL -o openssl.tar.gz && \
    echo "${OPENSSL_SHA1} openssl.tar.gz" | sha1sum -c - && \
    tar zxvf openssl.tar.gz && \
    rm -f openssl.tar.gz && \
    cd openssl-${OPENSSL_VERSION} && \
    ./config && make && make install && \
    ldconfig

ENV LD_LIBRARY_PATH /usr/local/lib
# Set the working directory within the container
WORKDIR /usr/src/app
COPY app/requirements.txt /usr/src/app/app/requirements.txt
RUN pip install -r app/requirements.txt

COPY . /usr/src/app
COPY app/app_config/__config_secrets.py /usr/src/app/app/app_config/config_secrets.py

# Expose port 5000 for the Flask application
EXPOSE 5000

# Define the command to run the Flask application using Gunicorn
CMD ["flask", "--app", "app", "run", "--host=0.0.0.0"]

