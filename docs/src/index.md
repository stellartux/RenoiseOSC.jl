# RenoiseOSC.jl

```@meta
CurrentModule = RenoiseOSC
```

```@docs
RenoiseOSC
```

## Install

Run the following commands in Julia to install RenoiseOSC.

```julia
using Pkg
Pkg.add(url="https://github.com/stellartux/RenoiseOSC.jl")
```

## Use

Open Renoise. The OSC server must be enabled for RenoiseOSC.jl to be able to communicate with it.

To enable the OSC server, select the Edit menu, then open the Preferences menu. Open the OSC tab and check
the Enable Server checkbox. You should see `*** Server is up and running` in the Incoming Messages panel.

```julia
using RenoiseOSC
start()
```

If everything is working correctly, Renoise should now be playing.
