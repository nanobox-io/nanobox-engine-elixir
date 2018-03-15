# -*- mode: bash; tab-width: 2; -*-
# vim: ts=2 sw=2 ft=bash noet

# Copy the compiled jars into the app directory to run live
publish_release() {
  nos_print_bullet "Moving build into live app directory..."
  rsync -a -k $(nos_code_dir)/ $(nos_app_dir)
}

# Determine the elixir runtime to install. This will first check
# within the boxfile.yml, then will rely on default_runtime to
# provide a sensible default
runtime() {
  _runtime=$(nos_validate \
    "$(nos_payload "config_runtime")" \
    "string" "$(default_runtime)")
  if [[ "$_runtime" =~ "erlang" ]]; then
    echo "$_runtime"
  else
    _erlang_runtime=$(condesed_erlang_runtime)
    echo "${_erlang_runtime}-${_runtime}"
  fi
}

# Provide a default elixir version.
default_runtime() {
  echo "elixir-1.5"
}

# Determine the erlang runtime to install. This will first check
# within the boxfile.yml, then will rely on default_erlang_runtime to
# provide a sensible default
erlang_runtime() {
  _runtime=$(nos_validate \
    "$(nos_payload "config_runtime")" \
    "string" "$(default_runtime)")
  if [[ "$_runtime" =~ "erlang" ]]; then
    _erlang_runtime=${_runtime//-elixir*/}
    echo "${_erlang_runtime//erlang/erlang-}"
  else
    echo $(nos_validate \
      "$(nos_payload "config_erlang_runtime")" \
      "string" "$(default_erlang_runtime)")
  fi
}

# Condensed erlang runtime. Chop off minor versions on the erlang version
# and remove the dash
condesed_erlang_runtime() {
  version=$(expr "$(erlang_runtime)" : '\([a-z\-]*-*[0-9]*\)')
  echo "${version//[.-]/}"
}

# Provide a default erlang version.
default_erlang_runtime() {
  echo "erlang-20"
}

# Install the elixir and erlang runtime along with any dependencies.
install_runtime_packages() {
  pkgs=("$(erlang_runtime)" "$(runtime)")

  # add any client dependencies
  pkgs+=("$(query_dependencies)")

  nos_install ${pkgs[@]}
}

# Elixir is built on the erlang ecosystem, which allows for processes
# to be attached to remotely. This engine tries to make this process
# simple, and has created a handful of scripts to facilitate in this.
install_helper_scripts() {
  # generate the files
  nos_template_file \
    'bin/node-start' \
    $(nos_data_dir)/bin/node-start

  nos_template_file \
    'bin/node-attach' \
    $(nos_data_dir)/bin/node-attach

  # chmod them
  chmod +x $(nos_data_dir)/bin/node-start
  chmod +x $(nos_data_dir)/bin/node-attach
}

# Uninstall build dependencies
uninstall_build_packages() {
  # currently elixir doesn't install any build-only deps... I think
  pkgs=()

  # if pkgs isn't empty, let's uninstall what we don't need
  if [[ ${#pkgs[@]} -gt 0 ]]; then
    nos_uninstall ${pkgs[@]}
  fi
}

# compiles a list of dependencies that will need to be installed
query_dependencies() {
  deps=()

  # mysql
  if [[ `grep 'mysql\|maria' $(nos_code_dir)/mix.exs` ]]; then
    deps+=(mysql-client)
  fi
  # memcache
  if [[ `grep 'memcache' $(nos_code_dir)/mix.exs` ]]; then
    deps+=(libmemcached)
  fi
  # postgres
  if [[ `grep 'postgrex' $(nos_code_dir)/mix.exs` ]]; then
    deps+=(postgresql94-client)
  fi
  # redis
  if [[ `grep 'red\|yar\|verk' $(nos_code_dir)/mix.exs` ]]; then
    deps+=(redis)
  fi

  echo "${deps[@]}"
}

# install hex locally
install_hex() {
  cd $(nos_code_dir)
  nos_run_process "Installing hex" \
    "mix local.hex --force"
  cd - >/dev/null
}

# install rebar locally
install_rebar() {
  cd $(nos_code_dir)
  nos_run_process "Installing rebar" \
    "mix local.rebar --force"
  cd - >/dev/null
}

# fetch dependencies via mix
fetch_deps() {
  if [[ -f $(nos_code_dir)/mix.exs ]]; then
    cd $(nos_code_dir)
    nos_run_process "Fetching mix dependencies" \
      "mix deps.get --force"
    cd - >/dev/null
  fi
}

# compile dependencies via mix
compile_deps() {
  if [[ -f $(nos_code_dir)/mix.exs ]]; then
    cd $(nos_code_dir)
    nos_run_process "Compiling mix dependencies" \
      "mix deps.compile --force"
    cd - >/dev/null
  fi
}

# compile the application
compile() {
  if [[ -f $(nos_code_dir)/mix.exs ]]; then
    cd $(nos_code_dir)
    nos_run_process "Compiling app" \
      "mix compile --force"
    cd - >/dev/null
  fi
}

# persist MIX_ENV to production
persist_mix_env() {
  nos_template_file \
    'profile.d/mix_env.sh' \
    $(nos_etc_dir)/profile.d/mix_env.sh
}

# persist PORT to production
persist_port_env() {
  nos_template_file \
    'profile.d/port_env.sh' \
    $(nos_etc_dir)/profile.d/port_env.sh
}
