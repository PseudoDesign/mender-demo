# mender-demo
A sample build of the Mender project

## Build on CircleCI

Requires the following CircleCI environment variables:

* DOCKER_USER - docker hub username
* DOCKER_PASS - docker hub password

See `.circleci/config.yml` for build details

## Build Locally

The local build, including the build docker image, is managed by `rakefile.rb`

Run `rake -T` for details.

## Documentation

[Quickstart QEMU Demo](docs/qemu_demo.md)
