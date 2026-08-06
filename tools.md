# Tool manifest

This file is the source of truth for software included in the image. When a
tool is added or removed here, update the matching install list in the
`Dockerfile` in the same change.

Use Homebrew for portable, fast-moving applications when a stable Linux bottle
is available. Use apt for bootstrap packages and tools coupled to Ubuntu,
the kernel, networking, or filesystems. Weekly CI builds use `--pull`, apt's
current Ubuntu 24.04 packages, and Homebrew's current stable formulae. CI also
passes a unique `TOOL_REFRESH` build argument so a package-install layer can
never be reused from an older run.

## Homebrew tools

| Formula | Commands | Purpose |
| --- | --- | --- |
| `bat` | `bat` | Syntax-highlighted file viewer |
| `ipython` | `ipython` | Enhanced interactive Python shell |
| `jq` | `jq` | JSON query and transformation |
| `jupyterlab` | `jupyter`, `jupyter-lab` | Interactive Python notebooks |
| `ripgrep` | `rg` | Fast recursive text search |
| `tmux` | `tmux` | Terminal multiplexer |
| `tree` | `tree` | Directory tree display |
| `wget` | `wget` | HTTP/FTP downloader |
| `wgcf` | `wgcf` | Generate Cloudflare WARP WireGuard profiles |

## Ubuntu tools

| Package | Important commands or purpose |
| --- | --- |
| `apt-file` | Search package contents |
| `bash-completion` | Interactive shell completions |
| `build-essential` | C/C++ compiler and build basics required by Homebrew |
| `ca-certificates` | TLS trust store |
| `curl` | Bootstrap downloader and HTTP client |
| `dnsutils` | `dig`, `nslookup`, and `nsupdate` |
| `file` | File type inspection |
| `git` | Source control and Homebrew bootstrap dependency |
| `gosu` | Drop from the entrypoint's root account to the invoking host UID/GID |
| `htop` | Interactive process viewer |
| `iproute2` | `ip`, `ss`, and traffic-control utilities |
| `iputils-ping` | `ping` |
| `less` | Terminal pager |
| `locales` | UTF-8 locale support |
| `lsof` | Open-file and socket inspection |
| `man-db` | Manual-page reader |
| `mtr-tiny` | Combined ping/traceroute diagnostics |
| `nano` | Simple terminal editor |
| `netcat-openbsd` | `nc` TCP/UDP client and listener |
| `nfs-common` | NFS client utilities |
| `openssh-client` | SSH, SCP, and SFTP clients |
| `procps` | `ps`, `top`, `free`, and related process tools |
| `rsync` | Incremental file transfer |
| `socat` | Bidirectional socket relay |
| `strace` | System-call tracing |
| `tcpdump` | Packet capture |
| `telnet` | Basic interactive TCP client |
| `traceroute` | Network path tracing |
| `unzip` | ZIP extraction |
| `vim` | Terminal editor |
| `zip` | ZIP archive creation |

## Image-provided shell

Ubuntu supplies Bash and the standard GNU userland. Homebrew's IPython and
JupyterLab formulae bring their supported Python runtime as a dependency. The
image provides both `python3`/`pip3` and compatibility aliases named
`python`/`pip`.

Some diagnostics need extra container privileges. For example, packet capture,
network-interface changes, and mounting NFS may require `--cap-add` flags or
`--privileged`, depending on the Docker host's security policy.

## Runtime user

`debug-here` passes the invoking user's numeric UID and GID into the container.
The entrypoint reuses an image account when that UID already exists (for
example, host UID 1000 uses Ubuntu's `ubuntu` account). Otherwise it creates a
temporary account with the requested IDs. Files written to the bind mount are
therefore owned by the invoking host user.

Set `DEBUG_HERE_ROOT=1` when a debugging session must run as root:

```console
DEBUG_HERE_ROOT=1 debug-here
```
