echo running tests for elixir
UUID=$(cat /proc/sys/kernel/random/uuid)

pass "Unable to start the $VERSION container" docker run --privileged=true -d --name $UUID nanobox/build-elixir sleep 365d

defer docker kill $UUID

pass "Failed to run cleanup script" docker exec $UUID bash -c "cd /opt/engines/elixir/bin; ./cleanup '$(payload default-cleanup)'"