FROM --platform=linux/amd64 ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y make gcc python3.9 python3.9-dev python3-pip

ADD . /repo
WORKDIR /repo
RUN chmod +x /repo/tools/packaging/cpt.py
RUN /repo/tools/packaging/cpt.py --check-requirements && /repo/tools/packaging/cpt.py --create-dev-env Debug --with-workdir=/repo/tools/packaging/cling-build/


RUN mkdir -p /deps
RUN ldd /repo/cling | tr -s '[:blank:]' '\n' | grep '^/' | xargs -I % sh -c 'cp % /deps;'

FROM ubuntu:20.04 as package

COPY --from=builder /deps /deps
COPY --from=builder /repo/cling /repo/cling
ENV LD_LIBRARY_PATH=/deps
