# Spark playground docker


# Get started
 1. change to folder with dockerfile
 2. build docker image
 docker build .
 3. start container
 docker run -it <container> /bin/bash




# Tested on
This docker file has only been tested on wsl.

# Requirements
docker

# Introduction
This dockerfile was created to enable playing around with Spark, delta lake and S3 on a laptop. 


# Docker file layout
dockerfile has not been optimized according to best practices, but here are some guildelines to do that:
https://docs.docker.com/develop/develop-images/dockerfile_best-practices/


# AWS Credentials
Setup uses environment variables so before S3 can be accessed the container needs those variables set

export AWS_ACCESS_KEY_ID=<YOUR_AWS_ACCESS_KEY_ID>
export AWS_SECRET_ACCESS_KEY=<YOUR_AWS_SECRET_ACCESS_KEY>

By replacing the provider in the dockerfile

echo spark.hadoop.fs.s3a.aws.credentials.provider=com.amazonaws.auth.<ANOTHER_PROVIDER_HERE> > /opt/spark/conf/spark-defaults.conf

other providers can be tested.

Docs on implemented provider classes can be found here

https://docs.aws.amazon.com/AWSJavaSDK/latest/javadoc/com/amazonaws/auth/AWSCredentialsProvider.html



# Certificates
Necessary ca certificates for Amazon s3 are part of this installation but if an on premises s3 installation is to be used necessary ca's needs to be added to 
the truststore.

# Useful commands in container

## Spark (Scala) + Deltalake + s3
spark-shell --packages io.delta:delta-core_2.12:1.1.0,org.apache.hadoop:hadoop-aws:3.2.0

## Pyspark + Deltalake + s3 
pyspark --packages io.delta:delta-core_2.12:1.1.0,org.apache.hadoop:hadoop-aws:3.2.0

## Packages command
Short explanation of the --packages command:
Comma-separated list of maven coordinates of jars to include on the driver and executor classpaths. Will search the local maven repo, then maven central and any additional remote repositories given by --repositories.

# Spark commands with delta lake and s3
spark.range(5).write.format("delta").save("s3a://<container>/<path_to_table>/<table_name>")


