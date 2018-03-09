# Test the runtime selection

# source the Nos framework
. /opt/nanobox/nos/common.sh

# source the nos test helper
. util/nos.sh

# source stub.sh to stub functions and binaries
. util/stub.sh

# initialize nos
nos_init

# source the ruby libraries
. ${engine_lib_dir}/elixir.sh

setup() {
  rm -rf /tmp/code
  mkdir -p /tmp/code
  nos_reset_payload
}

@test "Use default versions of erlang and elixir" {

      nos_init "$(cat <<-END
{
  "config": {
  }
}
END
)"

  runtime=$(runtime)
  erlang_runtime=$(erlang_runtime)

  [ "$runtime" = "erlang20-elixir-1.5" ]
  [ "$erlang_runtime" = "erlang-20" ]
}

@test "Use default version of erlang and specify version elixir" {

      nos_init "$(cat <<-END
{
  "config": {
    "runtime": "elixir-1.6"
  }
}
END
)"

  runtime=$(runtime)
  erlang_runtime=$(erlang_runtime)

  [ "$runtime" = "erlang20-elixir-1.6" ]
  [ "$erlang_runtime" = "erlang-20" ]
}

@test "Use specified version of erlang and default elixir" {

      nos_init "$(cat <<-END
{
  "config": {
    "erlang_runtime": "erlang-19"
  }
}
END
)"

  runtime=$(runtime)
  erlang_runtime=$(erlang_runtime)

  [ "$runtime" = "erlang19-elixir-1.5" ]
  [ "$erlang_runtime" = "erlang-19" ]
}

@test "Extract version of erlang from elixir runtime if specified" {

      nos_init "$(cat <<-END
{
  "config": {
    "runtime": "erlang19-elixir-1.6"
  }
}
END
)"

  runtime=$(runtime)
  erlang_runtime=$(erlang_runtime)

  [ "$runtime" = "erlang19-elixir-1.6" ]
  [ "$erlang_runtime" = "erlang-19" ]
}

@test "generate elixir runtime from specific erlang and elixir runtimes in the boxfile" {

      nos_init "$(cat <<-END
{
  "config": {
    "runtime": "elixir-1.6",
    "erlang_runtime": "erlang-19"
  }
}
END
)"

  runtime=$(runtime)
  erlang_runtime=$(erlang_runtime)

  [ "$runtime" = "erlang19-elixir-1.6" ]
  [ "$erlang_runtime" = "erlang-19" ]
}
