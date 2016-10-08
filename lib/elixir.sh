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

# create cache directories and link mix to them
setup_mix() {
	if [[ ! -f $(nos_code_dir)/.mix ]]; then
		mkdir -p $(nos_code_dir)/.mix
	fi
	
	if [[ ! -s ${HOME}/.mix ]]; then
		ln -s $(nos_code_dir)/.mix ${HOME}/.mix
	fi
	
	if [[ ! -f $(nos_code_dir)/.hex ]]; then
		mkdir -p $(nos_code_dir)/.hex
	fi
	
	if [[ ! -s ${HOME}/.hex ]]; then
		ln -s $(nos_code_dir)/.hex ${HOME}/.hex
	fi
}

create_profile_links() {
  mkdir -p $(nos_data_dir)/etc/profile.d/
  nos_template \
    "profile.d/elixir.sh" \
    "$(nos_data_dir)/etc/profile.d/elixir.sh" \
    "$(links_payload)"
}

links_payload() {
  cat <<-END
{
  code_dir: "$(nos_code_dir)"
}
END
}

mix_local_hex() {
	(cd $(nos_code_dir); nos_run_process "mix local.hex" "mix local.hex --force")
}

mix_local_rebar() {
	(cd $(nos_code_dir); nos_run_process "mix local.rebar" "mix local.rebar --force")
}

get_deps() {
	(cd $(nos_code_dir); nos_run_process "mix deps.get" "mix deps.get --force")
}

compile_deps() {
	(cd $(nos_code_dir); nos_run_process "mix deps.compile" "mix deps.compile --force")
}

compile() {
	(cd $(nos_code_dir); nos_run_process "mix compile" "mix compile --force")
}
