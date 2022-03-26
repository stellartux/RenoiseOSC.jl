"""

    RenoiseOSC

[RenoiseOSC.jl](https://stellartux.github.io/RenoiseOSC.jl/dev/)
is a collection of wrappers around the [Renoise OSC API functions](https://tutorials.renoise.com/wiki/Open_Sound_Control).
"""
module RenoiseOSC

export luaeval,
    bpm,
    tempo,
    editmode,
    octave,
    patternfollow,
    editstep,
    setmacroparam,
    monophonic,
    monophonicglide,
    phraseplayback,
    phraseprogram,
    quantizationmode,
    scalekey,
    scalemode,
    transpose,
    volume,
    volumedb,
    linesperbeat,
    lpb,
    metronome,
    metronomeprecount,
    quantization,
    quantizationstep,
    scheduleadd,
    scheduleset,
    slotmute,
    slotunmute,
    trigger,
    ticksperline,
    tpl,
    bypass,
    setparam,
    mute,
    unmute,
    solo,
    outputdelay,
    postfxpanning,
    postfxvolume,
    postfxvolumedb,
    prefxpanning,
    prefxvolume,
    prefxvolumedb,
    prefxwidth,
    loopblock,
    loopblockmovebackwards,
    loopblockmoveforwards,
    looppattern,
    loopsequence,
    panic,
    start,
    stop,
    resume,
    midievent,
    noteon,
    noteoff,
    sethost!,
    setport!

using OpenSoundControl
using Sockets

const settings = Dict{String,Union{Sockets.InetAddr,UDPSocket}}("server" => Sockets.InetAddr(ip"127.0.0.1", 8000))

"""

    sethost!(host::Union{AbstractString,Sockets.IPAddr})

Set the host of the Renoise OSC server. Default value is `ip"127.0.0.1"`.

!!! compat "Julia 1.3"
    Setting the host by passing an AbstractString requires at least Julia 1.3.

# Example

```jldoctest; setup=:(using Sockets: @ip_str; using RenoiseOSC: sethost!)
julia> sethost!(ip"127.0.0.1")
Sockets.InetAddr{Sockets.IPv4}(ip"127.0.0.1", 8000)
```
"""
sethost!(host::Union{AbstractString,IPAddr}) = settings["server"] = Sockets.InetAddr(host, settings["server"].port)

"""

    setport!(port::Integer)

Set the port of the Renoise OSC server. Default value is `8000`.
"""
setport!(port::Integer) = settings["server"] = Sockets.InetAddr(settings["server"].host, port)

"""

    setaddress!(host::Union{AbstractString,Sockets.IPAddr}, port::Integer)

Set the host and the port of the OSC Server.
"""
setaddress!(host::Union{AbstractString,IPAddr}, port::Integer) = settings["server"] = Sockets.InetAddr(host, port)

function postmessage(path::AbstractString, argtypes::AbstractString="", args...)
    send(
        get!(UDPSocket, settings, "socket"),
        settings["server"].host,
        settings["server"].port,
        OpenSoundControl.message("/renoise/" * path, argtypes, args...).data
    )
end

"""

    luaeval(expr::AbstractString)

Evaluate a Lua expression inside Renoise's scripting environment.

# Example

```julia
luaeval("renoise.song().transport.bpm = 132")
```
"""
luaeval(expr::AbstractString) = postmessage("evaluate", "s", expr)

"""

    tempo(bpm::Integer)

Set the song's [current bpm](https://tutorials.renoise.com/wiki/Transport_Panel#Song_Parameters) value.
The valid tempo range is `32:999` for `<v3.4`, `20:999` for `>=v3.4`.
"""
function tempo(bpm::Integer)
    if 20 <= bpm <= 999
        postmessage("song/bpm", "i", Int32(bpm))
    else
        @warn "Can't set bpm to $(bpm), bpm must be in 20:999"
    end
end

bpm = tempo

"""

    editmode(on::Bool)

Set the song's global [edit mode](https://tutorials.renoise.com/wiki/Recording_and_Editing_Notes#Edit_Mode) on or off.
"""
editmode(on::Bool) = postmessage("song/edit/mode", on ? "T" : "F")

