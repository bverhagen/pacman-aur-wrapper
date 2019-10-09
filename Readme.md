pacman-aur-wrapper
==================
Docker container with an [AUR](https://aur.archlinux.org/) wrapper pre-installed.
This is mainly useful to be used as a base container for building other containers.

Currently supported AUR wrappers:
- [Yet another Yogurt](https://github.com/Jguer/yay) or yay (default)

## Using the image
By default, the root user is used when running the container. However, AUR wrappers disapprove of being ran as the root user. Most even refuse to do anything when run as the root user. This image supports the _nobody_ user to do all non-root tasks. You can run as this user using:
```bash
sudo -E -u nobody <your command>
```

## Pre-build container
This container is built on a daily basis and pushed to [Docker hub](https://hub.docker.com/r/bverhagen/pacman-aur-wrapper).

_Note:_ Check the _tags_ for selecting the desired AUR wrappers.

## Building from source
### Using [exec-helper](https://github.com/bverhagen/exec-helper)
```bash
exec-helper build
```

### Using docker-build
```bash
docker build --tag "pacman-aur-wrapper" -f <wrapper>.Dockerfile .
```
