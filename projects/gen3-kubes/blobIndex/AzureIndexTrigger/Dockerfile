# To enable ssh & remote debugging on app service change the base image to the one below
# FROM mcr.microsoft.com/azure-functions/python:3.0-python3.8-appservice
FROM mcr.microsoft.com/azure-functions/python:3.0-python3.8

ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true

COPY requirements.txt /
RUN pip install -r /requirements.txt
RUN apt-get update && apt-get install -y openssh-server \
     && echo "root:Docker!" | chpasswd
COPY sshd_config /etc/ssh/
COPY init.sh /usr/local/bin/

RUN chmod u+x /usr/local/bin/init.sh

EXPOSE 80 2222
RUN which python3
ADD certs /
RUN cat /*.crt >> /usr/local/lib/python3.8/site-packages/pip/_vendor/certifi/cacert.pem \
       && cat /*.crt >> /usr/local/lib/python3.8/site-packages/certifi/cacert.pem
COPY . /home/site/wwwroot
#ENTRYPOINT ["/usr/local/bin/init.sh"]
CMD ["bash", "-c", "/usr/local/bin/init.sh"]
