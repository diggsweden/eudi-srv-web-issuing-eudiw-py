FROM cgr.dev/chainguard/wolfi-base AS builder

ARG version=3

ENV LANG=C.UTF-8
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PATH="/webissuer/venv/bin:$PATH"

WORKDIR /webissuer

RUN apk add \
    gcc \
    make \
    zlib-dev \
    libffi-dev \
    openssl-dev \
    openssl \
    glibc-dev \
    python${version}-dev \
    git \
    python-${version} \
    py${version}-pip && \
    chown -R nonroot.nonroot /webissuer/

USER nonroot
RUN python -m venv /webissuer/venv

COPY --chown=nonroot app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt 

FROM cgr.dev/chainguard/python:latest-dev
# TODO change to distroless image including openssl libcrypto later on

ENV PYTHONUNBUFFERED=1
ENV PATH="/webissuer/bin:$PATH"

# workaround for missing libcrypto
USER root
RUN apk add openssl openssl-dev 

USER nonroot
WORKDIR /webissuer

COPY --chown=nonroot --from=builder /webissuer/venv /webissuer
COPY --chown=nonroot . ./

# Expose port 5000 for the Flask application
EXPOSE 5000

CMD ["-m", "flask", "--app", "app", "run", "--host=0.0.0.0"]

ENTRYPOINT ["python"]