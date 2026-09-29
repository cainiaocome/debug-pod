# Debug Pod

Debug Pod is a portable Ubuntu toolbox for inspecting applications, networks,
filesystems, and data without installing a large collection of utilities on
the host. The published image supports Linux AMD64 and ARM64.

The `debug-here` wrapper opens Bash in the current directory, mounted at
`/app/<directory-name>`. The shell uses the invoking host user's numeric UID
and GID, so files created in the mounted directory retain the correct host
ownership.

## Quick start

Docker must be installed and connected to a local Linux Docker daemon.
`debug-here` intentionally does not translate bind-mount paths for a remote
daemon.

Clone the repository and install the wrapper under `~/.local/bin`:

```console
git clone https://github.com/cainiaocome/debug-pod.git
cd debug-pod
make install
make pull
```

Ensure `~/.local/bin` is in `PATH`, then run the wrapper from any directory:

```console
cd ~/projects/example
debug-here
```

This starts the published `ghcr.io/cainiaocome/debug-pod:main` image with the
following mapping and working directory:

```text
~/projects/example -> /app/example
```

The container is removed when the shell exits. Changes inside the bind-mounted
project remain on the host; other container changes are temporary.

## Runtime user

The wrapper passes the host UID, GID, username, and group name to the image's
entrypoint. If the UID already exists in the image, that account is reused. For
example, host UID 1000 uses Ubuntu's built-in `ubuntu` account. If it does not
exist, the entrypoint creates an account for the session.

Linux records ownership numerically, so a file created by container user
`ubuntu` with UID 1000 belongs to a host user such as `jlz` with the same UID.

Some debugging work genuinely requires root. Enable it explicitly:

```console
DEBUG_HERE_ROOT=1 debug-here
```

Additional Docker capabilities may still be required for operations such as
packet capture, changing network interfaces, or mounting filesystems. The
wrapper deliberately starts with Docker's default capability set.

## Image tags

Every GitHub Actions build publishes two independent tags:

- The source branch name, such as `main`.
- The seven-character commit hash, such as `08b626d`.

Select a different image or immutable commit tag with `DEBUG_HERE_IMAGE`:

```console
DEBUG_HERE_IMAGE=ghcr.io/cainiaocome/debug-pod:08b626d debug-here
```

Branch names are normalized into valid container tags by the GitHub metadata
action.

## Make targets

Run `make help` to list the available operations:

| Target | Purpose |
| --- | --- |
| `make pull` | Pull the published `main` image |
| `make build` | Build `debug-pod:local`, refreshing the base and package layers |
| `make shell` | Open the current directory with the published image |
| `make install` | Install `debug-here` under `~/.local/bin` |

Variables can override the defaults:

```console
make pull TAG=08b626d
make build LOCAL_IMAGE=debug-pod:test
make install PREFIX=/usr/local
```

## Included tools

The image combines Ubuntu packages for system and network diagnostics with
Homebrew formulae for portable, fast-moving command-line applications. Notable
tools include:

- `bat`, `curl`, `fx`, `jq`, `jless`, `ripgrep`, `wget`, and `wgcf`
- GCC, Go, Node.js, TypeScript, and general build tools
- Git, OpenSSH, rsync, socat, and netcat
- `ip`, `dig`, `mtr`, `ping`, `tcpdump`, and traceroute
- IPython, JupyterLab, Python, and build tools
- htop, lsof, strace, tmux, tree, Vim, and Nano

The complete source-of-truth inventory is in [tools.md](tools.md). Add or
remove tools there and update the corresponding Dockerfile install list in the
same change.

## Published builds

GitHub Actions builds and pushes the image on every branch push, on manual
dispatch, and weekly on Monday at 03:17 UTC. Weekly builds pull the current
Ubuntu base and install the latest stable apt packages and Homebrew formulae.

The workflow publishes a multi-platform manifest for `linux/amd64` and
`linux/arm64` and attaches build provenance to the registry image.

## License

Debug Pod is available under the [MIT License](LICENSE).