"""

    octave(oct::Integer)

Sets the song's [current octave](https://tutorials.renoise.com/wiki/Transport_Panel#Song_Parameters) `0:8`.
"""
function octave(oct::Integer)
    if oct in 0:8
        postmessage("song/edit/octave", "i", Int32(oct))
    else
        @warn "Can't set octave to $(oct), octave must be in `0:8`"
    end
end

"""

    patternfollow(on::Bool)

Enable or disable the global [pattern follow](https://tutorials.renoise.com/wiki/Transport_Panel#Song_Controls) mode.
"""
patternfollow(on::Bool) = postmessage("song/edit/pattern_follow", on ? "T" : "F")

"""

    editstep(step::Integer)

Set the song's current [edit step](https://tutorials.renoise.com/wiki/Pattern_Editor#Pattern_Editor_Control_Panel) `[0:8]`.
"""
function editstep(step::Integer)
    if step in 0:8
        postmessage("song/edit/step", "i", Int32(step))
    else
        @warn "Can't set edit step to $(step), edit step must be in 0:8"
    end
end


"""

    setmacroparam(param::Integer, value::Real; instrument::Integer = -1)

Set `instrument`'s [macro](https://tutorials.renoise.com/wiki/Sampler#Macros) parameter value `0.0:1.0`.
Defaults to the currently selected instrument and macro 1.
"""
function setmacroparam(param::Integer, value::Real; instrument::Integer=-1)
    postmessage("song/instrument/$(instrument)/macro$(param)", "d", Float64(value))
end

"""

    monophonic(mono::Bool; instrument::Integer=-1)

Enable or disable `instrument`'s [mono mode](https://tutorials.renoise.com/wiki/Instruments#Instrument_Properties).
Default to the currently selected instrument.
"""
monophonic(mono::Bool; instrument::Integer=-1) = postmessage("song/instrument/$(instrument)/monophonic", mono ? "T" : "F")

"""

    monophonicglide(glide::Integer; instrument::Integer=-1)

Set `instrument`'s [glide amount](https://tutorials.renoise.com/wiki/Instruments#Instrument_Properties) `0:255`.
Default to the currently selected instrument.
"""
function monophonicglide(glide::Integer; instrument::Integer=-1)
    if glide in 0:255
        postmessage("song/instrument/$(instrument)/monophonic_glide", "i", Int32(glide))
    else
        @warn "Can't set monophonic glide to $(glide), glide must be in `0:255`"
    end
end

"""
    phraseplayback(mode::AbstractString; instrument::Integer=-1)

Set `instrument`'s [phrase playback mode](https://tutorials.renoise.com/wiki/Phrase_Editor#Phrase_Controls) `["Off", "Program", "Keymap"]`
Default to the currently selected instrument.
"""
function phraseplayback(mode::AbstractString; instrument::Integer=-1)
    if mode in Set(["Off", "Program", "Keymap"])
        postmessage("song/instrument/$(instrument)/phrase_playback", "s", mode)
    else
        @warn "Can't set phrase playback mode to \"$(mode)\", mode must be one of `[\"Off\", \"Program\", \"Keymap\"]`"
    end
end

"""

    phraseprogram(program::Integer; instrument::Integer=-1)

Set `instrument`'s [phrase program number](https://tutorials.renoise.com/wiki/Phrase_Editor#Phrase_Controls) `0:127`.
Default to the currently selected instrument.
"""
function phraseprogram(program::Integer; instrument::Integer=-1)
    if program in 0:127
        postmessage("song/instrument/$(instrument)/phrase_playback", "i", Int32(program))
    else
        @warn "Can't set phrase program to $(program), program must be in 0:127"
    end
end

"""

    quantizationmode(mode::AbstractString; instrument::Integer=-1)

Set `instrument`'s [quantization method](https://tutorials.renoise.com/wiki/Instruments#Instrument_Properties), one of `"None"`, `"Line"`, `"Beat"`, `"Bar"`.
Default to the currently selected instrument.
"""
function quantizationmode(mode::AbstractString; instrument::Integer=-1)
    if mode in Set(["None", "Line", "Beat", "Bar"])
        postmessage("song/instrument/$(instrument)/quantize", "s", mode)
    else
        @warn "Can't set quantization mode to \"$(mode)\", mode must be one of `[\"None\", \"Line\", \"Beat\", \"Bar\"]`"
    end
