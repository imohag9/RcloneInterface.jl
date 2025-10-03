# RcloneInterface

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://imohag9.github.io/RcloneInterface.jl/dev/)
[![Build Status](https://github.com/imohag9/RcloneInterface.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/imohag9/RcloneInterface.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

> **A safe, high-level Julia interface to [`rclone`](https://rclone.org)** — the Swiss Army knife for cloud storage and file synchronization.

`RcloneInterface.jl` wraps the powerful `rclone` CLI tool in idiomatic Julia functions with **keyword arguments**, **automatic binary management** (via `Rclone_jll`), and **built-in safety defaults** (like `dry_run=true`). No need to install `rclone` separately—everything runs out of the box!



## ✨ Features

- **Full coverage** of core `rclone` commands: `copy`, `sync`, `move`, `ls`, `delete`, `check`, `dedupe`, `size`, `tree`, `mount`, and more.
- **Type-safe keyword arguments** that map directly to `rclone` flags (e.g., `max_age="7d"`, `checksum=true`).
- **No external dependencies**: Uses the official `rclone` binary via `Rclone_jll`.
- **Safety-first defaults**: Most destructive operations support `dry_run=true` by default.
- **Escape hatch**: Pass arbitrary flags via `extra_flags=["--custom-opt", "value"]`.
- **Robust output handling**: Functions return command output as strings for parsing or logging.
- **Local & remote agnostic**: Works with local paths (`"/data"`) or remotes (`"gdrive:backup"`).



## 📦 Installation

```julia
using Pkg
Pkg.add("RcloneInterface")
```

 ⚠️ **Note**: You must have `rclone` [configured](https://rclone.org/docs/#config-file) (e.g., via `rclone config`) **outside Julia** before using remote backends. Local paths work immediately.



## 🚀 Quick Start

```julia
using RcloneInterface

# List files (recursively)
output = rclone_ls("local:/home/user/documents")
println(output)
#> 1024 report.pdf
#> 2048 notes.txt

# Safely preview a sync (no files changed)
rclone_sync("local:/photos", "gdrive:backup", dry_run=true, verbose=1)

# Copy with filtering
rclone_copy(
    "s3:bucket/logs",
    "local:/archive",
    max_age="30d",
    exclude=["*.tmp"],
    checksum=true
)

# Check integrity
mismatches = rclone_check("local:/data", "dropbox:mirror", size_only=true)
if !isempty(strip(mismatches))
    @warn "Integrity check failed!" mismatches
end

# Get human-readable size summary
println(rclone_size("onedrive:projects"))
#> Total objects: 142
#> Total size: 2.3 GiB (2469384192 Bytes)
```

## 🔒 Safety & Best Practices

- **Always test destructive operations** (`sync`, `move`, `delete`) with `dry_run=true`.
- Use `max_delete=N` in `rclone_sync` to limit accidental deletions.
- Prefer `size_only=true` or `checksum=true` for reliable comparisons.
- Avoid `--interactive` in scripts—it blocks execution.



## 🧰 Available Commands

| Function | Purpose |
|--------|--------|
| `rclone_copy(src, dst; ...)` | Copy files (non-destructive) |
| `rclone_sync(src, dst; ...)` | Make `dst` identical to `src` (**can delete!**) |
| `rclone_move(src, dst; ...)` | Move files (deletes from source) |
| `rclone_ls(path; ...)` | List files with size |
| `rclone_delete(path; ...)` | Delete files (**use `dry_run`!**) |
| `rclone_check(src, dst; ...)` | Verify file integrity |
| `rclone_dedupe(path; ...)` | Resolve duplicates |
| `rclone_size(path; ...)` | Get total size & object count |
| `rclone_tree(path; ...)` | Print directory tree |
| `rclone_mount(remote, local; ...)` | Mount remote as local filesystem (**blocks**) |
| `rclone_version()` | Show `rclone` version |
| `rclone_help(topic="sync")` | Get command help |

> 💡 All functions accept common filtering options: `exclude`, `include`, `max_age`, `min_size`, etc.


See the [rclone documentation](https://rclone.org/commands/) for a complete list of commands and options.

**Note**: This package is **not affiliated** with the official `rclone` project. It is a community-driven Julia wrapper.


## 🧪 Testing & Reliability

- Full **integration tests** using local filesystems (no remote credentials needed).

- Built on the same pattern as [`FFMPEG.jl`](https://github.com/JuliaIO/FFMPEG.jl)—a proven design for CLI wrappers.




## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.