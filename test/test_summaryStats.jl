# Depends on test_syllablize to run
info("Testing summary statistics...")

import Birdsong: samplerate, windowstep, lowharmonic, windowlength, harmonic2hz, timeslice2sec, pitch_pool, fit, Histogram

#test harmonic to frequency conversion
@test harmonic2hz(5, 5, 128, 1280) == 100
@test harmonic2hz(10, 20, 200, 1000) == 150

#Test conversion of time slices to seconds
@test timeslice2sec(10) == 10*windowstep/samplerate
@test timeslice2sec(10, 2, 1000) == 10/500

#Test songlength
@test songlength(syllables) == 13*windowstep/samplerate
@test songlength(syllables, 1, 1) == 13

#Test extraction of frequency pool
@test pitch_pool(syllables) == harmonic2hz.(vcat(map(s->s.harmonics, syllables)...))

#Test min and max pitch
@test minpitch(syllables) ==  (2+lowharmonic) * samplerate/windowlength
@test maxpitch(syllables) == (5+lowharmonic) * samplerate/windowlength

#TODO: write tests for pitch_distribution and sdpitch

#Test computing pitch standard deviation
@test SDpitch(syllables) == std(pitch_pool(syllables))

#Test computing a histogram of pitches
@test pitch_distribution(syllables) == fit(Histogram, pitch_pool(syllables))

#Test psong
@test psong(syllables, 1, 1) == 5/13

#Test syllable rate
@test syllrate(syllables) == 3/songlength(syllables)

#Test bandwidth computation
@test bandlimits(syllables) == (minpitch(syllables), maxpitch(syllables))

