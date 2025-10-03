using RcloneInterface
using Documenter

DocMeta.setdocmeta!(RcloneInterface, :DocTestSetup, :(using RcloneInterface); recursive=true)

makedocs(;
    modules=[RcloneInterface],
    checkdocs = :exports,
    authors="imohag9 <souidi.hamza90@gmail.com> and contributors",
    sitename="RcloneInterface.jl",
    format=Documenter.HTML(;
        canonical="https://imohag9.github.io/RcloneInterface.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Commands" => "commands.md",
        "API Reference" => "api.md",
    ],
)

deploydocs(;
    repo="github.com/imohag9/RcloneInterface.jl",
    devbranch="main",
)
