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

# Description: SSH connection addition script.

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
        "    $mnemonic - Add an SSH connection.\n" \
        "SYNOPSIS\n" \
        "    $mnemonic --help\n" \
        "    $mnemonic --version\n" \
        "    $mnemonic --name <name> --ip-address <address> --key-comment <comment>\n" \
        "OPTIONS\n" \
        "    --help\n" \
        "        Display this help text.\n" \
        "    --ip-address <address>\n" \
        "        Specify the remote host's IP address.\n" \
        "    --key-comment <comment>\n" \
        "        Specify the connection's SSH key comment.\n" \
        "    --name <name>\n" \
        "        Specify the remote host's name.\n" \
        "    --version\n" \
        "        Display the version of this script.\n" \
        "EXAMPLES\n" \
        "    $mnemonic --help\n" \
        "    $mnemonic --version\n" \
        "    $mnemonic --name foo --ip-address 192.168.56.2 --key-comment bar\n" \
        ""
}

function display_version()
{
    echo "$mnemonic, version $version"
}

function generate_key()
{
    if ! ssh-keygen -t rsa -b 4096 -f "$private_key" -C "$key_comment"; then
        abort "SSH key generation failure"
    fi
}

function install_local_key()
{
    if ! printf "Host %s\n    HostName %s\n    User %s\n    IdentityFile %s\n    PreferredAuthentications publickey\n\n" "$name" "$ip_address" "$USER" "$private_key" >> "$HOME/.ssh/config"; then
        abort "local SSH key installation failure"
    fi
}

function install_remote_key()
{
    if ! ssh-copy-id -i "$public_key" "$USER@$ip_address"; then
        abort "remote SSH key installation failure"
    fi
}

function add_ssh_connection()
{
    local -r private_key="$HOME/.ssh/$USER-$name"
    local -r public_key="$private_key.pub"

    generate_key
    install_local_key
    install_remote_key
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
            --help)
                display_help_text
                exit
                ;;
            --ip-address)
                if [[ -n "$ip_address" ]]; then
                    abort "remote host IP address already specified"
                fi

                if [[ "$#" -le 0 ]]; then
                    abort "remote host IP address not specified"
                fi

                local -r ip_address="$1"; shift
                ;;
            --key-comment)
                if [[ -n "$key_comment" ]]; then
                    abort "connection SSH key comment already specified"
                fi

                if [[ "$#" -le 0 ]]; then
                    abort "connection SSH key comment not specified"
                fi

                local -r key_comment="$1"; shift
                ;;
            --name)
                if [[ -n "$name" ]]; then
                    abort "remote host name / name prefix already specified"
                fi

                if [[ "$#" -le 0 ]]; then
                    abort "remote host name not specified"
                fi

                local -r name="$1"; shift
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

    if [[ -z "$ip_address" ]]; then
        abort "'--ip-address' must be specified"
    fi

    if [[ -z "$key_comment" ]]; then
        abort "'--key-comment' must be specified"
    fi

    if [[ -z "$name" ]]; then
        abort "'--name' or '--name-prefix' must be specified"
    fi

    add_ssh_connection
}

main "$@"
