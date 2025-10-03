
"""
    rclone_sync(src::AbstractString, dest::AbstractString; kwargs...)

Synchronize the source to the destination, making the destination **identical** to the source.
This may **delete files** in the destination that are not present in the source.

> ⚠️ **Warning**: This command can cause data loss. Always test with `dry_run=true`.

# Arguments
- `src`: Source path (e.g., `"local:/data"` or `"remote:bucket/dir"`)
- `dest`: Destination path

# Keyword arguments (common & sync-specific flags)
## Safety & Testing
- `dry_run::Bool = false`        → `--dry-run`
- `interactive::Bool = false`    → `--interactive` (`-i`)

## Core behavior
- `checksum::Bool = false`       → `-c`, use checksum + size
- `update::Bool = false`         → `-u`, skip files newer on destination
- `ignore_existing::Bool = false`→ skip files that already exist
- `size_only::Bool = false`      → skip based on size only
- `ignore_times::Bool = false`   → `-I`, transfer all unconditionally
- `metadata::Bool = false`       → `-M`, preserve metadata

## Deletion control
- `max_delete::Int = -1`         → `--max-delete N` (default: unlimited)
- `delete_excluded::Bool = false`→ `--delete-excluded`
- `ignore_errors::Bool = false`  → delete even if I/O errors occur

## Performance & filtering
- `no_traverse::Bool = false`    → `--no-traverse`
- `max_age::Union{Nothing,String} = nothing`
- `min_age::Union{Nothing,String} = nothing`
- `max_size::Union{Nothing,String} = nothing`
- `min_size::Union{Nothing,String} = nothing`
- `exclude::Vector{String} = String[]`
- `include::Vector{String} = String[]`

## Logging & reporting (output to file or stdout)
- `combined::Union{Nothing,String} = nothing`      → `--combined FILE`
- `differ::Union{Nothing,String} = nothing`        → `--differ FILE`
- `missing_on_dst::Union{Nothing,String} = nothing`
- `missing_on_src::Union{Nothing,String} = nothing`
- `error_log::Union{Nothing,String} = nothing`     → `--error FILE`

## Other
- `verbose::Int = 0`             → `-v`, `-vv`, etc.
- `progress::Bool = false`       → `-P`
- `create_empty_src_dirs::Bool = false`
- `track_renames::Bool = false`  → enable rename detection
- `extra_flags::Vector{String} = String[]`

# Example
```julia
rclone_sync("local:/photos", "gdrive:backup/photos", dry_run=true, verbose=1)
rclone_sync("s3:mybucket", "b2:archive", max_delete=100, checksum=true)
```
"""
function rclone_sync(
    src::AbstractString,
    dest::AbstractString;
    # Safety
    dry_run::Bool = false,
    interactive::Bool = false,

    # Core copy/sync options
    checksum::Bool = false,
    update::Bool = false,
    ignore_existing::Bool = false,
    size_only::Bool = false,
    ignore_times::Bool = false,
    metadata::Bool = false,

    # Deletion control
    max_delete::Int = -1,
    delete_excluded::Bool = false,
    ignore_errors::Bool = false,

    # Filtering
    no_traverse::Bool = false,
    max_age::Union{Nothing, String} = nothing,
    min_age::Union{Nothing, String} = nothing,
    max_size::Union{Nothing, String} = nothing,
    min_size::Union{Nothing, String} = nothing,
    exclude::Vector{String} = String[],
    include::Vector{String} = String[],

    # Logging/reporting
    combined::Union{Nothing, String} = nothing,
    differ::Union{Nothing, String} = nothing,
    missing_on_dst::Union{Nothing, String} = nothing,
    missing_on_src::Union{Nothing, String} = nothing,
    error_log::Union{Nothing, String} = nothing,

    # Misc
    verbose::Int = 0,
    progress::Bool = false,
    create_empty_src_dirs::Bool = false,
    track_renames::Bool = false,

    # Escape hatch
    extra_flags::Vector{String} = String[]
)
    cmd = ["sync", src, dest]

    # Safety flags
    dry_run && push!(cmd, "--dry-run")
    interactive && push!(cmd, "--interactive")

    # Core flags
    checksum && push!(cmd, "--checksum")
    update && push!(cmd, "--update")
    ignore_existing && push!(cmd, "--ignore-existing")
    size_only && push!(cmd, "--size-only")
    ignore_times && push!(cmd, "--ignore-times")
    metadata && push!(cmd, "--metadata")

    # Deletion control
    if max_delete != -1
        push!(cmd, "--max-delete")
        push!(cmd, string(max_delete))
    end
    delete_excluded && push!(cmd, "--delete-excluded")
    ignore_errors && push!(cmd, "--ignore-errors")

    # Performance
    no_traverse && push!(cmd, "--no-traverse")

    # Age/size filters
    if max_age !== nothing
        push!(cmd, "--max-age"); push!(cmd, max_age)
    end
    if min_age !== nothing
        push!(cmd, "--min-age"); push!(cmd, min_age)
    end
    if max_size !== nothing
        push!(cmd, "--max-size"); push!(cmd, max_size)
    end
    if min_size !== nothing
        push!(cmd, "--min-size"); push!(cmd, min_size)
    end

    # Include/exclude
    for pat in exclude
        push!(cmd, "--exclude"); push!(cmd, pat)
    end
    for pat in include
        push!(cmd, "--include"); push!(cmd, pat)
    end

    # Logging/reporting
    if combined !== nothing
        push!(cmd, "--combined"); push!(cmd, combined)
    end
    if differ !== nothing
        push!(cmd, "--differ"); push!(cmd, differ)
    end
    if missing_on_dst !== nothing
        push!(cmd, "--missing-on-dst"); push!(cmd, missing_on_dst)
    end
    if missing_on_src !== nothing
        push!(cmd, "--missing-on-src"); push!(cmd, missing_on_src)
    end
    if error_log !== nothing
        push!(cmd, "--error"); push!(cmd, error_log)
    end

    # Misc
    verbose > 0 && append!(cmd, ["-" * repeat("v", verbose)])
    progress && push!(cmd, "--progress")
    create_empty_src_dirs && push!(cmd, "--create-empty-src-dirs")
    track_renames && push!(cmd, "--track-renames")

    # Extra flags
    append!(cmd, extra_flags)

    return rclone_exe(cmd...)
end