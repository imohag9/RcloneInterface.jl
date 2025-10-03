# src/core.jl
using Rclone_jll

"""
    rclone_exe(args::AbstractString...; collect = true)
Execute rclone with the given arguments.
Returns stdout/stderr as a string if `collect=true` (default).
"""
rclone_exe(args::AbstractString...; collect = true) = rclone_exe(Cmd([args...]); collect=collect)

"""
    rclone_exe(cmd::Cmd; collect = true)
Execute rclone with the given Cmd.
"""
function rclone_exe(cmd::Cmd; collect = true)
    f = collect ? _collectexecoutput : Base.run
    return f(`$(rclone()) $cmd`)
end

"""
    _collectexecoutput(exec::Cmd)
Run the command and return the dominant output stream as a string.
"""
function _collectexecoutput(exec::Cmd)
    out_s, err_s = _readexecoutput(exec)
    # Return the longer stream as a single string
    out_str = join(out_s, "\n")
    err_str = join(err_s, "\n")
    return length(out_str) >= length(err_str) ? out_str : err_str
end

"""
    _readexecoutput(exec::Cmd) -> (stdout_lines, stderr_lines)
Capture stdout and stderr as Vector{String}.
"""
function _readexecoutput(exec::Cmd)
    out = Pipe()
    err = Pipe()
    proc = Base.open(pipeline(ignorestatus(exec), stdout=out, stderr=err))
    close(out.in)
    close(err.in)
    out_lines = readlines(out)
    err_lines = readlines(err)
    close(proc)
    return out_lines, err_lines
end