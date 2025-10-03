

"""
    rclone_size(path::AbstractString; kwargs...)

Print the total size and number of objects in `path`.

Returns a string with human-readable summary (e.g., "Total objects: 123, Total size: 4.5 GiB").

# Keyword arguments
- `max_depth::Int = -1` → limit recursion depth
- `exclude::Vector{String} = String[]`
- `include::Vector{String} = String[]`
- `max_age`, `min_age`, `max_size`, `min_size`
- `fast_list::Bool = false`
- `json::Bool = false` → return JSON-formatted output instead
- `extra_flags::Vector{String} = String[]`

# Example
```julia
summary = rclone_size("gdrive:photos")
json_out = rclone_size("s3:bucket", json=true)
```
"""
function rclone_size(
    path::AbstractString;
    max_depth::Int = -1,
    exclude::Vector{String} = String[],
    include::Vector{String} = String[],
    max_age::Union{Nothing, String} = nothing,
    min_age::Union{Nothing, String} = nothing,
    max_size::Union{Nothing, String} = nothing,
    min_size::Union{Nothing, String} = nothing,
    fast_list::Bool = false,
    json::Bool = false,
    extra_flags::Vector{String} = String[]
)
    cmd = ["size", path]

    if max_depth != -1
        push!(cmd, "--max-depth"); push!(cmd, string(max_depth))
    end

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

    fast_list && push!(cmd, "--fast-list")
    json && push!(cmd, "--json")
    append!(cmd, extra_flags)

    return rclone_exe(cmd...)
end

"""
    rclone_tree(path::AbstractString; kwargs...)

Print a directory tree of the remote path.

Returns a string showing the hierarchical structure.

# Keyword arguments
- `max_depth::Int = -1`
- `dirs_only::Bool = false`
- `files_only::Bool = false`
- `exclude`, `include`, `max_age`, etc. (same as other commands)
- `extra_flags::Vector{String} = String[]`

# Example
```julia
tree = rclone_tree("dropbox:projects", max_depth=2)
println(tree)
```
"""
function rclone_tree(
    path::AbstractString;
    max_depth::Int = -1,
    dirs_only::Bool = false,
    files_only::Bool = false,
    exclude::Vector{String} = String[],
    include::Vector{String} = String[],
    max_age::Union{Nothing, String} = nothing,
    min_age::Union{Nothing, String} = nothing,
    max_size::Union{Nothing, String} = nothing,
    min_size::Union{Nothing, String} = nothing,
    extra_flags::Vector{String} = String[]
)
    cmd = ["tree", path]

    if max_depth != -1
        push!(cmd, "--max-depth"); push!(cmd, string(max_depth))
    end

    dirs_only && push!(cmd, "--dirs-only")
    files_only && push!(cmd, "--files-only")

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

"""
    rclone_version(; check::Bool = false, deps::Bool = false)

Return the rclone version info as a string.

# Keyword arguments
- `check::Bool = false` → compare with latest release/beta online
- `deps::Bool = false` → show Go dependencies

# Example
```julia
println(rclone_version())
println(rclone_version(check=true))
```
"""
function rclone_version(; check::Bool = false, deps::Bool = false)
    cmd = ["version"]
    check && push!(cmd, "--check")
    deps && push!(cmd, "--deps")
    return rclone_exe(cmd...)
end

"""
    rclone_help(; topic::Union{Nothing, String} = nothing)

Show general help or help for a specific command/topic.

Returns help text as a string.

# Arguments
- `topic`: e.g., `"sync"`, `"mount"`, or a backend name like `"s3"`

# Example
```julia
general = rclone_help()
sync_help = rclone_help(topic="sync")
```
"""
function rclone_help(; topic::Union{Nothing, String} = nothing)
    cmd = ["help"]
    if topic !== nothing
        push!(cmd, topic)
    end
    return rclone_exe(cmd...)
end