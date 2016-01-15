FROM debian:jessie

MAINTAINER OneAPM <package@oneapm.com>

ENV DOCKER_ONEAPM_CI_AGENT yes
ENV AGENT_VERSION 1:4.2.1-1

# Install the Agent
RUN echo "deb http://apt.oneapm.com/ stable main" > /etc/apt/sources.list.d/oneapm-ci-agent.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 54B043BC \
 && apt-get update \
 && apt-get install --no-install-recommends -y oneapm-ci-agent="${AGENT_VERSION}" \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configure the Agent
# 1. Turn syslog off
# 2. Remove oneapm-ci-agent user from supervisor configuration
# 3. Remove oneapm-ci-agent user from init.d configuration
# 4. Fix permission on /etc/init.d/oneapm-ci-agent
# 5. Remove network check
RUN mv /etc/oneapm-ci-agent/oneapm-ci-agent.conf.example /etc/oneapm-ci-agent/oneapm-ci-agent.conf \
 && sed -i -e"s/^.*log_to_syslog:.*$/log_to_syslog: no/" /etc/oneapm-ci-agent/oneapm-ci-agent.conf \
 && sed -i "/user=oneapm-ci-agent/d" /etc/oneapm-ci-agent/supervisor.conf \
 && sed -i 's/AGENTUSER="oneapm-ci-agent"/AGENTUSER="root"/g' /etc/init.d/oneapm-ci-agent \
 && chmod +x /etc/init.d/oneapm-ci-agent \
 && rm /etc/oneapm-ci-agent/conf.d/network.yaml.default

# Add Docker check
COPY conf.d/docker_daemon.yaml /etc/oneapm-ci-agent/conf.d/docker_daemon.yaml

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
# Extra conf.d
CMD mkdir -p /conf.d
VOLUME ["/conf.d"]

# Expose OneStatsD port
EXPOSE 8251/udp

ENTRYPOINT ["/entrypoint.sh"]
CMD ["supervisord", "-n", "-c", "/etc/oneapm-ci-agent/supervisor.conf"]
