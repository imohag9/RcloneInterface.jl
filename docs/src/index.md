# RcloneInterface.jl

A Julia-native interface to [**Rclone**](https://rclone.org) — the powerful command-line tool for managing files across cloud storage, local filesystems, and enterprise services.

This package wraps `rclone` commands in idiomatic Julia functions with keyword arguments, automatic binary management (via `Rclone_jll`), and safety defaults like `dry_run=true`. No need to install `rclone` separately.

> ⚠️ You must configure remotes (e.g., Google Drive, S3) using `rclone config` **outside Julia** before using them. Local paths work immediately.

## Installation

```julia
using Pkg
Pkg.add("RcloneInterface")
```

## Quick Example

```julia
using RcloneInterface

# List files
rclone_ls("local:/home/user")

# Safely preview a sync
rclone_sync("local:/photos", "gdrive:backup", dry_run=true)
```