
"""
    rclone_copy(src::AbstractString, dest::AbstractString; kwargs...)

Copy files from `src` to `dest` using `rclone copy`.

# Arguments
- `src`: Source path (e.g., `"local:/path"` or `"remote:bucket/dir"`)
- `dest`: Destination path

# Keyword arguments (common flags)
- `dry_run::Bool = false`: Do a trial run without copying (`--dry-run`)
- `verbose::Int = 0`: Verbosity level (`-v`, `-vv`, etc.)
- `checksum::Bool = false`: Use checksum + size to detect changes (`-c`)
- `update::Bool = false`: Skip files newer on destination (`-u`)
- `ignore_existing::Bool = false`: Skip files that already exist
- `max_age::Union{Nothing, String} = nothing`: Only copy files younger than this (e.g., `"24h"`)
- `exclude::Vector{String} = String[]`: Patterns to exclude
- `include::Vector{String} = String[]`: Patterns to include
- `metadata::Bool = false`: Preserve metadata (`-M`)
- `progress::Bool = false`: Show progress (`-P`)
- `extra_flags::Vector{String} = String[]`: Additional raw flags

# Example
```julia
rclone_copy("mylocal:/data", "gdrive:backup", dry_run=true, verbose=1)
```
"""
function rclone_copy(
    src::AbstractString,
    dest::AbstractString;
    dry_run::Bool = false,
    verbose::Int = 0,
    checksum::Bool = false,
    update::Bool = false,
    ignore_existing::Bool = false,
    max_age::Union{Nothing, String} = nothing,
    exclude::Vector{String} = String[],
    include::Vector{String} = String[],
    metadata::Bool = false,
    progress::Bool = false,
    extra_flags::Vector{String} = String[]
)
    cmd = ["copy", src, dest]

    # Add flags
    dry_run && push!(cmd, "--dry-run")
    checksum && push!(cmd, "--checksum")
    update && push!(cmd, "--update")
    ignore_existing && push!(cmd, "--ignore-existing")
    metadata && push!(cmd, "--metadata")
    progress && push!(cmd, "--progress")

    # Verbose: -v, -vv, -vvv
    verbose > 0 && append!(cmd, ["-" * repeat("v", verbose)])

    # Max age
    if max_age !== nothing
        push!(cmd, "--max-age")
        push!(cmd, max_age)
    end

    # Exclude/include patterns
    for pat in exclude
        push!(cmd, "--exclude")
        push!(cmd, pat)
    end
    for pat in include
        push!(cmd, "--include")
        push!(cmd, pat)
    end

    # Append any extra flags (for flexibility)
    append!(cmd, extra_flags)

    # Execute
    return rclone_exe(cmd...)
end

