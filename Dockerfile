FROM golang:1.12.17-alpine3.11 AS go-build

RUN apk add --no-cache linux-headers git build-base bash pkgconf

ENV GOPATH "/go"

WORKDIR /go/src/github.com/docker/docker

ARG BALENA_VERSION=v19.03.30

RUN git clone --branch ${BALENA_VERSION} --depth 1 https://github.com/balena-os/balena-engine.git .

ENV DOCKER_BUILDTAGS "no_btrfs no_cri no_devmapper no_zfs exclude_disk_quota exclude_graphdriver_btrfs exclude_graphdriver_devicemapper exclude_graphdriver_zfs no_buildkit"
ENV GO111MODULE "off" 
ENV CGO_ENABLED "0"
ENV DOCKER_LDFLAGS "-s"

RUN DOCKER_GITCOMMIT="$(git rev-parse --verify ${BALENA_VERSION})" VERSION=${BALENA_VERSION} ./hack/make.sh dynbinary-balena

# TODO: build without the script above, but make sure all the desired versions are set correctly
# RUN export VERSION=${BALENA_VERSION} && \
#     export GITCOMMIT=$(git rev-parse --verify ${BALENA_VERSION}) && \
#     export BUILDTIME=$(date) && \
#     export LDFLAGS="-s \
#     -X \"github.com/docker/docker/vendor/github.com/docker/cli/cli/version.GitCommit=${GITCOMMIT}\" \
#     -X \"github.com/docker/docker/vendor/github.com/docker/cli/cli/version.BuildTime=${BUILDTIME}\" \
#     -X \"github.com/docker/docker/vendor/github.com/docker/cli/cli/version.Version=${VERSION}\" \
#     -X \"github.com/docker/docker/dockerversion.GitCommit=${GITCOMMIT}\" \
#     -X \"github.com/docker/docker/dockerversion.BuildTime=${BUILDTIME}\" \
#     -X \"github.com/docker/docker/dockerversion.Version=${VERSION}\" " && echo $LDFLAGS && \
#     go build -tags "${BUILDTAGS}" -ldflags "${LDFLAGS}" -o /usr/bin/balena-engine ./cmd/balena-engine/

FROM alpine

COPY --from=go-build /go/src/github.com/docker/docker/bundles/dynbinary-balena/balena-engine /usr/bin/

RUN ln -s /usr/bin/balena-engine /usr/bin/balenad && \
	ln -s /usr/bin/balena-engine /usr/bin/balena-engine-daemon && \
	ln -s /usr/bin/balena-engine /usr/bin/balena-engine-containerd && \
	ln -s /usr/bin/balena-engine /usr/bin/balena-engine-containerd-ctr && \
	ln -s /usr/bin/balena-engine /usr/bin/balena-engine-containerd-shim && \
	ln -s /usr/bin/balena-engine /usr/bin/balena-engine-proxy && \
	ln -s /usr/bin/balena-engine /usr/bin/balena-engine-runc && \
	ln -s /usr/bin/balena-engine /usr/bin/balena-engine-init

RUN balena-engine version 2>/dev/null || true

RUN apk add --no-cache iptables

ENTRYPOINT [ "/usr/bin/balena-engine-daemon" ]

CMD [ "-H", "tcp://0.0.0.0:2375" ]
