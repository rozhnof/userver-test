FROM ghcr.io/userver-framework/ubuntu-userver-build-base:v1

ENV PREFIX=${PREFIX:-~/.local}
ENV CCACHE_DIR=/project/.ccache
ENV CORES_DIR=/cores

COPY . /project

RUN cd /project; git config --global --add safe.directory /project; git submodule update --init
RUN useradd runner; chown -R runner:runner /project

USER runner

WORKDIR /project

RUN make build-release

USER root
RUN make install-release

USER runner

ENTRYPOINT ["/project/start.sh"]

