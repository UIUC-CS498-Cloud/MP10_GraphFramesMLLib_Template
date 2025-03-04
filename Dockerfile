# Fetch ubuntu 22.04 LTS docker image
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive
ENV PYSPARK_PYTHON=python3

RUN apt-get update && \
	apt-get install -y --no-install-recommends build-essential\
	expect git vim zip unzip wget openjdk-21-jdk wget sudo curl
RUN apt-get install -y python3 python3-pip python-dev-is-python3 build-essential
RUN cd /usr/local/bin; \
ln -s /usr/bin/python3 python;


################################################################################
####################   Spark stuff   ###########################################
################################################################################

# Download and install spark
RUN curl -s "https://archive.apache.org/dist/spark/spark-3.5.0/spark-3.5.0-bin-hadoop3.tgz" | tar -xz  -C /usr/local/ \
    && ln -s /usr/local/spark-3.5.0-bin-hadoop3 /usr/local/spark \
    && chmod a+rwx -R /usr/local/spark/

RUN pip3 install Cython && pip3 install numpy

RUN echo "alias spark-submit='/usr/local/spark/bin/spark-submit'" >> ~/.bashrc

# Graphframes 0.8.4 is only compatible with spark3.5 currently:

RUN cd /usr/local/spark/jars/ && \
	wget https://repos.spark-packages.org/graphframes/graphframes/0.8.4-spark3.5-s_2.12/graphframes-0.8.4-spark3.5-s_2.12.jar && \
 	chmod a+rwx graphframes-0.8.4-spark3.5-s_2.12.jar

ENV PYTHONPATH=:/usr/local/spark/jars/graphframes-0.8.4-spark3.5-s_2.12.jar

# Ensure spark log output is redirected to stderr
RUN cp /usr/local/spark/conf/log4j2.properties /usr/local/spark/conf/log4j.properties || \
    cp /usr/local/spark/conf/log4j.properties.template /usr/local/spark/conf/log4j.properties || \
    echo "log4j.rootCategory=INFO, console" > /usr/local/spark/conf/log4j.properties

# Set relevant environment variables to simplify usage of spark
ENV SPARK_HOME /usr/local/spark
ENV PATH="/usr/local/spark/bin:${PATH}"
RUN chmod a+rwx -R /usr/local/spark/

# WORKDIR /CS498
