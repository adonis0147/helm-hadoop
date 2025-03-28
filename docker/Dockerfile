FROM alpine:latest AS builder

WORKDIR /tmp

COPY hadoop-*.tar.gz .
RUN tar -zxvf hadoop-*.tar.gz -C /

COPY *jdk*.tar.gz .
RUN tar -zxvf *jdk*.tar.gz -C /

FROM ubuntu:latest

ARG PASSWORD

RUN mkdir -p /home/hadoop

WORKDIR /home/hadoop

COPY --from=builder /hadoop-* hadoop-current
COPY --from=builder /amazon-corretto-* /opt/java

RUN mkdir -p cluster-data/hadoop/logs cluster-data/hadoop/pids

ENV PATH="/opt/java/bin:/home/hadoop/hadoop-current/bin:/home/hadoop/hadoop-current/sbin:${PATH}"
ENV JAVA_HOME='/opt/java'
ENV HADOOP_LOG_DIR='/home/hadoop/cluster-data/hadoop/logs'
ENV HADOOP_PID_DIR='/home/hadoop/cluster-data/hadoop/pids'

CMD ["/usr/bin/bash"]
