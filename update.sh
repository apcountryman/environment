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

# Description: Host update script.

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
        "    $mnemonic - Update a host.\n" \
        "SYNOPSIS\n" \
        "    $mnemonic --help\n" \
        "    $mnemonic --version\n" \
        "OPTIONS\n" \
        "    --help\n" \
        "        Display this help text.\n" \
        "    --version\n" \
        "        Display the version of this script.\n" \
        "EXAMPLES\n" \
        "    $mnemonic --help\n" \
        "    $mnemonic --version\n" \
        "    $mnemonic\n" \
        ""
}

function display_version()
{
    echo "$mnemonic, version $version"
}

function ensure_environment_has_been_configured()
{
    if [[ ! -e "$log_file" ]]; then
        abort "environment has not been configured"
    fi
}

function log_event()
{
    local -r event="$1"

    if ! echo "$( date --utc +'%F %H:%M:%S' ) ($version) - $event" | sudo tee -a "$log_file"; then
        abort "log failure"
    fi
}

function update_and_install_packages()
{
    local packages; mapfile -t packages < <( sed '/^#/ d' "$repository/packages" | sed '/^$/ d' | sort ); readonly packages

    if ! ( sudo apt update && sudo apt -y autoremove && sudo apt -y dist-upgrade && sudo apt -y install "${packages[@]}" ); then
        abort "packages update/installation failure"
    fi
}

function update_environment()
{
    local -r log_file="/var/log/environment"

    ensure_environment_has_been_configured

    log_event "update started"

    update_and_install_packages

    log_event "update completed"
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

    update_environment
}

main "$@"
