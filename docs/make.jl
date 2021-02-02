using Documenter
using RenoiseOSC

makedocs(sitename="RenoiseOSC.jl", modules=[RenoiseOSC], pages=["index.md", "api.md", "config.md"])
deploydocs(repo="github.com/stellartux/RenoiseOSC.jl.git")
