FROM hadoop-preinstall:latest
# Hadoop env variables
ENV HADOOP_HOME=/usr/local/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

RUN tar -xzf hadoop-${HADOOP_VERSION}.tar.gz && \
    mv hadoop-${HADOOP_VERSION} /usr/local/hadoop && \
    rm hadoop-${HADOOP_VERSION}.tar.gz
# Copy Hadoop configs
    COPY config-hadoop/* $HADOOP_HOME/etc/hadoop



# Configure JAVA_HOME
RUN sed -i 's|^# export JAVA_HOME=.*|export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64|' $HADOOP_HOME/etc/hadoop/hadoop-env.sh

# Copy entrypoint: entrypoint.sh contains the necessary commands to start Hadoop services
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
