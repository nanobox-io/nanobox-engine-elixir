# -*- mode: bash; tab-width: 2; -*-
# vim: ts=2 sw=2 ft=bash noet

# source nodejs
. ${engine_lib_dir}/nodejs.sh

runtime() {
	echo $(nos_validate "$(nos_payload 'config_runtime')" "string" "elixir")
}

install_runtime() {
  pkgs=($(runtime))

  if [[ "$(is_nodejs_required)" = "true" ]]; then
    pkgs+=("$(nodejs_dependencies)")
  fi
  
  nos_install ${pkgs[@]}
}

# Uninstall build dependencies
uninstall_build_packages() {
  # currently ruby doesn't install any build-only deps... I think
  pkgs=()

  # if nodejs is required, let's fetch any node build deps
  if [[ "$(is_nodejs_required)" = "true" ]]; then
    pkgs+=("$(nodejs_build_dependencies)")
  fi

  # if pkgs isn't empty, let's uninstall what we don't need
  if [[ ${#pkgs[@]} -gt 0 ]]; then
    nos_uninstall ${pkgs[@]}
  fi
}

mix_dir() {
  [[ ! -f $(nos_data_dir)/var/mix ]] && nos_run_process "make mix cache dir" "mkdir -p $(nos_data_dir)/var/mix"
  [[ ! -s ${HOME}/.mix ]] && nos_run_process "link mix cache dir" "ln -s $(nos_data_dir)/var/mix ${HOME}/.mix"
  [[ ! -f $(nos_data_dir)/var/hex ]] && nos_run_process "make hex cache dir" "mkdir -p $(nos_data_dir)/var/hex"
  [[ ! -s ${HOME}/.hex ]] && nos_run_process "link hex cache dir" "ln -s $(nos_data_dir)/var/hex ${HOME}/.hex"
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
  data_dir: "$(nos_data_dir)"
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

# Copy the compiled jars into the app directory to run live
publish_release() {
	nos_print_bullet "Moving build into live code directory..."
	rsync -a $(nos_code_dir)/ $(nos_app_dir)
}

copy_cached_files() {
  if [ -d $(nos_cache_dir)/mix ]; then
    rsync -a $(nos_cache_dir)/mix/ $(nos_data_dir)/var/mix
  fi
  if [ -d $(nos_cache_dir)/hex ]; then
    rsync -a $(nos_cache_dir)/hex/ $(nos_data_dir)/var/hex
  fi
}

save_cached_files() {
  if [ -d $(nos_data_dir)/var/mix ]; then
    rsync -a --delete $(nos_data_dir)/var/mix/ $(nos_cache_dir)/mix
  fi
  if [ -d $(nos_data_dir)/var/hex ]; then
    rsync -a --delete $(nos_data_dir)/var/hex/ $(nos_cache_dir)/hex
  fi
}