end

"""

    scalekey(key::AbstractString; instrument::Integer=-1)

Set `instrument`'s [note scaling](https://tutorials.renoise.com/wiki/Instruments#Instrument_Properties) key `["C", "C#"..., "B"]`.
Default to the currently selected instrument.
"""
function scalekey(key::AbstractString; instrument::Integer=-1)
    key = get(key, Dict("Db" => "C#", "Eb" => "D#", "Gb" => "F#", "Ab" => "G#", "Bb" => "A#"), key)
    if key in Set(["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"])
        postmessage("song/instrument/$(instrument)/scale_key", "s", key)
    else
        @warn "Can't set scale key to \"$(key)\", key must be one of [\"C\", \"C#\", \"D\", \"D#\", \"E\", \"F\", \"F#\", \"G\", \"G#\", \"A\", \"A#\", \"B\"]"
    end
end

"""

    scalemode(mode::AbstractString; instrument::Integer=-1)

Set `instrument`'s [note scaling](https://tutorials.renoise.com/wiki/Instruments#Instrument_Properties) mode.
Default to the currently selected instrument.
"""
function scalemode(mode::AbstractString; instrument::Integer=-1)
    postmessage("song/instrument/$(instrument)/scale_mode", "s", mode)
end

"""

    transpose(pitch::Integer; instrument::Integer=-1)

Set `instrument`'s [global pitch transpose](https://tutorials.renoise.com/wiki/Instruments#Instrument_Properties) `-120:120`.
Default to the currently selected instrument.
"""
function transpose(pitch::Integer; instrument::Integer=-1)
    if pitch in -120:120
        postmessage("song/instrument/$(instrument)/transpose", "i", pitch)
    else
        @warn "Can't transpose by $(pitch), `pitch` must be in `-120:120`"
    end
end

"""

    volume(level::Real; instrument::Integer=-1)

Set `instrument`'s [global volume](https://tutorials.renoise.com/wiki/Instruments#Instrument_Properties) to `level` `[0.0:db2lin(6)]≈[0.0:2.0]`.
Default to the currently selected instrument.
"""
function volume(level::Real; instrument::Integer=-1)
    postmessage("song/instrument/$(instrument)/volume", "d", clamp(Float64(level), 0.0, 1.9952623149688795))
end

"""

    volumedb(level::Real; instrument::Integer=-1)

Set `instrument`'s [global volume](https://tutorials.renoise.com/wiki/Instruments#Instrument_Properties) to `level` in decibels `[0.0:6.0]`.
Default to the currently selected instrument.
"""
function volumedb(level::Real; instrument::Integer=-1)
    postmessage("song/instrument/$(instrument)/volume_db", "d", clamp(Float64(level), 0.0, 6.0))
end

"""

    linesperbeat(lpb::Integer)

Set the song's current [lines per beat](https://tutorials.renoise.com/wiki/Transport_Panel#Song_Parameters) `1:255`.
"""
function linesperbeat(lpb::Integer)
    if lpb in 1:255
        postmessage("song/lpb", "i", Int32(lpb))
    else
        @warn "Can't set lines per beat to $(lpb), `lpb` must be in `1:255`"
    end
end

lpb = linesperbeat

"""

    metronome(on::Bool)

Enable or disable the [metronome](https://tutorials.renoise.com/wiki/Transport_Panel).
"""
metronome(on::Bool) = postmessage("song/record/metronome", on ? "T" : "F")

"""

    metronomeprecount(on::Bool)

Enable or disable the global [metronome](https://tutorials.renoise.com/wiki/Transport_Panel) precount.
"""
metronomeprecount(on::Bool) = postmessage("song/record/metronome_precount", on ? "T" : "F")

"""

    quantization(on::Bool)

Enable or disable the global [record quantization](https://tutorials.renoise.com/wiki/Pattern_Editor#Pattern_Editor_Control_Panel).
"""
quantization(on::Bool) = postmessage("song/record/quantization", on ? "T" : "F")

"""

    quantizationstep(step::Integer)

Set the global [record quantization](https://tutorials.renoise.com/wiki/Pattern_Editor#Pattern_Editor_Control_Panel) step `1:32`.
"""
function quantizationstep(step::Integer)
    if step in 1:32
        postmessage("song/record/quantization_step", b ? "T" : "F")
    else
        @warn "Can't set quantization step to $(step), `step` must be in `1:32`"
    end
