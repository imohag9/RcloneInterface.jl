# src/commands/dedupe.jl

"""
    rclone_dedupe(path::AbstractString; kwargs...)

Find and resolve duplicate files (by name or hash).

> ⚠️ Can delete or rename files. Use `dry_run=true` first!

# Arguments
- `path`: remote path to dedupe

# Keyword arguments
- `by_hash::Bool = false` → dedupe by content hash instead of name
- `dedupe_mode::String = "interactive"` → `"skip"`, `"first"`, `"newest"`, `"rename"`, etc.
- `size_only::Bool = false` → use size only (for backends without hash)
- `dry_run::Bool = false`
- `interactive::Bool = false`
- `verbose::Int = 0`

# Example
```julia
rclone_dedupe("gdrive:photos", dedupe_mode="rename", dry_run=true)
rclone_dedupe("crypt:backups", by_hash=true, dedupe_mode="largest")
```
"""
function rclone_dedupe(
    path::AbstractString;
    by_hash::Bool = false,
    dedupe_mode::String = "interactive",
    size_only::Bool = false,
    dry_run::Bool = false,
    interactive::Bool = false,
    verbose::Int = 0,
    extra_flags::Vector{String} = String[]
)
    cmd = ["dedupe", path]

    by_hash && push!(cmd, "--by-hash")
    push!(cmd, "--dedupe-mode"); push!(cmd, dedupe_mode)
    size_only && push!(cmd, "--size-only")
    dry_run && push!(cmd, "--dry-run")
    interactive && push!(cmd, "--interactive")
    verbose > 0 && append!(cmd, ["-" * repeat("v", verbose)])
    append!(cmd, extra_flags)

    return rclone_exe(cmd...)
end