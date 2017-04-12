"""
`songlength{T}(syllables::Array{Syllable{T}, 1}, windowStep::Integer=windowstep, samplerate::Integer=samplerate)`
Return the length (in seconds) of a song, given the isolated syllables
"""
function songlength{T}(syllables::Array{Syllable{T}, 1}, windowStep::Integer=windowstep, sampleRate::Integer=samplerate)
   min_t_idx = minimum(syllables[1].times)
   max_t_idx = maximum(syllables[end].times)

   song_length_idx = max_t_idx-min_t_idx
   song_length = timeslice2sec(song_length_idx, windowStep, sampleRate)

   return song_length
end


"""
`minpitch{T}(syllables::AbstractArray{Syllable{T}, 1}, lowHarmonic::Integer=lowharmonic, windowLength::Integer=windowlength, sampleRate::Integer=samplerate) -> minimum pitch`
Return the minimum pitch attained by any syllable in `syllables`
"""
function minpitch{T}(syllables::AbstractArray{Syllable{T}, 1}, lowHarmonic::Integer=lowharmonic, windowLength::Integer=windowlength, sampleRate::Integer=samplerate)
    min_harmonic = minimum(syll->minimum(syll.harmonics), syllables)
    min_pitch = harmonic2hz(min_harmonic, lowHarmonic, windowLength, sampleRate)
    
    return min_pitch
end


"""
`maxpitch{T}(syllables::AbstractArray{Syllable{T}, 1}, lowHarmonic::Integer=lowharmonic, windowLength::Integer=windowlength, sampleRate::Integer=samplerate) -> maximum pitch`
Return the maximum pitch attained by any syllable in `syllables`
"""
function maxpitch{T}(syllables::AbstractArray{Syllable{T}, 1}, lowHarmonic::Integer=lowharmonic, windowLength::Integer=windowlength, sampleRate::Integer=samplerate)
    max_harmonic = maximum(syll->maximum(syll.harmonics), syllables)
    max_pitch = harmonic2hz(max_harmonic, lowHarmonic, windowLength, sampleRate)
    
    return max_pitch
end


"""
`pitch_distribution{T}(syllables::AbstractArray{Syllable{T}, 1}, lowHarmonic::Integer=lowharmonic, windowLength::Integer=windowlength, sampleRate::Integer=samplerate)`
Return the distribution of frequencies in a song
"""
function pitch_distribution{T}(syllables::AbstractArray{Syllable{T}, 1}, lowHarmonic::Integer=lowharmonic, windowLength::Integer=windowlength, sampleRate::Integer=samplerate)
    pool = pitch_pool(syllables, lowHarmonic, windowLength, sampleRate)
    return fit(Histogram, pool)
end


"""
`SDpitch{T}(syllables::AbstractArray{Syllable{T}, 1}, lowHarmonic::Integer=lowharmonic, windowLength::Integer=windowlength, sampleRate::Integer=samplerate) -> stdDev`
Compute the standard deviation of pitch in `syllables`
"""
function SDpitch{T}(syllables::AbstractArray{Syllable{T}, 1}, lowHarmonic::Integer=lowharmonic, windowLength::Integer=windowlength, sampleRate::Integer=samplerate)
    return std(pitch_pool(syllables, lowHarmonic, windowLength, sampleRate))
end


"""
`psong{T}(syllables::AbstractArray{Syllable{T}, 1}) -> proportion`
Return the proportion of time that a bird spent making noise relative to the total song time
"""
function psong{T}(syllables::AbstractArray{Syllable{T}, 1}, windowStep::Integer=windowstep, sampleRate::Integer=samplerate)
    singing_timeslices = sum(syll->maximum(syll.times)-minimum(syll.times)+1, syllables)
    singing_time = timeslice2sec(singing_timeslices, windowStep, sampleRate)

    return singing_time/songlength(syllables, windowStep, sampleRate)
end

"""
`syllrate{T}(syllables::Array{Syllable{T}, 1}, windowStep::Integer=windowstep, sampleRate::Integer=samplerate)`
Return the average number of syllables/second in `syllables`
"""
function syllrate{T}(syllables::Array{Syllable{T}, 1}, windowStep::Integer=windowstep, sampleRate::Integer=samplerate)
    return length(syllables)/songlength(syllables, windowStep, sampleRate)
end

"""
`bandlimits{T}(syllables::AbstractArray{Syllable{T}, band_proportion::Float64=1, lowHarmonic::Integer=lowharmonic, windowLength::Integer=windowlength, sampleRate::Integer=samplerate) -> (min_freq, max_freq)`
return a range of frequencies that contain `band_proportion` of the histogram of frequencies of `syllables`
"""
function bandlimits{T}(syllables::AbstractArray{Syllable{T}, 1}, band_proportion::Float64=1.0, lowHarmonic::Integer=lowharmonic, windowLength::Integer=windowlength, sampleRate::Integer=samplerate)
    @argcheck (band_proportion > 0) && (band_proportion <=1)

    fpool = pitch_pool(syllables, lowHarmonic, windowLength, sampleRate)
    max_freq = quantile(fpool, .5+(band_proportion/2))
    min_freq = quantile(fpool, .5-(band_proportion/2))
    
    return (min_freq, max_freq)
end


"""
`bandwidth{T}(syllables::AbstractArray{Syllable{T}}, band_proportion::Float64=1, lowHarmonic::Integer=lowharmonic, windowLength::Integer=windowlength, sampleRate::Integer=samplerate)`
Return the size of the frequency range containg `band_proportion` of the histogram of frequencies in `syllables`
"""
function bandwidth{T}(syllables::AbstractArray{Syllable{T}, 1}, band_proportion::Float64=1, lowHarmonic::Integer=lowharmonic, windowLength::Integer=windowlength, sampleRate::Integer=samplerate)
    @argcheck cutoff >= 0 && cutoff <= 1

    blim = bandlimits(syllables, band_proportion, lowHarmonic, windowLength, sampleRate)

    return blim[2]-blim[1]
end

"""Utility function to convert harmonics to pitch (in HZ)"""
function harmonic2hz(harmonic::Integer, lowHarmonic::Integer=lowharmonic, windowLength::Integer=windowlength, sampleRate::Integer=samplerate)
    return (harmonic+lowHarmonic) * sampleRate/windowLength
end

"""Utility function to convert time slices (in number of windows) to seconds"""
#### NOTE: the psong function above impliticly assumes that this function distributes over addition (because right now it is just a scalar multiplication)
#### Don't change this without making sure that every other function is updated as necessary.
function timeslice2sec(timeslice::Integer, windowStep::Integer=windowstep, sampleRate::Integer=samplerate)
    return timeslice * windowStep/sampleRate
end


"""Utility function to extract all the frequencies in a song"""
function pitch_pool{T}(syllables::AbstractArray{Syllable{T}, 1}, lowHarmonic::Integer=lowharmonic, windowLength::Integer=windowlength, sampleRate::Integer=samplerate)
    pool = vcat(map(x->x.harmonics, syllables)...)
    pitchPool = map(x->harmonic2hz(x, lowHarmonic, windowLength, sampleRate), pool)

    return pitchPool
end

export songlength
export minpitch
export maxpitch
export SDpitch
export pitch_distribution
export psong
export syllrate
export bandlimits
export bandwidth
