# Example - Kafka
#
# Agent running a Kafka check

FROM oneapm/docker-oneapm-ci-agent

# Install JMXFetch dependencies
RUN apt-get install openjdk-7-jre-headless -qq --no-install-recommends

# Add Kafka check configuration
ADD kafka.yaml /etc/oneapm-ci-agent/conf.d/kafka.yaml

