# environment

[![CI](https://github.com/apcountryman/environment/actions/workflows/ci.yml/badge.svg)](https://github.com/apcountryman/environment/actions/workflows/ci.yml)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.0-4baaaa.svg)](CODE_OF_CONDUCT.md)

Host environment creation, configuration, and utilities.

## Obtaining the Source Code

HTTPS:
```shell
git clone https://github.com/apcountryman/environment.git
```
SSH:
```shell
git clone git@github.com:apcountryman/environment.git
```

## Usage

### Configure Environment

To configure an environment, install Git, clone this repository, and execute the
`configure.sh` script.
See the `configure.sh` script's help text for usage details.
```shell
sudo apt update && sudo apt -y install git shellcheck
git clone https://github.com/apcountryman/environment.git
cd environment
./configure.sh --help
```

### Update Environment

To update an environment, execute the `update.sh` script.
See the `update.sh` script's help text for usage details.
```shell
./update.sh --help
```

### Add SSH Connection

To add an SSH connection, execute the `add-ssh-connection.sh` script.
See the `add-ssh-connection.sh` script's help text for usage details.
```shell
./add-ssh-connection.sh --help
```

## Versioning

Post version 0.3.0, environment will follow the [Abseil Live at Head
philosophy](https://abseil.io/about/philosophy).

## Workflow

environment uses the [GitHub flow](https://guides.github.com/introduction/flow/) workflow.

## Git Hooks

To install this repository's Git hooks, execute the `install.sh` script located in the
`git/hooks` directory.
See the `install.sh` script's help text for usage details.
```shell
./git/hooks/install.sh --help
```

## Code of Conduct

environment has adopted the Contributor Covenant 2.0 code of conduct.
For more information, [see the `CODE_OF_CONDUCT.md` file in this
repository](CODE_OF_CONDUCT.md).

## Contributing

If you are interested in contributing to environment, please [read the `CONTRIBUTING.md`
file in this repository](CONTRIBUTING.md).

## Authors

- Andrew Countryman

## License

environment is licensed under the Apache License, Version 2.0.
For more information, [see the `LICENSE` file in this repository](LICENSE).
