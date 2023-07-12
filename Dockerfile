FROM openjdk:8
MAINTAINER ome-devel@lists.openmicroscopy.org.uk

# Installs Ant
ENV ANT_VERSION 1.9.4
RUN wget -q http://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.zip && \
  unzip apache-ant-${ANT_VERSION}-bin.zip && \
  mv apache-ant-${ANT_VERSION} /opt/ant && \
  rm apache-ant-${ANT_VERSION}-bin.zip

RUN useradd -m bf
COPY . /opt/bioformats/
RUN chown -R bf /opt/bioformats

WORKDIR /
RUN wget -q "https://github.com/graalvm/graalvm-ce-builds/releases/download/jdk-20.0.1/graalvm-community-jdk-20.0.1_linux-x64_bin.tar.gz" -O graal.tar.gz && tar -xzvf graal.tar.gz > /dev/null && rm graal.tar.gz
ENV JAVA_HOME=/graalvm-community-openjdk-20.0.1+9.1
ENV PATH="/graalvm-community-openjdk-20.0.1+9.1/bin:$PATH"
ENV ANT_OPTS=-agentlib:native-image-agent=config-merge-dir=META-INF/native-image

USER bf
WORKDIR /opt/bioformats
RUN /opt/ant/bin/ant clean jars tools

ENV TZ "Europe/London"

WORKDIR /opt/bioformats/components/test-suite
ENTRYPOINT ["/opt/ant/bin/ant", "test-automated", "-Dtestng.directory=/opt/data", "-Dtestng.configDirectory=/opt/config"]
