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
  # memcache
  # postgres
  # redis
  
  echo "${deps[@]}"
}

# ensure MIX_HOME and HEX_HOME are set properly
prep_env() {
	mix_home="$(nos_code_dir)/.mix"
	hex_home="$(nos_code_dir)/.hex"
	nos_set_evar      'MIX_HOME' $mix_home
	nos_persist_evar  'MIX_HOME' $mix_home
	nos_set_evar      'HEX_HOME' $hex_home
	nos_persist_evar  'HEX_HOME' $hex_home
}

# install hex locally
install_hex() {
	if [[ -f $(nos_code_dir)/mix.exs ]]; then
		cd $(nos_code_dir)
		nos_run_process "Installing hex" \
			"mix local.hex --force"
		cd - >/dev/null
	fi
}

# install rebar locally
install_rebar() {
	if [[ -f $(nos_code_dir)/mix.exs ]]; then
		cd $(nos_code_dir)
		nos_run_process "Installing rebar" \
			"mix local.rebar --force"
		cd - >/dev/null
	fi
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
