# Elixir

This is an Elixir engine used to launch Elixir apps on [Nanobox](http://nanobox.io).

## Usage
To use the Elixir engine, specify `elixir` as your `engine` in your boxfile.yml.

```yaml
run.config:
  engine: elixir
```

## Build Process
When preparing your runtime, this engine compiles code by doing the following:

```
> mix local.hex --force
> mix local.rebar --force
> mix deps.get --force
> mix deps.compile --force
> mix compile --force
```

## Helper Scripts
This engine provides helper scripts to make managing your Elixir application easier.

### node-attach
The `node-attach` helper facilitates connecting to an Elixir node that was started with `elixir-start`.

```bash
node-attach
```

### node-start
The `node-start` helper ensures that nodes are started with credentials sufficient to cluster and attach to after they are running.

```bash
# Examples
node-start mix phoenix.server
node-start mix run —no-halt
```

## Configuration Options
This engine exposes configuration options through the [boxfile.yml](http://docs.nanobox.io/boxfile/), a yaml config file used to provision and configure your app's infrastructure when using Nanobox. This engine makes the following options available.

#### Overview of Boxfile Configuration Options
```yaml
run.config:
  engine.config:
    # Elixir Settings
    runtime: elixir-1.4
```

---

#### runtime
Specifies which Elixir runtime to use. The following runtimes are available:

- elixir-1.0
- elixir-1.1
- elixir-1.3
- elixir-1.4 *(default)*
- elixir-1.5

```yaml
run.config:
  engine.config:
    runtime: elixir-1.5
```

---

#### erlang_runtime
Specifies which Erlang runtime to use. The following runtimes are available:

- erlang-18.0
- erlang-18.1
- erlang-18.3
- erlang-19.0
- erlang-19.2
- erlang-19.3 *(default)*
- erlang-20.0

```yaml
run.config:
  engine.config:
    erlang_runtime: erlang-20.0
```

## Help & Support
This is an Elixir engine provided by [Nanobox](http://nanobox.io). If you need help with this engine, you can reach out to us in the [Nanobox Slack channel](https://nanoboxio.slack.com) (access can be requested at [slack.nanoapp.io](http://slack.nanoapp.io)). If you are running into an issue with the engine, feel free to [create a new issue on this project](https://github.com/nanobox-io/nanobox-engine-elixir/issues/new).
