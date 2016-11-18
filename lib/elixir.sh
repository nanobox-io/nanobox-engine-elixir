# -*- mode: bash; tab-width: 2; -*-
# vim: ts=2 sw=2 ft=bash noet

# Copy the compiled jars into the app directory to run live
publish_release() {
	nos_print_bullet "Moving build into live app directory..."
	rsync -a $(nos_code_dir)/ $(nos_app_dir)
}

# Determine the elixir runtime to install. This will first check
# within the boxfile.yml, then will rely on default_runtime to
# provide a sensible default
runtime() {
  echo $(nos_validate \
    "$(nos_payload "config_runtime")" \
    "string" "$(default_runtime)")
}

# Provide a default elixir version.
default_runtime() {
  echo "elixir-1.3"
}

# Install the elixir and erlang runtime along with any dependencies.
install_runtime_packages() {
  pkgs=("$(runtime)")
  
  # add any client dependencies
  pkgs+=("$(query_dependencies)")

  nos_install ${pkgs[@]}
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
