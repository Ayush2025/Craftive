#!/usr/bin/env bash
set -x

DOCKER_CLI_EXPERIMENTAL=enabled
ORG=${CRAFTIVE_DOCKER_NAMESPACE:-craftiveapp};
PLATFORM=${CRAFTIVE_BUILD_PLATFORM:-linux/amd64};

IMAGE=${CRAFTIVE_BUILD_IMAGE:-backend}
PLATFORM=${CRAFTIVE_BUILD_PLATFORM:-linux/amd64};
VERSION=${CRAFTIVE_BUILD_VERSION:-latest}

DOCKER_IMAGE="$ORG/$IMAGE";
OPTIONS="-t $DOCKER_IMAGE:$VERSION";

IFS=", "
read -a TAGS <<< $CRAFTIVE_BUILD_TAGS;

for element in "${TAGS[@]}"; do
    OPTIONS="$OPTIONS -t $DOCKER_IMAGE:$element";
done

docker buildx inspect craftive > /dev/null 2>&1;
docker run --privileged --rm tonistiigi/binfmt --install all

if [ $? -eq 1 ]; then
    docker buildx create --name=craftive --use
    docker buildx inspect --bootstrap > /dev/null 2>&1;
else
    docker buildx use craftive;
    docker buildx inspect --bootstrap  > /dev/null 2>&1;
fi

unset IFS;

docker buildx build --platform ${PLATFORM// /,} $OPTIONS -f Dockerfile.$IMAGE "$@" .;
