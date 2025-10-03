# src/commands/move.jl

"""
    rclone_move(src::AbstractString, dest::AbstractString; kwargs...)

Move files from source to destination. After a successful move, files are deleted from the source.

> ⚠️ **Warning**: This can cause data loss. Always test with `dry_run=true`.

# Arguments
- `src`: Source path
- `dest`: Destination path

# Keyword arguments
## Safety & testing
- `dry_run::Bool = false`
- `interactive::Bool = false`

## Behavior
- `checksum::Bool = false`
- `update::Bool = false`
- `ignore_existing::Bool = false`
- `size_only::Bool = false`
- `ignore_times::Bool = false`
- `metadata::Bool = false`

## Source cleanup
- `delete_empty_src_dirs::Bool = false` → `--delete-empty-src-dirs`
- `create_empty_src_dirs::Bool = false` → `--create-empty-src-dirs`

## Filtering
- `max_age`, `min_age`, `max_size`, `min_size`
- `exclude::Vector{String} = String[]`
- `include::Vector{String} = String[]`
- `no_traverse::Bool = false`

## Output & control
- `verbose::Int = 0`
- `progress::Bool = false`
- `extra_flags::Vector{String} = String[]`

# Example
```julia
rclone_move("local:/tmp/old", "archive:old", dry_run=true)
rclone_move("s3:bucket/temp", "gcs:archive", delete_empty_src_dirs=true, checksum=true)
```
"""
function rclone_move(
    src::AbstractString,
    dest::AbstractString;
    # Safety
    dry_run::Bool = false,
    interactive::Bool = false,

    # Core copy/move options
    checksum::Bool = false,
    update::Bool = false,
    ignore_existing::Bool = false,
    size_only::Bool = false,
    ignore_times::Bool = false,
    metadata::Bool = false,

    # Source directory handling
    delete_empty_src_dirs::Bool = false,
    create_empty_src_dirs::Bool = false,

    # Filtering
    no_traverse::Bool = false,
    max_age::Union{Nothing, String} = nothing,
    min_age::Union{Nothing, String} = nothing,
    max_size::Union{Nothing, String} = nothing,
    min_size::Union{Nothing, String} = nothing,
    exclude::Vector{String} = String[],
    include::Vector{String} = String[],

    # Output
    verbose::Int = 0,
    progress::Bool = false,

    # Escape hatch
    extra_flags::Vector{String} = String[]
)
    cmd = ["move", src, dest]

    # Safety
    dry_run && push!(cmd, "--dry-run")
    interactive && push!(cmd, "--interactive")

    # Core flags
    checksum && push!(cmd, "--checksum")
    update && push!(cmd, "--update")
    ignore_existing && push!(cmd, "--ignore-existing")
    size_only && push!(cmd, "--size-only")
    ignore_times && push!(cmd, "--ignore-times")
    metadata && push!(cmd, "--metadata")

    # Source dir cleanup
    delete_empty_src_dirs && push!(cmd, "--delete-empty-src-dirs")
    create_empty_src_dirs && push!(cmd, "--create-empty-src-dirs")

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

    # Output
    verbose > 0 && append!(cmd, ["-" * repeat("v", verbose)])
    progress && push!(cmd, "--progress")

    # Extra
    append!(cmd, extra_flags)

    return rclone_exe(cmd...)
end