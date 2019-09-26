#!/bin/bash

function pyclean() {
    find . -type f -name "*.py[co]" -delete
    find . -type d -name "__pycache__" -delete
}

function resetmigrations() {
    find . -path "*/migrations/*.py" -not -name "__init__.py" -delete
    find . -path "*/migrations/*.pyc"  -delete
}

