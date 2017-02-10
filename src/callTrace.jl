"""
    `function dftrace{T}(sono::Array{T, 2}, syllables::AbstractArray{SyllableBox, 1})`

Given a sonogram sono and a list of boxes around syllables that it contains,
return the dominant frequency as a function of time in each syllable

Parameters:
-----------
 - `sono` The sonogram
 - `syllables` The list of boxes around syllables

Return
------
 - An array with one member for each element of `syllables`. Each member is an array containing the index (along dimension 1) in `sono` of the dominant frequency  at each time slice in that particular syllable


    `function dftrace{T}(sono::Array{T, 2}, syllables::AbstractArray{Syllable, 1})`

A convenience method that allows syllables to be a an array of `Syllable`s rather than an array
of boxes around syllables

**Note**: see Birdsong.aliased_types for documentation on the `Syllable` and `SyllableBox` types
"""
function dftrace{T}(sono::Array{T, 2}, syllables::AbstractArray{SyllableBox, 1})
    traces = similar(syllables, Array{Int, 1})

    for (i, syll) in enumerate(syllables)
	tmin = syll[1][2]
	tmax = syll[2][2]
	fmin = syll[1][1]
	fmax = syll[2][1]

	traces[i] = Array{Int, 1}((tmax-tmin)+1)

	for (j, jnd) in enumerate(tmin:tmax)
	    traces[i][j] = fmin+findmax(sono[fmin:fmax, jnd])[2]-1
	end
    end

    return traces
end

function dftrace{T}(sono::Array{T, 2}, syllables::AbstractArray{Syllable, 1})
    return dftrace(sono, syllable_boxes(syllables))
end

export dftrace
