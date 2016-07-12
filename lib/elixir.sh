# -*- mode: bash; tab-width: 2; -*-
# vim: ts=2 sw=2 ft=bash noet

nodejs_runtime() {
	if [[ -f $(nos_code_dir)/package.json ]]; then
		echo $(nos_validate "$(nos_payload 'config_runtime')" "string" "nodejs")
	fi
}

runtime() {
	echo $(nos_validate "$(nos_payload 'config_runtime')" "string" "elixir")
}

install_runtime() {
	nos_install $(runtime) $(nodejs_runtime)
}

mix_cache_dir() {
  [[ ! -f $(nos_code_dir)/.mix ]] && nos_run_process "make mix cache dir" "mkdir -p $(nos_code_dir)/.mix"
  [[ ! -s ${HOME}/.mix ]] && nos_run_process "link mix cache dir" "ln -s $(nos_code_dir)/.mix ${HOME}/.mix"
  [[ ! -f $(nos_code_dir)/.hex ]] && nos_run_process "make hex cache dir" "mkdir -p $(nos_code_dir)/.hex"
  [[ ! -s ${HOME}/.hex ]] && nos_run_process "link hex cache dir" "ln -s $(nos_code_dir)/.hex ${HOME}/.hex"
}

create_profile_links() {
  mkdir -p $(nos_data_dir)/etc/profile.d/
  nos_template \
    "links.sh.mustache" \
    "$(nos_data_dir)/etc/profile.d/links.sh" \
    "$(links_payload)"
}

links_payload() {
  cat <<-END
{
  "nos_app_dir": "${nos_app_dir}"
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

npm_install() {
	if [[ -f $(nos_code_dir)/package.json ]]; then
		(cd $(nos_code_dir); nos_run_process "npm install" "npm install")
	fi
}

# Copy the compiled jars into the app directory to run live
publish_release() {
	nos_print_bullet "Moving build into live code directory..."
	rsync -a $(nos_code_dir)/ $(nos_app_dir)
}