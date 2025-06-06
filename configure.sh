#!/usr/bin/env bash

# environment
#
# Copyright 2020-2025, Andrew Countryman <apcountryman@gmail.com> and the environment
# contributors
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
# file except in compliance with the License. You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the specific language governing
# permissions and limitations under the License.

# Description: Host configuration script.

function error()
{
    local -r message="$1"

    ( >&2 echo "$mnemonic: $message" )
}

function abort()
{
    if [[ "$#" -gt 0 ]]; then
        local -r message="$1"

        error "$message, aborting"
    fi

    exit 1
}

function validate_script()
{
    if ! shellcheck "$script"; then
        abort
    fi
}

function display_help_text()
{
    printf "%b" \
        "NAME\n" \
        "    $mnemonic - Configure a host.\n" \
        "SYNOPSIS\n" \
        "    $mnemonic --help\n" \
        "    $mnemonic --version\n" \
        "    $mnemonic [--github-username <username>]\n" \
        "OPTIONS\n" \
        "    --github-username <username>\n" \
        "        Generate a GitHub SSH key for the specified user.\n" \
        "    --help\n" \
        "        Display this help text.\n" \
        "    --version\n" \
        "        Display the version of this script.\n" \
        "EXAMPLES\n" \
        "    $mnemonic --help\n" \
        "    $mnemonic --version\n" \
        "    $mnemonic\n" \
        "    $mnemonic --github-username apcountryman\n" \
        ""
}

function display_version()
{
    echo "$mnemonic, version $version"
}

function ensure_environment_has_not_been_configured()
{
    if [[ -e "$log_file" ]]; then
        abort "environment has already been configured"
    fi
}

function log_event()
{
    local -r event="$1"

    if ! echo "$( date --utc +'%F %H:%M:%S' ) ($version) - $event" | sudo tee -a "$log_file"; then
        abort "log failure"
    fi
}

function enable_boot_messages()
{
    if ! sudo sed -i 's/quiet splash//g' "/etc/default/grub"; then
        abort "boot messages enable failure"
    fi

    if ! sudo update-grub; then
        abort "GRUB update failure"
    fi
}

function purge_modemmanager()
{
    if ! sudo apt -y purge modemmanager; then
        abort "modemmanager purge failure"
    fi
}

function update_and_install_packages()
{
    local packages; mapfile -t packages < <( sed '/^#/ d' "$repository/packages" | sed '/^$/ d' | sort ); readonly packages

    if ! ( sudo apt update && sudo apt -y autoremove && sudo apt -y dist-upgrade && sudo apt -y install "${packages[@]}" ); then
        abort "packages update/installation failure"
    fi
}

function configure_editor()
{
    if ! sudo update-alternatives --set editor "/usr/bin/vim.basic"; then
        abort "editor configuration failure"
    fi
}

function generate_and_install_github_ssh_key()
{
    local -r key="$HOME/.ssh/$github_username-github"

    if ! ssh-keygen -t rsa -b 4096 -f "$key" -C "$USER@$( hostname ) for $github_username@github.com"; then
        abort "GitHub SSH key generation failure"
    fi

    if ! printf "Host github.com\n    User $github_username\n    IdentityFile %s\n    PreferredAuthentications publickey\n\n" "$key" > "$HOME/.ssh/config"; then
        abort "GitHub SSH key installation failure"
    fi
}

function add_user_to_groups()
{
    local -r user_groups=(
        "dialout"
    )

    for user_group in "${user_groups[@]}"; do
        if ! sudo adduser "$USER" "$user_group"; then
            abort "'$user_group' group add failure"
        fi
    done
}

function configure_environment()
{
    local -r log_file="/var/log/environment"

    ensure_environment_has_not_been_configured

    log_event "configuration started"

    enable_boot_messages

    purge_modemmanager

    update_and_install_packages

    configure_editor

    if [[ -n "$github_username" ]]; then
        generate_and_install_github_ssh_key
    fi

    add_user_to_groups

    log_event "configuration completed"

    sudo reboot now
}

function main()
{
    local -r script=$( readlink -f "$0" )
    local -r mnemonic=$( basename "$script" )

    validate_script

    local -r repository=$( dirname "$script" )
    local -r version=$( git -C "$repository" describe --match=none --always --dirty --broken )

    while [[ "$#" -gt 0 ]]; do
        local argument="$1"; shift

        case "$argument" in
            --github-username)
                if [[ -n "$github_username" ]]; then
                    abort "GitHub username already specified"
                fi

                if [[ "$#" -le 0 ]]; then
                    abort "GitHub username not specified"
                fi

                local -r github_username="$1"; shift
                ;;
            --help)
                display_help_text
                exit
                ;;
            --version)
                display_version
                exit
                ;;
            --*)
                ;&
            -*)
                abort "'$argument' is not a supported option"
                ;;
            *)
                abort "'$argument' is not a valid argument"
                ;;
        esac
    done

    configure_environment
}

main "$@"
