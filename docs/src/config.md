# Configuration

```@meta
CurrentModule = RenoiseOSC
```

RenoiseOSC defaults to sending events to `localhost` at port `8000`, the default port which
Renoise hosts its OSC server on. To use a different address, use the functions below.
Only communication over UDP is supported.

```@docs
setaddress!
sethost!
setport!
```
