
using RcloneInterface
using Test
using Aqua
using Random
using SHA


# --- Code Quality ---
@testset "Code quality (Aqua.jl)" begin
    Aqua.test_all(RcloneInterface; ambiguities=false)  # disable ambiguities due to JLL
end

# --- Integration Tests ---
@testset "Integration tests (local backend)" begin
    # Create temporary directories
    tmp = mktempdir()
    src_dir = joinpath(tmp, "src")
    dst_dir = joinpath(tmp, "dst")
    mkdir(src_dir)
    mkdir(dst_dir)

    # Helper to write a test file
    function write_test_file(path, content)
        open(path, "w") do io
            write(io, content)
        end
    end

    # Create test files
    write_test_file(joinpath(src_dir, "file1.txt"), "Hello from RcloneInterface!")
    write_test_file(joinpath(src_dir, "file2.log"), "Log data\nmore logs")
    mkdir(joinpath(src_dir, "subdir"))
    write_test_file(joinpath(src_dir, "subdir", "nested.txt"), "Nested content")

    try




        # Test: rclone_copy
        rclone_copy(src_dir, dst_dir; verbose=0)
        @test isfile(joinpath(dst_dir, "file1.txt"))
        @test isfile(joinpath(dst_dir, "subdir", "nested.txt"))

        # Verify content
        @test read(joinpath(dst_dir, "file1.txt"), String) == "Hello from RcloneInterface!"

        # Test: rclone_check (should pass)
        check_out = rclone_check(src_dir, dst_dir; size_only=true)
        @test occursin("0 differences found", check_out)  # no mismatches

        # Test: rclone_delete (only .log files)
        rclone_delete(dst_dir; include=["*.log"], dry_run=false)
        @test !isfile(joinpath(dst_dir, "file2.log"))   # deleted
        @test isfile(joinpath(dst_dir, "file1.txt"))    # kept

        # Test: rclone_sync with dry_run (should not error)
        rclone_sync(src_dir, dst_dir; dry_run=true, verbose=0)

        # Test: rclone_version
        version_str = rclone_version()
        @test startswith(version_str, "rclone v")

    finally
        rm(tmp, recursive=true)
    end
end