# Ajenti Dockerized Dev-Environment

Bootstrap to get a full ajenti plugin dev environment up and running.
Ajenti dev commands will be wrapped and executed inside a docker image.

## Setup

Create the docker image that is used to run the development environment.
`./project.sh --setup`

## Usage

1. Create plugin:
    `./project.sh -n "Plugin"
2. Build plugin:
    `./project.sh -b "Plugin"
3. Run ajenti with plugin:
    `./project.sh -r "Plugin"

Or build and run with one command: `./project.sh -b -r "Plugin"