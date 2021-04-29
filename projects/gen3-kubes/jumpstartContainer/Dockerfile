FROM centos:7

USER root
RUN  yum update -y
RUN  yum install -y postgresql wget curl
RUN  wget https://dl.min.io/client/mc/release/linux-amd64/mc \
          && mv mc /usr/local/bin/mc  \
          && chmod +x /usr/local/bin/mc \
          && mc --help
