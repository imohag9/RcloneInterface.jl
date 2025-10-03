
"""
    rclone_check(src::AbstractString, dest::AbstractString; kwargs...)

Verify that files in source and destination match (size + hash by default).

Returns the raw output (useful for parsing mismatch reports).

# Arguments
- `src`, `dest`: paths to compare

# Keyword arguments
- `size_only::Bool = false` → skip hash check
- `download::Bool = false` → download and compare byte-by-byte
- `one_way::Bool = false` → only check that source files exist in dest
- `checkfile::Union{Nothing,String} = nothing` → treat src as SUM file

## Logging/reporting (like sync)
- `combined`, `differ`, `missing_on_dst`, `missing_on_src`, `error_log`

## Filtering & verbosity
- `exclude`, `include`, `verbose`, etc.

# Example
```julia
output = rclone_check("local:/data", "s3:backup", size_only=true, verbose=1)
println(output)
```
"""
function rclone_check(
    src::AbstractString,
    dest::AbstractString;
    size_only::Bool = false,
    download::Bool = false,
    one_way::Bool = false,
    checkfile::Union{Nothing, String} = nothing,

    # Reporting
    combined::Union{Nothing, String} = nothing,
    differ::Union{Nothing, String} = nothing,
    missing_on_dst::Union{Nothing, String} = nothing,
    missing_on_src::Union{Nothing, String} = nothing,
    error_log::Union{Nothing, String} = nothing,

    # Filtering
    exclude::Vector{String} = String[],
    include::Vector{String} = String[],
    max_age::Union{Nothing, String} = nothing,
    min_size::Union{Nothing, String} = nothing,

    # Output
    verbose::Int = 0,
    extra_flags::Vector{String} = String[]
)
    cmd = ["check", src, dest]

    size_only && push!(cmd, "--size-only")
    download && push!(cmd, "--download")
    one_way && push!(cmd, "--one-way")
    if checkfile !== nothing
        push!(cmd, "--checkfile"); push!(cmd, checkfile)
    end

    # Reporting
    if combined !== nothing; push!(cmd, "--combined"); push!(cmd, combined); end
    if differ !== nothing; push!(cmd, "--differ"); push!(cmd, differ); end
    if missing_on_dst !== nothing; push!(cmd, "--missing-on-dst"); push!(cmd, missing_on_dst); end
    if missing_on_src !== nothing; push!(cmd, "--missing-on-src"); push!(cmd, missing_on_src); end
    if error_log !== nothing; push!(cmd, "--error"); push!(cmd, error_log); end

    # Filtering
    if max_age !== nothing; push!(cmd, "--max-age"); push!(cmd, max_age); end
    if min_size !== nothing; push!(cmd, "--min-size"); push!(cmd, min_size); end

    for pat in exclude
        push!(cmd, "--exclude"); push!(cmd, pat)
    end
    for pat in include
        push!(cmd, "--include"); push!(cmd, pat)
    end

    verbose > 0 && append!(cmd, ["-" * repeat("v", verbose)])
    append!(cmd, extra_flags)

    return rclone_exe(cmd...)
end