# -*- mode: bash; tab-width: 2; -*-
# vim: ts=2 sw=2 ft=bash noet

if [ ! -s ${HOME}/.mix ]; then
  ln -sf {{data_dir}}/var/mix ${HOME}/.mix
fi

if [ ! -s ${HOME}/.hex ]; then
  ln -sf {{data_dir}}/var/hex ${HOME}/.hex
fi