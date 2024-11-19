FROM mcr.microsoft.com/devcontainers/cpp:ubuntu-22.04

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && apt-get install -y llvm clang git build-essential
RUN apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/odin-lang/Odin
RUN cd Odin && git checkout dev-2024-11 && make
# RUN mkdir /opt/odin && cp -R ./base ./core ./shared ./vendor ./odin /opt/odin/
