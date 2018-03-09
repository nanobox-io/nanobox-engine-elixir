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

@test "Use default PostgreSQL client package" {

      nos_init "$(cat <<-END
{
  "config": {
  }
}
END
)"

  postgresql_version=$(postgresql_version)

  [ "$postgresql_version" = "96" ]
}

@test "Specify what version of PostgreSQL client to use" {

      nos_init "$(cat <<-END
{
  "config": {
    "postgresql_client_version": "9.5"
  }
}
END
)"

  postgresql_version=$(postgresql_version)

  [ "$postgresql_version" = "95" ]
}

@test "Detect PostgreSQL version from the boxfile" {

  nos_init "$(cat <<-END
{
  "code_dir": "/tmp/code"
}
END
)"

  cat > /tmp/code/boxfile.yml <<-END
data.db:
    image: nanobox/postgresql:9.5
END

  postgresql_version=$(postgresql_version)

  [ "$postgresql_version" = "95" ]
}
