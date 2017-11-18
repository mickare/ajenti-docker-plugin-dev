# Ajenti Dockerized Dev-Environment

Bootstrap to get a full ajenti plugin dev environment up and running.
Ajenti dev commands will be wrapped and executed inside a docker image.

## Warning

DON'T name your plugin with an underscore in the name. At the moment this will break Ajenti.

So instead "test_plugin" name your plugin "test plugin".

## Setup

Create the docker image that is used to run the development environment.
```./project.sh --setup```

## Usage

1. Create plugin:
    `./project.sh -n "Plugin"`
2. Build plugin:
    `./project.sh -b "Plugin"`
3. Run ajenti with plugin:
    `./project.sh -r "Plugin"`

Or build and run with one command: `./project.sh -b -r "Plugin"`

## ToDo

- [ ] "?" Help in script.
- [ ] Improve script to pass command args directly to `ajenti-dev-multitool` in the container.
