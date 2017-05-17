#!/bin/bash

# set the PORT env to 8080 unless we're in `nanobox run` context
if [[ ! "$APP_NAME" = "dev" ]]; then
  export PORT=8080
fi
