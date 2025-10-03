# Supported Commands

`RcloneInterface.jl` provides high-level Julia wrappers for the most commonly used `rclone` operations. All functions support filtering (`exclude`, `include`, `max_age`, etc.), verbosity control, and an `extra_flags` escape hatch for advanced options.

| Command | Function | Description |
|--------|--------|-------------|
| **Copy** | `rclone_copy(src, dst; ...)` | Copy files from source to destination (non-destructive). |
| **Sync** | `rclone_sync(src, dst; ...)` | Make destination **identical** to source (**can delete files**). |
| **Move** | `rclone_move(src, dst; ...)` | Move files and delete from source after transfer. |
| **List** | `rclone_ls(path; ...)` | List files with size (like `rclone ls`). |
| **Delete** | `rclone_delete(path; ...)` | Delete files matching filters (**use `dry_run=true`**). |
| **Check** | `rclone_check(src, dst; ...)` | Verify file integrity via size/hash. |
| **Dedupe** | `rclone_dedupe(path; ...)` | Find and resolve duplicate files. |
| **Size** | `rclone_size(path; ...)` | Get total object count and size summary. |
| **Tree** | `rclone_tree(path; ...)` | Print directory hierarchy. |
| **Mount** | `rclone_mount(remote, local; ...)` | Mount remote as local filesystem (**blocks**). |
| **Version** | `rclone_version()` | Show `rclone` version info. |
| **Help** | `rclone_help(topic="sync")` | Get help for any command or backend. |

All functions:
- Accept **local paths** (`"local:/data"`) or **configured remotes** (`"gdrive:backup"`).
- Default to **safe mode** where applicable (`dry_run=true` for destructive ops).
- Return command output as a **string** for parsing or logging.
```
