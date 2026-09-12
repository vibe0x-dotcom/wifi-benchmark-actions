FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        zip \
        clinfo \
        pocl-opencl-icd \
        hashcat && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

COPY scripts/ /workspace/scripts/

RUN chmod +x /workspace/scripts/*.sh

ENTRYPOINT ["/bin/bash"]
