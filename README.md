# Example balenaEngine docker image

Example [balenaEngine](https://github.com/balena-os/balena-engine) container image, suitable for use as a Docker build stage.

For a more minimal runtime image based on buildroot, check out <https://github.com/balena-io-playground/balena-engine-docker>.

## Build

This example is not published on any repo so you'll need to build it yourself.

```bash
docker build . --build-arg BALENA_VERSION=v19.03.30 --tag balena-engine
```

## Test

```bash
docker run -d --privileged --name balena -p "2375:2375" balena-engine
DOCKER_HOST=tcp://127.0.0.1:2375 docker info
DOCKER_HOST=tcp://127.0.0.1:2375 docker run hello-world
docker rm --force balena
```

## Usage

Much like [Docker-in-Docker](https://hub.docker.com/_/docker), elevated permissions are required for running balenaEngine in a container.

```bash
# print usage flags
docker run --rm balena-engine --help

# run with volatile storage
docker run --rm -it --privileged \
  -p "2375:2375" balena-engine

# run with persistent data volume
docker run --rm -it --privileged \
  -v "balena:/var/lib/balena-engine"
  -p "2375:2375" balena-engine

# run in the background as a service (detached)
docker run -d --privileged \
  -v "balena:/var/lib/balena-engine"
  -p "2375:2375" balena-engine
```

## Contributing

Please open an issue or submit a pull request with any features, fixes, or changes.
