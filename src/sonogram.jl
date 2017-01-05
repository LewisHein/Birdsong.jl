"""Given the name of a file that is assumed to be a single-channel audio file
containing a birdsong, compute the sonogram of the song in the file.

The defaults of this  function have been written to work well on songs of the house wren. 
They may or may not do well for other species. See stft for docs on the parameters"""
function sonogram{T}(fileName::AbstractString; window::AbstractArray{T, 1}=STFT.gaussian(windowlength), windowStep::Integer = windowstep, lowHarmonic::Integer = lowharmonic, highHarmonic::Integer = highharmonic, transformation::Function=STFT.powSpec)
	songData::Array{Float64, 1} = collect(wavread(fileName)[1])::Array{T, 1}
	return sonogram(songData, window, windowStep, lowHarmonic, highHarmonic, transformation)
end

"""Given an array containing a birdsong read from an audio file, compute the sonogram of the song in the file.

The defaults of this  function have been written to work well on songs of the house wren. 
They may or may not do well for other species. See stft for docs on the parameters"""
function sonogram{T}(songData::AbstractArray{T, 1}; window::AbstractArray{T, 1}=STFT.gaussian(windowlength), windowStep::Integer = windowstep, lowHarmonic::Integer = lowharmonic, highHarmonic::Integer = highharmonic, transformation::Function=STFT.powSpec)
	sono = log10.(stft(songData, window, windowStep, lowHarmonic, highHarmonic, transformation))
	sonoMin = maximum(sono) - lowCutOff

	for (i, x) in enumerate(sono)
	    if x < sonoMin
		sono[i] = sonoMin
	    end
	end
	
	sono .-= sonoMin
	return sono
end

export sonogram
