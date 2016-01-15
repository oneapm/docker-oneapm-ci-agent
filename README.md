# OneAPM CI Agent Dockerfile

This repository is meant to build the base image for a OneAPM CI Agent container. You will have to use the resulting image to configure and run the Agent.


## Quick Start

The default image is ready-to-go. You just need to set your hostname and LICENSE_KEY in the environment.

```
docker run -d --name oneapm-ci-agent -h `hostname` -v /var/run/docker.sock:/var/run/docker.sock -v /proc/:/host/proc/:ro -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro -e LICENSE_KEY={your_license_key_here} oneapm/docker-oneapm-ci-agent
```

If you are running on Amazon Linux, use the following instead:

```
docker run -d --name oneapm-ci-agent -h `hostname` -v /var/run/docker.sock:/var/run/docker.sock -v /proc/:/host/proc/:ro -v /cgroup/:/host/sys/fs/cgroup:ro -e LICENSE_KEY={your_license_key_here}
oneapm/docker-oneapm-ci-agent
```

## Configuration

### Environment variables

A few parameters can be changed with environment variables.

* `TAGS` set host tags. Add `-e TAGS="simple-tag-0,tag-key-1:tag-value-1"` to use [simple-tag-0, tag-key-1:tag-value-1] as host tags.
* `LOG_LEVEL` set logging verbosity (CRITICAL, ERROR, WARNING, INFO, DEBUG). Add `-e LOG_LEVEL=DEBUG` to turn logs to debug mode.
* `PROXY_HOST`, `PROXY_PORT`, `PROXY_USER` and `PROXY_PASSWORD` set the proxy configuration.
* `CI_URL` set the OneAPM intake server to send Agent data to [OneAPM](http://www.oneapm.com)

### Enabling integrations

To enable integrations you can write your YAML configuration files in the `/conf.d` folder, they will automatically be copied to `/etc/oneapm-ci-agent/conf.d/` when the container starts.

1. Create a configuration folder on the host and write your YAML files in it.

    ```
    mkdir /opt/oneapm-ci-agent-conf.d
    touch /opt/oneapm-ci-agent-conf.d/nginx.yaml
    ```

2. When creating the container, mount this new folder to `/conf.d`.
    ```
    docker run -d --name oneapm-ci-agent -h `hostname` -v /var/run/docker.sock:/var/run/docker.sock -v /proc/:/host/proc/:ro -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro -v /opt/oneapm-ci-agent-conf.d:/conf.d:ro -e LICENSE_KEY={your_license_key_here} oneapm/docker-oneapm-ci-agent
    ```

    _The important part here is `-v /opt/oneapm-ci-agent-conf.d:/conf.d:ro`_

Now when the container starts, all files in ``/opt/oneapm-ci-agent-conf.d` with a `.yaml` extension will be copied to `/etc/oneapm-ci-agent/conf.d/`. Please note that to add new files you will need to restart the container.

### Build an image

To configure custom checks, or setup integrations straight in the image, you will need to build a Docker image on top of this image.

1. Create a `Dockerfile` to set your specific configuration or to install dependencies.

    ```
    FROM oneapm/docker-oneapm-ci-agent
    # Example: MySQL
    ADD conf.d/mysql.yaml /etc/oneapm-ci-agent/conf.d/mysql.yaml
    ```

2. Build it.

    `docker build -t oneapm-ci-agent-image .`

3. Then run it like the `oneapm/docker-oneapm-ci-agent` image.

    ```
    docker run -d --name oneapm-ci-agent -h `hostname` -v /var/run/docker.sock:/var/run/docker.sock -v /proc/:/host/proc/:ro -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro -e LICENSE_KEY={your_license_key_here} oneapm-ci-agent-image
    ```

4. It's done!


## Information

To display information about the Agent's state with this command.

`docker exec oneapm-ci-agent service oneapm-ci-agent info`

Warning: the `docker exec` command is available only with Docker 1.3 and above.

## Logs

### Copy logs from the container to the host

That's the simplest solution. It imports container's log to one's host directory.

`docker cp oneapm-ci-agent:/var/log/oneapm-ci-agent /tmp/log-oneapm-ci-agent`

### Supervisor logs

Basic information about the Agent execution are available through the `logs` command.

`docker logs oneapm-ci-agent`


## Limitations

Docker isolates containers from the host. As a result, the Agent won't have access to all host metrics.

Known missing/incorrect metrics:

* Network
* Process list

Also, several integrations might be incomplete.

