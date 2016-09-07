# Elixir

This is an Elixir engine used to launch Elixir apps on [Nanobox](http://nanobox.io).

## Usage
To use the Elixir engine, specify `elixir` as your `engine` in your boxfile.yml.

```yaml
code.build:
  engine: elixir
```

## Build Process
When [running a build](https://docs.nanboox.io/cli/build/), this engine compiles code by doing the following:

```
> mix local.hex --force
> mix local.rebar --force
> mix deps.get --force
> mix deps.compile --force
> mix compile --force
```

## Configuration Options
This engine exposes configuration options through the [boxfile.yml](http://docs.nanobox.io/boxfile/), a yaml config file used to provision and configure your app's infrastructure when using Nanobox. This engine makes the following options available.

#### Overview of Boxfile Configuration Options
```yaml
code.build:
  config:
    # Elixir Settings
    runtime: elixir-1.3

    # Node.js Settings
    nodejs_runtime: nodejs-4.4
```

##### Quick Links
[Elixir Settings](#elixir-settings)  
[Node.js Settings](#nodejs-settings)

---

### Elixir Settings
The following setting allows you to define your Elixir runtime environment.

---

#### runtime
Specifies which Elixir runtime to use. The following runtimes are available:

- elixir-1.0
- elixir-1.1
- elixir-1.3

```yaml
code.build:
  config:
    runtime: elixir-1.3
```

---

### Node.js Runtime Settings
Many applications utilize Javascript tools in some way. This engine allows you to specify which Node.js runtime you'd like to use.

---

#### nodejs_runtime
Specifies which Node.js runtime and version to use. You can view the available Node.js runtimes in the [Node.js engine documentation](https://github.com/nanobox-io/nanobox-engine-nodejs#runtime).

```yaml
code.build:
  config:
    nodejs_runtime: nodejs-4.4
```

---

## Help & Support
This is an Elixir engine provided by [Nanobox](http://nanobox.io). If you need help with this engine, you can reach out to us in the [#nanobox IRC channel](http://webchat.freenode.net/?channels=nanobox). If you are running into an issue with the engine, feel free to [create a new issue on this project](https://github.com/nanobox-io/nanobox-engine-elixir/issues/new).
