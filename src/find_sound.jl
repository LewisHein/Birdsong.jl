"""
`function find_sound{T}(song::AbstractArray{T, 1}, cutoff::Real, maxsilence::Real; mindur::Real=0, maxdur::Real=-1)`

Automatically detect bird calls in a recording and return vectors of their start and end times

Paramaters:
 - `song`: An array containing the samples of the recording
 - `cutoff`: The cutoff (as a proportion of maximum volume) that is used to seperate sound from silence
 - `maxsilence:` The maximum length (in seconds) of silence that can occur before the current song is declared to have ended.
 - `mindur:` The minimum duration (in seconds) of sound with amplitude above `cutoff` that is deemed meaningful.
 - `maxdur`: The maximum duration (in seconds) of sound with amplitude above `cutoff` that is desired.
Sounds that are found but have duration less than `mindur` or greater than `maxdur` are not reported.

Algorithmic details:
1) Compute the STFT (spectrogram) of `song`.
2) For each piece of `song` in the spectrogram, find the centroid frequency
3) We now have a path through the spectrogram that will follow a bird song *if* it is sufficiently loud relative to background noise
4) Compute the amplitude along this path (actually along a small band centered on this path to compensate for windowing effects) We now have an estimate of amplitude vs. time that is insensitive to noise
5) The domain of amplitude(t) may be thought of as consisting of two disjoint subsets: "silence", all t such that amplitude(t) < `cutoff` and "sounds", all t such that amplitude(t) >= `cutoff`
6) However, we decide that silences of duration shorter than `maxsilence` don't count; when one of these silences occurs between two sounds, we just declare the two sounds to be one.
7) Repeat this process until all silences of duration < `maxsilence` have been eliminated.
8) Return two arrays containing start and end times of all the sounds

**Note**: The full spectrogram is never actually computed, because to do so  would be an egregious waste of memory. Instead, the centroid frequency and
amplitudes are computed for each transformed windowed piece of `song` in turn.
"""
function find_sound{T}(song::AbstractArray{T, 1}, cutoff::Real, maxsilence::Real; mindur::Real=0, maxdur::Real=-1)::Tuple{Array{Float64, 1}, Array{Float64, 1}, Array{T, 1}}
    if maxdur == -1
        maxdur = length(song)/samplerate
    end
    
    song_env = envelope_along_centroid(song, STFT.gaussian(windowlength), windowstep, lowharmonic, highharmonic, STFT.powSpec, bandwidth)
    song_env /= maximum(song_env)
    
    maxsilence *= samplerate/windowstep #Convert from seconds to indecies in song_env
    
    inasong = false
    current_silence_length = 0
    call_starts = Array{Float64, 1}(0)
    call_ends = Array{Float64, 1}(0)
    for (i, amp) in enumerate(song_env)
        if !inasong
            if amp >= cutoff
                current_silence_length = 0
                inasong = true
                push!(call_starts, i)
            end
        else
            if amp < cutoff 
                if current_silence_length <= maxsilence
                    current_silence_length += 1
                    continue
                else
                    inasong = false
                    push!(call_ends, i-maxsilence)
                    current_silence_length = 0
                end
            else
                current_silence_length = 0
            end
        end
    end
    if length(call_starts) > length(call_ends)
        push!(call_ends, length(song))
    end
    
    call_starts *= windowstep
    call_starts += Int(floor(windowlength/2))
    call_starts /= samplerate
    
    call_ends *= windowstep
    call_ends += Int(floor(windowlength/2))
    call_ends /= samplerate
    
    indshift = 0
    for i in eachindex(call_starts)
        if call_ends[i-indshift] - call_starts[i-indshift] < mindur || call_ends[i-indshift]-call_starts[i-indshift] > maxdur
            deleteat!(call_starts, i-indshift)
            deleteat!(call_ends, i-indshift)
            indshift += 1
        end
    end
    
    return call_starts, call_ends, song_env
end


"""
`function find_sound(songname::AbstractString, cutoff::Real, maxsilence::Real; mindur::Real=0, maxdur::Real=-1, make_sonograms::Bool=false)`

find_sound method that takes a filename and writes out sonograms of each sound found
Parameters:
 - `make_sonograms`: Determines whether to create and save sonograms of what was found.
"""
function find_sound(songname::AbstractString, cutoff::Real, maxsilence::Real; mindur::Real=0, maxdur::Real=-1, make_sonograms::Bool=false)
    song = wavread(songname)[1][:, 1]
    call_starts, call_ends, song_env = find_sound(song, cutoff, maxsilence, mindur=mindur, maxdur=maxdur)

    if make_sonograms
        for i in eachindex(call_starts)
	    sonog = sonogram(view(song, Int(round(call_starts[i]*samplerate)):Int(round(call_ends[i]*samplerate)))).^.5
            gr = mglGraph()
            SetRanges(gr, 0, size(sonog, 2), 0, size(sonog, 1))
            SetRange(gr, 'c', minimum(sonog), maximum(sonog))
            SetDefScheme(gr, "wrcbk")
            Dens(gr, sonog)
            #Line(gr, MathGL.mglPoint(call_starts[i], 0, 0), MathGL.mglPoint(call_starts[i], maximum(song_env), 0), "r")
            #Line(gr, MathGL.mglPoint(call_ends[i], 0, 0), MathGL.mglPoint(call_ends[i], maximum(song_env), 0), "r")
            SetRange(gr, 'x', 0, size(sonog, 2)*samplerate/windowstep)
            Axis(gr)
            MathGL.Box(gr)
            WritePNG(gr, "$songname-$i.png")
	end
    end
    
    
    return call_starts, call_ends, song_env
end

export find_sound
