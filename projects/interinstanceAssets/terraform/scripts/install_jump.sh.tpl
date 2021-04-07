#!/bin/bash -x
#
# Run as root - installs docker, then builds and deploys barista
#installs apache (with LetsEncrypt) and configures basic reverse proxy (redirects http->https offloading SSL with LetsEncrypt, proxies to http backend app server)
#
# Variables:
#   fqdn - used for ServerName and http->https redirect
#   dest_host - typically 'localhost'
#   dest_port - port on which the backend app server listens


  df -h
  # remove old versions of these packages if they exist
  apt-get -y remove docker docker-engine docker.io containerd runc || true
  echo "Installing basic packages"
  apt-get update
  apt-get -y install \
      apt-transport-https \
      ca-certificates \
      curl \
      git \
      gnupg-agent \
      software-properties-common \
      xterm \
      python3-pip \
      sysstat \
      postgresql-client 
