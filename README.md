# environment
Host/VM environment creation, configuration, and utilities.

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
### Initialize VM
To initialize a VM, execute the `initialize-vm` script.
See the `initialize-vm` script's help test for usage details.
```shell
./initialize-vm --help
```

### Configure Environment
To configure an environment, install Git, clone this repository, and execute the
`configure` script.
See the `configure` script's help text for usage details.
```shell
sudo apt update && sudo apt -y install git
git clone https://github.com/apcountryman/environment.git
cd environment
./configure --help
```

### Update Environment
To update an environment, execute the `update` script.
See the `update` script's help text for usage details.
```shell
./update --help
```

### Add SSH Connection
To add an SSH connection, execute the `add-ssh-connection` script.
See the `add-ssh-connection` script's help text for usage details.
```shell
./add-ssh-connection --help
```

## Versioning
Post version 0.3.0, `environment` will follow the [Abseil Live at Head
philosophy](https://abseil.io/about/philosophy).

## Workflow
`environment` uses the [GitHub flow](https://guides.github.com/introduction/flow/)
workflow.

## Git Hooks
To install this repository's Git hooks, execute the `install` script located in the
`git/hooks` directory.
See the `install` script's help text for usage details.
```shell
./git/hooks/install --help
```

## Authors
- Andrew Countryman

## License
`environment` is licensed under the Apache License, Version 2.0.
For more information, [see the `LICENSE` file in this repository](LICENSE).
