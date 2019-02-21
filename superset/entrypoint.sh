#!/bin/bash

# Install custom python package if requirements.txt is present
if [ -e "/requirements.txt" ]; then
    $(which pip) pip install --no-cache-dir -r /requirements.txt
fi
