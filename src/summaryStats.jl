"""
`songlength(syllables::Array{Syllable, 1}, windowStep::Integer=windowstep, samplerate::Integer=samplerate)`
Return the length (in seconds) of a song, given the isolated syllables
"""
function songlength(syllables::Array{Syllable, 1}, windowStep::Integer=windowstep, samplerate::Integer=samplerate)
   min_t_idx = minimum(syllables[1][2])
   max_t_idx = maximum(syllables[end][2])

   song_length_idx = max_t_idx-min_t_idx
   song_length = song_length_idx * windowStep/44100

   return song_length
end


"""
`minpitch(syllables::AbstractArray{Syllable, 1}, lowHarmonic::Integer=lowharmonic, windowLength::Integer=windowlength, sampleRate::Integer=samplerate) -> minimum pitch`
Return the minimum pitch attained by any syllable in `syllables`
"""
function minpitch(syllables::AbstractArray{Syllable, 1}, lowHarmonic::Integer=lowharmonic, windowLength::Integer=windowlength, sampleRate::Integer=samplerate)
    min_pitch_idx = minimum(syll->minimum(syll[1]), syllables)
    min_pitch = harmonic2hz(min_pitch_idx, lowHarmonic, windowLength, sampleRate)
    
    return min_pitch
end


"""
`maxpitch(syllables::AbstractArray{Syllable, 1}, lowHarmonic::Integer=lowharmonic, windowLength::Integer=windowlength, sampleRate::Integer=samplerate) -> maximum pitch`
Return the maximum pitch attained by any syllable in `syllables`
"""
function maxpitch(syllables::AbstractArray{Syllable, 1}, lowHarmonic::Integer=lowharmonic, windowLength::Integer=windowlength, sampleRate::Integer=samplerate)
    max_pitch_idx = maximum(syll->maximum(syll[1]), syllables)
    max_pitch = (max_pitch_idx+lowHarmonic) * sampleRate/windowLength
    
    return max_pitch
end


"""
`pitch_distribution(syllables::AbstractArray{Syllable, 1}, lowHarmonic::Integer=lowharmonic, windowLength::Integer=windowlength, sampleRate::Integer=samplerate)`
Return the distribution of frequencies in a song
"""
function pitch_distribution(syllables::AbstractArray{Syllable, 1}, lowHarmonic::Integer=lowharmonic, windowLength::Integer=windowlength, sampleRate::Integer=samplerate)
    pool = pitch_pool(syllables, lowHarmonic, highHarmonic)
    return fit(Histogram, pool)
end


"""
`SDpitch(syllables::AbstractArray{Syllable, 1}, lowHarmonic::Integer=lowharmonic, windowLength::Integer=windowlength, sampleRate::Integer=samplerate) -> stdDev`
Compute the standard deviation of pitch in `syllables`
"""
function SDpitch(syllables::AbstractArray{Syllable, 1}, lowHarmonic::Integer=lowharmonic, windowLength::Integer=windowlength, sampleRate::Integer=samplerate)
    return std(pitch_pool(syllables, lowHarmonic, windowLength, sampleRate))
end


"""
`psong(syllables::AbstractArray{Syllable, 1}) -> proportion`
Return the proportion of time that a bird spent making noise relative to the total song time
"""
function psong(syllables::AbstractArray{Syllable, 1})
    singing_time = sum(syll->maximum(syll[2])-minimum(syll[2]), syllables)

    return singing_time/songlength(syllables)
end

"""
`syllrate(syllables::Array{Syllable, 1}, windowStep::Integer=windowstep, sampleRate::Integer=samplerate)`
Return the average number of syllables/second in `syllables`
"""
function syllrate(syllables::Array{Syllable, 1}, windowStep::Integer=windowstep, sampleRate::Integer=samplerate)
    return length(syllables)/songlength(syllables, windowStep, sampleRate)
end

"""
`bandlimits(syllables::AbstractArray, band_proportion::Float64=1, lowHarmonic::Integer=lowharmonic, windowLength::Integer=windowlength, sampleRate::Integer=samplerate) -> (min_freq, max_freq)`
return a range of frequencies that contain `band_proportion` of the histogram of frequencies of `syllables`
"""
function bandlimits(syllables::AbstractArray, band_proportion::Float64=1, lowHarmonic::Integer=lowharmonic, windowLength::Integer=windowlength, sampleRate::Integer=samplerate)
    @argcheck cutoff > 0
    @argcheck cutoff <= 1

    fpool = pitch_pool(syllables, lowHarmonic, windowLength, sampleRate)
    max_freq = quantile(fpool, .5+(cutoff/2))
    min_freq = quantile(fpool, .5-(cutoff/2))
    
    return (max_freq, min_freq)
end


"""
`bandwidth(syllables::AbstractArray, band_proportion::Float64=1, lowHarmonic::Integer=lowharmonic, windowLength::Integer=windowlength, sampleRate::Integer=samplerate)`
Return the size of the frequency range containg `band_proportion` of the histogram of frequencies in `syllables`
"""
function bandwidth(syllables::AbstractArray, band_proportion::Float64=1, lowHarmonic::Integer=lowharmonic, windowLength::Integer=windowlength, sampleRate::Integer=samplerate)
    @argcheck cutoff >= 0 && cutoff <= 1

    blim = bandlimits(syllables, band_proportion, lowHarmonic, windowLength, sampleRate)

    return blim[2]-blim[1]
end

"""Utility function to convert harmonics to pitch (in HZ)"""
function harmonic2hz(harmonic::Integer, lowHarmonic::Integer=lowharmonic, windowLength::Integer=windowlength, sampleRate::Integer=samplerate)
    return (harmonic+lowHarmonic) * sampleRate/windowLength
end

"""Utility function to extract all the frequencies in a song"""
function pitch_pool(syllables::AbstractArray{Syllable, 1}, lowHarmonic::Integer=lowharmonic, windowLength::Integer=windowlength, sampleRate::Integer=samplerate)
    pool = vcat(map(x->x[1], syllables)...)
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
