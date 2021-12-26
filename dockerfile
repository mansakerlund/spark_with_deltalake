# https://pythonspeed.com/articles/alpine-docker-python/
FROM python:3.9-alpine3.14

# versions for a flexible install
# it is important to select version that are copatible but unfortunately I have 
# not found a good list for that other than
# https://spark.apache.org/downloads.html
ARG SPARK_VERSION=3.2.0
ARG HADOOP_VERSION_SHORT=3.2
ARG HADOOP_VERSION=3.2.2
ARG AWS_SDK_VERSION=1.11.375

#RUN apt-get update && apt-get install -y tini

# Adds sbin to folder path
ENV PATH="${PATH}:/sbin"

# apk is the package manager of alpine linux
# https://git.alpinelinux.org/apk-tools/about/

# bash 
RUN apk add --no-cache bash 

# https://musl.libc.org/about.html
# adds c api to underlying linux
RUN apk add --no-cache libc6-compat 
RUN ln -s /lib/libc.musl-x86_64.so.1 /lib/ld-linux-x86-64.so.2 

# "Find pyspark to make it importable.", whatever that means.....
RUN pip install findspark


# ca-certificates
# https://askubuntu.com/questions/857476/what-is-the-use-purpose-of-the-ca-certificates-package

# coreutils
# https://www.gnu.org/software/coreutils/

# openjdk, java11 required by spark

# tzdata, timezone database
# https://developers.redhat.com/blog/2020/04/03/whats-new-with-tzdata-the-time-zone-database-for-red-hat-enterprise-linux

# curl
# command line tool and library for transferring data with URLs
# https://curl.se/

# unzip
# unpack zip files
# https://linux.die.net/man/1/unzip


# nss
# accessing linux system databases like password and group database
# https://man7.org/linux/man-pages/man5/nss.5.html#DESCRIPTION

# /var/cache
# /var/cache is intended for cached data from applications. Such data is locally generated as a result of time-consuming I/O or calculation. The application must be able to regenerate or restore the data. Unlike /var/spool , the cached files can be deleted without data loss.
# https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch05s05.html#:~:text=%2Fvar%2Fcache%20is%20intended%20for,be%20deleted%20without%20data%20loss.

RUN  apk update \
  && apk upgrade \
  && apk add ca-certificates \
  && update-ca-certificates \
  && apk add --update coreutils && rm -rf /var/cache/apk/*   \ 
  && apk add --update openjdk11 tzdata curl unzip \
  && apk add --no-cache nss \
  && rm -rf /var/cache/apk/*

# Download and extract Spark
RUN wget -qO- https://www-eu.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION_SHORT}.tgz | tar zx -C /opt && \
    mv /opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION_SHORT} /opt/spark

# create a spark config file that contains the reference to the aws credentials resolver 
# https://docs.aws.amazon.com/AWSJavaSDK/latest/javadoc/com/amazonaws/auth/AWSCredentialsProvider.html
 RUN echo spark.hadoop.fs.s3a.aws.credentials.provider=com.amazonaws.auth.EnvironmentVariableCredentialsProvider > /opt/spark/conf/spark-defaults.conf

# Add hadoop-aws and aws-sdk
RUN wget https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_VERSION}/hadoop-aws-${HADOOP_VERSION}.jar -P /opt/spark/jars/ && \ 
    wget https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/${AWS_SDK_VERSION}/aws-java-sdk-bundle-${AWS_SDK_VERSION}.jar -P /opt/spark/jars/

ENV PATH="/opt/spark/bin:${PATH}"
ENV PYSPARK_PYTHON=python3
ENV PYTHONPATH="${SPARK_HOME}/python:${SPARK_HOME}/python/lib/py4j-0.10.9-src.zip:${PYTHONPATH}"
# Define default command

RUN mkdir $SPARK_HOME/conf
RUN echo "SPARK_LOCAL_IP=127.0.0.1" > $SPARK_HOME/conf/spark-env.sh

#Copy python script for batch
#COPY app.py /app/app.py
# Define default command
CMD ["/bin/bash"]
