# Gen3 Installation on Azure cloud services
## Overview
Gen3 was originally deployed widely in Amazon Web Services (AWS) and has a healthy provisioning system build upon that platform.  This project has taken that approach only deployed in Microsoft Azure services, which is slightly different.  The deployment is as automated as possible, but steps need to be done in a certain order.

## Skills needed on your team to deploy and support Gen3
Use homebrew on the Mac to install these tools.
- terraform (command line)
- Azure command line
- Azure portal
- git
- kubernetes (command line and portal)
- docker
- helm
- python

## Installation
Follow the procedure in the [INSTALL.md](INSTALL.md) file, but there are a few things to keep in mind.
- You will need an Azure subscription, and this creates quite a few resources.  Expect the monthly bill to be several hundred dollars.
- This deployment builds a kubernetes cluster using Azure AKS, which is about 5 servers.
- This deployment creates HDInsight system for doing Spark processing, creates a few servers.
- This deployment creates some functionapps for doing backend processing and metadata enrichment.  This are quite small