end

"""

    scheduleadd(sequence::Integer)

Add a scheduled [sequence playback position](https://tutorials.renoise.com/wiki/Pattern_Sequencer#Triggering_Patterns).
"""
scheduleadd(sequence::Integer) = postmessage("song/sequence/schedule_add", "i", Int32(sequence))

"""

    scheduleset(sequence::Integer)

Replace the current scheduled [sequence playback](https://tutorials.renoise.com/wiki/Pattern_Sequencer#Triggering_Patterns) position.
"""
scheduleset(sequence::Integer) = postmessage("song/sequence/schedule_set", "i", Int32(sequence))

"""

    slotmute(track::Integer, sequence::Integer)
    slotmute(mute::Bool, track::Integer, sequence::Integer)

Mute the [specified track at the specified sequence slot](https://tutorials.renoise.com/wiki/Pattern_Matrix#Muting_Blocks) in the matrix.
"""
slotmute(track::Integer, sequence::Integer) = postmessage("song/sequence/slot_mute", "ii", Int32(track), Int32(sequence))
slotmute(mute::Bool, track::Integer, sequence::Integer) = (mute ? slotmute : slotunmute)(track, sequence)

"""

    slotunmute(track::Integer, sequence::Integer)

Unmute the [specified track at the specified sequence slot](https://tutorials.renoise.com/wiki/Pattern_Matrix#Muting_Blocks) in the matrix.
"""
slotunmute(track::Integer, sequence::Integer) = postmessage("song/sequence/slot_unmute", "ii", Int32(track), Int32(sequence))

"""

    trigger(sequence::Integer)

Set playback pos to the specified [sequence position](https://tutorials.renoise.com/wiki/Pattern_Sequencer#Triggering_Patterns).
"""
trigger(sequence::Integer) = postmessage("song/sequence/trigger", "i", Int32(sequence))

"""

    ticksperline(tpl::Integer)

Set the song's current [ticks per line](https://tutorials.renoise.com/wiki/Song_Options#Playback_Options) `1:16`.
"""
function ticksperline(tpl::Integer)
    if tpl in 1:16
        postmessage("song/tpl", "i", Int32(tpl))
    else
        @warn "Can't set ticks per line to $(tpl), ticks per line must be in `1:16`"
    end
end

tpl = ticksperline

"""

    bypass(bypassed::Bool; track::Integer=-1, device::Integer=-1)

Enable or disable the [bypassing](https://tutorials.renoise.com/wiki/Effect_Chains#Common_Effect_Layout_and_Controls)
of an [effect device](https://tutorials.renoise.com/wiki/Effect_Chains), set `true` to bypass the device.
When unspecified, `track` and `device` default to the currently selected track and device.
"""
function bypass(bypassed::Bool; track::Integer=-1, device::Integer=-1)
    postmessage("song/track/$(track)/device/$(device)/bypass", bypassed ? "T" : "F")
end

"""

    setparam(key::Union{AbstractString,Integer}, value::Real; track::Integer=-1, device::Integer=-1)

Set the parameter of any [effect device](https://tutorials.renoise.com/wiki/Effect_Chains)
by its name or index. `value` is clamped between `0.0` and `1.0`.
When unspecified, track and device default to the currently selected track and device.
"""
function setparam(key::Integer, value::Real; track::Integer=-1, device::Integer=-1)
    postmessage("song/track/$(track)/device/$(device)/set_parameter_by_index", "id", Int32(key), Float64(clamp(value, 0.0, 1.0)))
end
function setparam(key::AbstractString, value::Real; track::Integer=-1, device::Integer=-1)
    postmessage("song/track/$(track)/device/$(device)/set_parameter_by_name", "sd", key, Float64(clamp(value, 0.0, 1.0)))
end

"""

    mute(muted::Bool = true; track::Integer = -1)

[Mute](https://tutorials.renoise.com/wiki/Pattern_Editor#Muting_Tracks) the given track.
Default to the currently selected track.
"""
mute(muted::Bool=true; track::Integer=-1) = postmessage("song/track/$(track)/$(muted ? "" : "un")mute")

