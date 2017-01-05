"""Return the pitch of the song as a function of time, heavily smoothed and as a spline"""
function tonespline{T}(song::AbstractArray{T, 1})
	phr = phrases(song, 3.5)
	phrBounds = phraseBoundaries(song, 3.5)
	chirpCenterTimes = [mean(chirp) for chirp in phrBounds]
	chirpCenterTimes /= samplerate/windowstep
	tone = [Float64(mean(i)) for i in phr]
	tone *= samplerate/windowlength
	toneSpline = Spline(chirpCenterTimes, tone)
	return toneSpline
end

function tonespline(filename::AbstractString)
	tonespline(wavread(filename)[1][:, 1])	
end

"""Return the pitch of the bird song as a function of time, heavily smoothed"""
function tonesmooth{T}(song::AbstractArray{T, 1})
	toneSpline = tonespline(song)
	songStart = toneSpline.knots[1]
	songEnd = toneSpline.knots[end]
	return [Float64(toneSpline(Float64(i))) for i in songStart:10:songEnd] #FIXME: why 10?
end

function tonesmooth(filename::AbstractString)
	tonesmooth(wavread(filename)[1][:, 1])
end

export tonesmooth
export tonespline
