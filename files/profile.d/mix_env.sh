#!/bin/bash

# set the mix env to prod unless we're in `nanobox run` context
if [[ ! "$APP_NAME" = "dev" ]]; then
  export MIX_ENV=prod
fi
