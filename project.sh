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
    -c|--clean)
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
DOCKER_IMAGE="${DOCKER_NAME}:${DOCKER_VERSION}"
DOCKER_RUNTIME_NAME="${DOCKER_NAME}"

PROJECT_VOLUME="${CURDIR}/:/opt/ajenti/"

USER_ID=$(id -u)
USER_GROUP=$(id -g)
USER="${USER_ID}:${USER_GROUP}"

start_environment() {
    if ! $(docker ps -a | grep -q "${DOCKER_RUNTIME_NAME}"); then
        docker create -t \
            --network=host \
            --name="${DOCKER_RUNTIME_NAME}" \
            --volume="${PROJECT_VOLUME}" \
            "${DOCKER_IMAGE}"
    fi
    if ! $(docker ps | grep -q "${DOCKER_RUNTIME_NAME}"); then
        # Only start container if not already running.
        docker start "${DOCKER_RUNTIME_NAME}"
    fi 
}

stop_environment() {
    docker stop "${DOCKER_RUNTIME_NAME}" ;
}

clean_environment() {
    docker rm -f "${DOCKER_RUNTIME_NAME}"
}

setup_project() {

    docker build --rm \
        --no-cache=false \
        -t "${DOCKER_IMAGE}" \
        --network=host \
        --build-arg USER_ID=${USER} \
        -f="dev_environment/Dockerfile" \
        .
}

new_plugin() {

    PLUGIN_NAME="$1"

    echo "Creating new plugin \"$PLUGIN_NAME\"."

    # docker run -it --rm \
    #     --volume="${PROJECT_VOLUME}" \
    #     --network=host \
    #     --user=${USER} \
    #     "${DOCKER_IMAGE}" \
    #     ajenti-dev-multitool --new-plugin "${PLUGIN_NAME}"

    docker exec -it \
        --user=${USER} \
        "${DOCKER_RUNTIME_NAME}" \
        ajenti-dev-multitool --new-plugin "${PLUGIN_NAME}"
}


build_plugin() {

    PLUGIN_NAME="$1"

    echo "Building plugin \"$PLUGIN_NAME\"."

    # docker run -it --rm \
    #     --volume="${PROJECT_VOLUME}" \
    #     --network=host \
    #     --user=${USER} \
    #     "${DOCKER_IMAGE}" \
    #     bash -c "cd ${PLUGIN_NAME} && ajenti-dev-multitool --build"

    docker exec -it \
        --user=${USER} \
        "${DOCKER_RUNTIME_NAME}" \
        bash -c "cd ${PLUGIN_NAME} && ajenti-dev-multitool --rebuild"

}


run_project() {

    PLUGIN_NAME="$1"

    echo "Running with plugin \"$PLUGIN_NAME\"."

    # docker run -it --rm \
    #     --volume="${PROJECT_VOLUME}" \
    #     --network=host \
    #     -p 8000:8000 \
    #     "${DOCKER_IMAGE}" \
    #     bash -c "ajenti-dev-multitool --run-dev"
    
    docker exec -it \
        "${DOCKER_RUNTIME_NAME}" \
        bash -c "ajenti-dev-multitool --run-dev"
}


main() {

    if $CLEAN; then
        clean_environment
    fi

    if $SETUP; then
        setup_project
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
        PLUGIN_NAME=$(echo "$PLUGIN_NAME" | sed -e "s/\s/\_/g" | tr '[:upper:]' '[:lower:]')

        start_environment

        if $NEW_PLUGIN; then
            new_plugin "${PLUGIN_NAME}"
        fi

        if $BUILD; then
            build_plugin "${PLUGIN_NAME}"
        fi

        if $RUN; then
            run_project "${PLUGIN_NAME}"
        fi

        stop_environment

    fi
}

main