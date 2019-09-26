#!/bin/bash

function wait_until_db_is_healthy {
    SLEEP_TIME=1
    RETRIES=0
    MAX_RETRIES=10
    until docker-compose run db mysqladmin --host=db ping; do
        if [[ $RETRIES -gt $MAX_RETRIES ]]; then
            echo "mysql never got ready after $RETRIES attempts!"
            exit 1
        fi

        echo "Waiting for mysql..."
        sleep $SLEEP_TIME
        SLEEP_TIME=$((SLEEP_TIME * 2))
        RETRIES=$((RETRIES + 1))
    done
}

function resetdb() {
    if [[ $# -le 0 ]]; then
        printf "E: Requires a database name.\n" >&2;
        printf "Usage: resetdatabase database-name\n";
        return 1;
    fi

    mysql -u root -e "drop database $1;"
    mysql -u root -e "create database $1;"
}

