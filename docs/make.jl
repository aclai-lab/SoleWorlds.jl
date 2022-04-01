using SoleWorlds
using Documenter

DocMeta.setdocmeta!(SoleWorlds, :DocTestSetup, :(using SoleWorlds); recursive=true)

makedocs(;
    modules=[SoleWorlds],
    authors="Eduard I. STAN, Giovanni PAGLIARINI",
    repo="https://github.com/aclai-lab/SoleWorlds.jl/blob/{commit}{path}#{line}",
    sitename="SoleWorlds.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://aclai-lab.github.io/SoleWorlds.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/aclai-lab/SoleWorlds.jl",
)
