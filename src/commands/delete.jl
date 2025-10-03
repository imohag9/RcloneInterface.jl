"""
    rclone_delete(path::AbstractString; kwargs...)

Delete files in the given path, respecting filters. Does **not** delete directories
unless `rmdirs=true` is used.

> ⚠️ **Warning**: This permanently deletes data. Always test with `dry_run=true`.

# Arguments
- `path`: Remote or local path to delete from

# Keyword arguments
- `dry_run::Bool = false`
- `interactive::Bool = false`
- `rmdirs::Bool = false` → also remove empty directories
- `verbose::Int = 0`

## Filtering (same as other commands)
- `exclude`, `include`, `max_age`, `min_size`, etc.

# Example
```julia
rclone_delete("gdrive:temp", dry_run=true, max_size="1G")
rclone_delete("s3:bucket/logs", rmdirs=true, min_age="7d")
```
"""
function rclone_delete(
    path::AbstractString;
    dry_run::Bool = false,
    interactive::Bool = false,
    rmdirs::Bool = false,
    verbose::Int = 0,

    # Filtering (reuse common subset)
    exclude::Vector{String} = String[],
    include::Vector{String} = String[],
    max_age::Union{Nothing, String} = nothing,
    min_age::Union{Nothing, String} = nothing,
    max_size::Union{Nothing, String} = nothing,
    min_size::Union{Nothing, String} = nothing,
    extra_flags::Vector{String} = String[]
)
    cmd = ["delete", path]

    dry_run && push!(cmd, "--dry-run")
    interactive && push!(cmd, "--interactive")
    rmdirs && push!(cmd, "--rmdirs")
    verbose > 0 && append!(cmd, ["-" * repeat("v", verbose)])

    # Filtering
    if max_age !== nothing; push!(cmd, "--max-age"); push!(cmd, max_age); end
    if min_age !== nothing; push!(cmd, "--min-age"); push!(cmd, min_age); end
    if max_size !== nothing; push!(cmd, "--max-size"); push!(cmd, max_size); end
    if min_size !== nothing; push!(cmd, "--min-size"); push!(cmd, min_size); end

    for pat in exclude
        push!(cmd, "--exclude"); push!(cmd, pat)
    end
    for pat in include
        push!(cmd, "--include"); push!(cmd, pat)
    end

    append!(cmd, extra_flags)
    return rclone_exe(cmd...)
end