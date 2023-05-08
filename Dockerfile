#FROM adoptopenjdk/openjdk11:latest
#FROM azul/zulu-openjdk-alpine:boge
FROM registry.cmri.cn/admodel/centos7-cmri-basejdk:latest
 
MAINTAINER liuxiaoboai

ENV KAFKA_HOME="/opt/kafka_2.12-3.3.1" \
    LANG=C.UTF-8 \
    TZ=Asia/Shanghai
 
COPY kafka_2.12-3.3.1.tgz /opt
 
RUN cd /opt && tar -zxvf kafka_2.12-3.3.1.tgz -C /opt
 
RUN rm -rf kafka_2.12-3.3.1.tgz
 
COPY start-kafka.sh ${KAFKA_HOME}/bin
 
WORKDIR ${KAFKA_HOME}



ENTRYPOINT ["/bin/bash", "bin/start-kafka.sh" ]
