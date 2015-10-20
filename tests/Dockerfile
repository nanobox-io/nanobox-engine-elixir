FROM nanobox/build

# Remove existing engines, we don't want to test those
RUN rm -rf /opt/engines/*

# Create folders for this engine
RUN mkdir -p /opt/engines/elixir/bin && \
    mkdir -p /opt/engines/elixir/lib && \
    mkdir -p /opt/engines/elixir/templates

# Add in this engine's files
ADD bin/. /opt/engines/elixir/bin
ADD lib/. /opt/engines/elixir/lib
ADD templates/. /opt/engines/elixir/templates