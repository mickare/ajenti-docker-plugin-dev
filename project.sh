#!/bin/bash

CURDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null && pwd )" 

CLEAN=false
SETUP=false
NEW_PLUGIN=false

BUILD=false
RUN=false

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    --clean)
    CLEAN=true
    shift # past argument
    ;;
    -s|--setup)
    SETUP=true
    shift # past argument
    ;;
    -n|--new)
    NEW_PLUGIN=true
    shift # past argument
    ;;
    -b|--build)
    BUILD=true
    shift # past argument
    ;;
    -r|--run)
    RUN=true
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters


DOCKER_NAME="ajenti_dev_environment"
DOCKER_VERSION="latest"

PROJECT_VOLUME="${CURDIR}/:/opt/ajenti/"

USER_ID=$(id -u)
USER_GROUP=$(id -g)
USER="${USER_ID}:${USER_GROUP}"

project_clean() {
    docker image rm -f "${DOCKER_NAME}:${DOCKER_VERSION}"
}

project_setup() {

    docker build --rm \
        --no-cache=false \
        -t "${DOCKER_NAME}:${DOCKER_VERSION}" \
        --network=host \
        --build-arg USER_ID=${USER} \
        -f="dev_environment/Dockerfile" \
        .
}

project_new_plugin() {

    PLUGIN_NAME="$1"

    docker run -it --rm \
        --volume="${PROJECT_VOLUME}" \
        --user=${USER} \
        "${DOCKER_NAME}:${DOCKER_VERSION}" \
        ajenti-dev-multitool --new-plugin "${PLUGIN_NAME}"
}


project_build() {

    PLUGIN_NAME="$1"

    docker run -it --rm \
        --volume="${PROJECT_VOLUME}" \
        --user=${USER} \
        "${DOCKER_NAME}:${DOCKER_VERSION}" \
        bash -c "cd ${PLUGIN_NAME} && ajenti-dev-multitool --build"
}


project_run() {

    PLUGIN_NAME="$1"

    docker run -it --rm \
        --volume="${PROJECT_VOLUME}" \
        -p 8000:8000 \
        "${DOCKER_NAME}:${DOCKER_VERSION}" \
        bash -c "cd ${PLUGIN_NAME} && ajenti-dev-multitool --run-dev"
}


main() {

    if $CLEAN; then
        project_clean
    fi

    if $SETUP; then
        project_setup
    fi

    if ! $(docker image ls | grep -q "${DOCKER_NAME}"); then
        >&2 echo "Please run setup first: ./project.sh --setup" 
        exit 1
    fi


    if [ $NEW_PLUGIN ] || [ $BUILD ] || [ $RUN ]; then

        if [ ! -n "$POSITIONAL" ]; then
            >&2 echo "Plugin name missing!"
            exit 1
        fi

        PLUGIN_NAME="${POSITIONAL[0]}"
        PLUGIN_NAME=echo "$PLUGIN_NAME" | sed -e "s/\s/\_/g" | tr '[:upper:]' '[:lower:]'

        
        if $NEW_PLUGIN; then
            project_new_plugin "${PLUGIN_NAME}"
        fi

        if $BUILD; then
            project_build "${PLUGIN_NAME}"
        fi

        if $RUN; then
            project_run "${PLUGIN_NAME}"
        fi

    fi
}

main