"""

    unmute(; track::Integer=-1)
    mute(false; track::Integer=-1)

[Unmute](https://tutorials.renoise.com/wiki/Pattern_Editor#Muting_Tracks) the given track.
Default to the currently selected track.
"""
unmute(; track::Integer=-1) = postmessage("song/track/$(track)/unmute")

"""

    solo(; track::Integer)

Toggle [solo](https://tutorials.renoise.com/wiki/Pattern_Editor#Muting_Tracks) for the given track.
Default to the currently selected track.
"""
solo(; track::Integer=-1) = postmessage("song/track/$(track)/solo")

"""

    outputdelay(δt::Real; track::Integer)

Set the given track's [pre-FX output delay](https://tutorials.renoise.com/wiki/Effect_Chains#Pre_and_Post_Mixer_Effects) in milliseconds [-100:100].
Default to the currently selected track.
"""
function outputdelay(δt::Real; track::Integer=-1)
    if -100.0 <= δt <= 100.0
        postmessage("song/track/$(track)/output_delay", "d", Float64(δt))
    else
        @warn "Can't set output delay to `$(δt)`. The output delay time must be between `-100.0` and `100.0`"
    end
end

"""

    postfxpanning(pan::Integer; track::Integer=-1)

Set `track`'s [post-FX panning](https://tutorials.renoise.com/wiki/Mixer#Pre.2FPost_Volume_and_Panning_Concept), `-50:50` left to right.
Default to the currently selected track.
"""
function postfxpanning(pan::Integer; track::Integer=-1)
    if -50 <= pan <= 50
        postmessage("song/track/$(track)/postfx_panning", "i", Int32(pan))
    else
        @warn "Can't set post-FX panning to $(pan), `pan` must be in `-50:50`"
    end
end

"""

    postfxvolume(level::Real; track::Integer=-1)

Set `track`s [post-FX volume](https://tutorials.renoise.com/wiki/Mixer#Pre.2FPost_Volume_and_Panning_Concept), `0.0:db2lin(6.0)`, `-Inf:+6dB`.
Default to the currently selected track.
"""
function postfxvolume(level::Real; track::Integer=-1)
    postmessage("song/track/$(track)/postfx_volume", "d", clamp(Float64(level), 0.0, 1.9952623149688795))
end

"""

    postfxvolumedb(level::Real; track::Integer=-1)

Set `track`s [post-FX volume](https://tutorials.renoise.com/wiki/Mixer#Pre.2FPost_Volume_and_Panning_Concept) in decibels, `-200.0:3.0`.
Default to the currently selected track.
"""
function postfxvolumedb(level::Real; track::Integer=-1)
    postmessage("song/track/$(track)/postfx_volume_db", "d", clamp(Float64(level), -200.0, 3.0))
end

"""

    prefxpanning(pan::Integer; track::Integer=-1)

Set `track`'s [pre-FX panning](https://tutorials.renoise.com/wiki/Mixer#Pre.2FPost_Volume_and_Panning_Concept), `[-50:50]` left to right.
Default to the currently selected track.
"""
function prefxpanning(pan::Integer; track::Integer=-1)
    if -50 <= pan <= 50
        postmessage("song/track/$(track)/prefx_panning", "i", Int32(pan))
    else
        @warn "Can't set pre-FX panning to $(pan), `pan` must be in `-50:50`"
    end
end

"""

    prefxvolume(level::Real; track::Integer=-1)

Set `track`s [pre-FX volume](https://tutorials.renoise.com/wiki/Mixer#Pre.2FPost_Volume_and_Panning_Concept), `[0.0:db2lin(6.0)]`, `-Inf:+6dB`.
Default to the currently selected track.
"""
function prefxvolume(level::Real; track::Integer=-1)
    postmessage("song/track/$(track)/prefx_volume", "d", clamp(Float64(level), 0.0, 1.9952623149688795))
end

"""

    prefxvolumedb(level::Real; track::Integer=-1)

Set `track`s [pre-FX volume](https://tutorials.renoise.com/wiki/Mixer#Pre.2FPost_Volume_and_Panning_Concept) in decibels, `-200.0:3.0`.
Default to the currently selected track.
"""
prefxvolumedb(level::Real; track::Integer=-1) = postmessage("song/track/$(track)/prefx_volume_db", "d", clamp(Float64(level), -200.0, 3.0))

