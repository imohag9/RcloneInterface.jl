"""
    rclone_ls(path::AbstractString; kwargs...)

List files in the given path with size and path (like `rclone ls`).

Returns a string with one line per file: `<size> <path>`

# Arguments
- `path`: Remote or local path to list

# Keyword arguments
- `max_depth::Int = -1` → `--max-depth N` (default: recurse fully)
- `recursive::Bool = true` → controls recursion (note: `ls` recurses by default)
- `exclude::Vector{String} = String[]`
- `include::Vector{String} = String[]`
- `max_age`, `min_age`, `max_size`, `min_size`
- `files_only::Bool = true` (default behavior)
- `dirs_only::Bool = false`
- `fast_list::Bool = false` → `--fast-list`
- `verbose::Int = 0`
- `extra_flags::Vector{String} = String[]`

> Note: `rclone ls` **recurses by default**. Use `max_depth=1` to list only top level.


```
"""
function rclone_ls(
    path::AbstractString;
    max_depth::Int = -1,
    recursive::Bool = true,  # ls recurses by default; this is for clarity
    exclude::Vector{String} = String[],
    include::Vector{String} = String[],
    max_age::Union{Nothing, String} = nothing,
    min_age::Union{Nothing, String} = nothing,
    max_size::Union{Nothing, String} = nothing,
    min_size::Union{Nothing, String} = nothing,
    files_only::Bool = true,
    dirs_only::Bool = false,
    fast_list::Bool = false,
    verbose::Int = 0,
    extra_flags::Vector{String} = String[]
)
    cmd = ["ls", path]

    # Depth control: --max-depth overrides default recursion
    if max_depth != -1
        push!(cmd, "--max-depth")
        push!(cmd, string(max_depth))
    end

    # Note: `ls` recurses by default; no need for `-R`

    # Filtering
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

    for pat in exclude
        push!(cmd, "--exclude"); push!(cmd, pat)
    end
    for pat in include
        push!(cmd, "--include"); push!(cmd, pat)
    end

    # Listing mode
    if dirs_only
        # `ls` doesn't have --dirs-only, but we can note that user should use `lsd`
        @warn "`rclone_ls` is for files. For directories only, use `rclone_lsd` (not yet implemented)."
    end
    # files_only is default; no flag needed

    fast_list && push!(cmd, "--fast-list")
    verbose > 0 && append!(cmd, ["-" * repeat("v", verbose)])
    append!(cmd, extra_flags)

    # Execute and return raw string output
    return rclone_exe(cmd...)
end