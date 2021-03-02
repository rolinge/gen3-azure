FROM quay.io/cdis/jupyter-slim:jupyter-covid1.1.3
USER root
RUN apt-get update
RUN apt-get install -y openjdk-8-jdk curl
WORKDIR /usr/local
#LIB DEPENDENCIES
RUN apt-get install -y liblz4-tool && apt-get install -y liblz4-dev
#UTILITIES
RUN apt-get install -y wget && apt-get -y install git
RUN wget -r https://services.gradle.org/distributions/gradle-4.10.2-bin.zip && unzip services.gradle.org/distributions/gradle-4.10.2-bin.zip
RUN wget -r http://archive.cloudera.com/spark2/parcels/latest/SPARK2-2.4.0.cloudera2-1.cdh5.13.3.p0.1041012-xenial.parcel && tar xvf archive.cloudera.com/spark2/parcels/latest/SPARK2-2.4.0.cloudera2-1.cdh5.13.3.p0.1041012-xenial.parcel
RUN apt-get install -y rsync
#HAIL Source
WORKDIR /usr/local
RUN git clone https://github.com/hail-is/hail.git
RUN ls -al
RUN export SPARK_HOME=/usr/local/archive.cloudera.com/spark2/parcels/latest/SPARK2-2.4.0.cloudera2-1.cdh5.13.3.p0.1041012-xenial.parcel
RUN export PATH=$PATH:/usr/local/services.gradle.org/distributions/gradle-4.10.2/bin
RUN ls -al
WORKDIR /usr/local/hail/hail
RUN make install-on-cluster HAIL_COMPILE_NATIVES=1 SPARK_VERSION=2.4.0 PY4J_VERSION=0.10.7

#Certificate

ADD ca-certs /
RUN if (ls /*crt ) ; then cp /*.crt /usr/local/share/ca-certificates/ && update-ca-certificates; fi
RUN if (ls /*crt ) ; then  for i in /*.crt; do certname=`openssl x509 -noout -subject -in $i | sed -n 's/ .*CN *= //;s/subject=CN *=//p'`; keytool -import -trustcacerts -noprompt \
    -keystore /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/cacerts -storepass changeit     \
    -file $i -alias $certname; done; fi

RUN apt-get install -y libpq-dev && pip install pyspark==2.4.1 gen3 psycopg2

RUN cat /etc/ssl/certs/ca-certificates.crt >> /opt/conda/lib/python3.7/site-packages/certifi/cacert.pem

WORKDIR  /home/jovyan

USER jovyan:root