"""

    prefxwidth(width::Real; track::Integer=-1)

Set `track`'s [pre-FX width](https://tutorials.renoise.com/wiki/Effect_Chains#Pre_and_Post_Mixer_Effects) `0.0:1.0`.
Default to the currently selected track.
"""
prefxwidth(width::Real; track::Integer=-1) = postmessage("song/track/$(track)/prefx_width", "d", clamp(Float64(width), 0.0, 1.0))

"""

    loopblock(loop::Bool)

Enable or disable pattern [block loop](https://tutorials.renoise.com/wiki/Transport_Panel#Song_Parameters).
"""
loopblock(loop::Bool) = postmessage("/transport/loop/block", loop ? "T" : "F")

"""

    loopblockmovebackwards()

Move the [block loop](https://tutorials.renoise.com/wiki/Transport_Panel#Song_Parameters) one segment backwards.
"""
loopblockmovebackwards() = postmessage("transport/loop/block_move_backwards")

"""

    loopblockmoveforwards()

Move the [block loop](https://tutorials.renoise.com/wiki/Transport_Panel#Song_Parameters) one segment forwards.
"""
loopblockmoveforwards() = postmessage("transport/loop/block_move_forwards")

"""

    looppattern(loop::Bool)

Enable or disable [looping the current pattern](https://tutorials.renoise.com/wiki/Transport_Panel).
"""
looppattern(loop::Bool) = postmessage("transport/loop/pattern", loop ? "T" : "F")

"""

    loopsequence()

Disable or set a new [sequence loop](https://tutorials.renoise.com/wiki/Pattern_Sequencer#Looping_Patterns) range.
"""
function loopsequence(start::Integer, stop::Integer = start)
    postmessage("transport/loop/sequence", "ii", Int32(start), Int32(stop))
end

"""

    start()

Start song playback or restart playing the current pattern.
"""
start() = postmessage("transport/start")

"""

    stop()

Stop song playback.
"""
stop() = postmessage("transport/stop")

"""

    panic()

Stop playback and reset all playing instruments and DSPs
"""
panic() = postmessage("transport/panic")

"""

    resume()

Continue playback. Called `continue` in the Renoise docs, but this name
can't be used as `continue` is a reserved word in Julia.
"""
resume() = postmessage("transport/continue")

"""

    midievent(portid::UInt8, status::UInt8, data1::UInt8, data2::UInt8)
    midievent(event::Union{UInt32,UInt64,Array{<:Integer},NTuple{4,<:Integer}})

Fire a raw MIDI event.
"""
midievent(portid::UInt8, status::UInt8, data1::UInt8, data2::UInt8) = postmessage("trigger/midi", "m", [portid, status, data1, data2])
function midievent(event::Union{Array{<:Integer},NTuple{4,<:Integer}})
    if all(<=(255), event)
        postmessage("trigger/midi", "m", UInt8.(event))
    else
        @warn "Can't send MIDI event"
    end
end
midievent(portid::Integer, status::Integer, data1::Integer, data2::Integer) = midievent([portid, status, data1, data2])
midievent(event::UInt64) = postmessage("trigger/midi", "h", event)
midievent(event::UInt32) = postmessage("trigger/midi", "i", event)

"""

    noteon(pitch::Integer, velocity::Integer; instrument::Integer=-1, track::Integer=-1)

Turn on the note with the velocity.
Default to the currently selected instrument and track.
"""
function noteon(pitch::Integer, velocity::Integer; instrument::Integer=-1, track::Integer=-1)
    postmessage("trigger/note_on", "iiii", Int32.((instrument, track, pitch, velocity))...)
end

"""

    noteoff(pitch::Integer, velocity::Integer; instrument::Integer=-1, track::Integer=-1)

Trigger a [note off](https://tutorials.renoise.com/wiki/Playing_Notes_with_the_Computer_Keyboard#Note_Off).
"""
function noteoff(pitch::Integer; instrument::Integer=-1, track::Integer=-1)
    postmessage("trigger/note_off", "iii", Int32.((instrument, track, pitch))...)
end

end # module
