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
### Configure Environment
To configure an environment, install Git, clone this repository, and execute the
`configure` script. See the `configure` script's help text for usage details.
```shell
sudo apt update && sudo apt -y install git
git clone https://github.com/apcountryman/environment.git
cd environment
./configure --help
```

## Git Hooks
To install this repository's Git hooks, run the `install` script located in the
`git/hooks` directory.
See the script's help text for usage details.
```shell
./git/hooks/install --help
```

## Authors
- Andrew Countryman

## License
`environment` is licensed under the Apache License, Version 2.0.
For more information, [see the `LICENSE` file in this repository](LICENSE).
