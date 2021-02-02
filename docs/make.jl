using Documenter
include("../src/RenoiseOSC.jl")

makedocs(sitename="RenoiseOSC.jl", modules=[RenoiseOSC], pages=["index.md", "api.md", "config.md"])
