FROM --platform=linux/amd64 ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y make gcc

ADD . /repo
WORKDIR /repo
RUN chmod +x /repo/tools/packaging/cpt.py
RUN /tools/packaging/cpt.py --check-requirements && ./cpt.py --create-dev-env Debug --with-workdir=./cling-build/


RUN mkdir -p /deps
RUN ldd /repo/cling | tr -s '[:blank:]' '\n' | grep '^/' | xargs -I % sh -c 'cp % /deps;'

FROM ubuntu:20.04 as package

COPY --from=builder /deps /deps
COPY --from=builder /repo/cling /repo/cling
ENV LD_LIBRARY_PATH=/deps
