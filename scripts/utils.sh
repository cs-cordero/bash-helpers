#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
RESET='\033[0m'

function capture_stdout_and_stderr_if_successful {
    set +e
    COMMAND=$*
    printf "Running %s ... " "${COMMAND}"

    if ! OUTPUT=$($COMMAND 2>&1); then
        AT_LEAST_ONE_ERROR=1
        printf "%bFailed%b\n" "${RED}" "${RESET}"
        printf "%s\n\n" "${OUTPUT}"
    else
        printf "%bSuccess!%b\n" "${GREEN}" "${RESET}"
    fi
    set -e
}

function store_if_at_least_one_error {
    set +e
    if ! "$@"; then
        # shellcheck disable=SC2034
        AT_LEAST_ONE_ERROR=1
    fi
    set -e
}

function prompt() {
    echo "$@" >&1
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) break;;
            No ) exit 1;;
        esac
    done
}
