echo running tests for elixir
UUID=$(cat /proc/sys/kernel/random/uuid)

pass "Unable to start the $VERSION container" docker run --privileged=true -d --name $UUID nanobox/build-elixir sleep 365d

defer docker kill $UUID

pass "Unable to create code folder" docker exec $UUID mkdir -p /opt/code

# fail "Detected something when there shouldn't be anything" docker exec $UUID bash -c "cd /opt/engines/elixir/bin; ./sniff /opt/code"

pass "Failed to detect Elixir" docker exec $UUID bash -c "cd /opt/engines/elixir/bin; ./sniff /opt/code"