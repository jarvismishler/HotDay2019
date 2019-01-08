FROM dynanate/my-es-image
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

WORKDIR /usr/share/elasticsearch

COPY logging.yml /usr/share/elasticsearch/config/
COPY elasticsearch.yml /usr/share/elasticsearch/config/
COPY start.sh /usr/share/elasticsearch/bin
RUN chown elasticsearch:elasticsearch /usr/share/elasticsearch/bin/start.sh
RUN chmod 755 /usr/share/elasticsearch/bin/start.sh
USER root

ENV PATH=$PATH:/usr/share/elasticsearch/bin

CMD bash -C '/usr/share/elasticsearch/bin/start.sh'

EXPOSE 9200 9300
