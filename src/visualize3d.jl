using Splines
using MathGL
function visualize3d{T}(song::AbstractArray{T, 1})
#Draw the sonogram
	sonog = sonogram(song, transformation=STFT.powSpec);
	sonogramMax = maximum(sonog)
	ops = plotOpStack()
	push!(ops, gr->Zoom(gr, -.3, 1.3, -.3, 1.3))
	push!(ops, gr->SetRanges(gr, 0, size(sonog, 2), 0, size(sonog, 1), minimum(sonog), maximum(sonog)))
	push!(ops, gr->SetRange(gr, 'c', minimum(sonog), maximum(sonog)))
	push!(ops, gr->Surf(gr, sonog), "Surface")
#	ops = Surf(sonog)

	insert!(ops, 2, gr->Alpha(gr, true))
#	insert!(ops, 2, gr->SetAlphaDef(gr, .09), "Set transparency value")
	insert!(ops, 2, gr->SetDefScheme(gr, "Wrcbk")) #Set the color scheme

#Draw just a color map
	push!(ops, gr->Dens(gr, sonog), "Color map")

#Draw the chirps.
	function drawChirpsFlat(gr::mglGraph)
		for i in 1:size(phr, 1)
			Plot(gr, [Float64(i) for i in phrb[i][1]:phrb[i][2]], phr[i], [sonogramMax for i in phrb[i][1]:phrb[i][2]], "b=")
		end
	end

	push!(ops, drawChirpsFlat, "Draw chirps")

#Draw the pitch as a function of time, with amplituide information
	sonogramTrace = centroidfrequencies(song, STFT.gaussian(windowlength), windowstep, lowharmonic, highharmonic, STFT.powSpec)
	env = envelope_along_centroid(song, STFT.gaussian(windowlength), windowstep, lowharmonic, highharmonic, STFT.powSpec, 4)
	push!(ops, gr->Area(gr, [i for i in 1:size(sonogramTrace, 1)], sonogramTrace, env, "y", "legend 'Pitch and volume vs time'"), "Pitch and volume vs. time")
	push!(ops, gr->Plot(gr, [i for i in 1:size(sonogramTrace, 1)], sonogramTrace, [sonogramMax for i in 1:size(sonogramTrace, 1)], "u:", "legend 'Pitch vs. time'"), "Pitch vs time")
	push!(ops, gr->Plot(gr, [i for i in 1:size(sonogramTrace, 1)], [0 for i in 1:size(sonogramTrace, 1)], env, "n", "legend Volume"), "Volume vs time")


#Get the phrases in the song
	phr = phrases(song, 10);
	phrb = phraseBoundaries(song, 10);
	if size(phrb, 1) == 0
		return ops
	end
	songStart = phrb[1][1]
	songEnd = phrb[end][2]
	push!(ops, gr->Mark(gr, [Float64(mean(i)) for i in phrb], [Float64(mean(i)) for i in phr], [sonogramMax for i in phrb], [Float64(size(i, 1))/100 for i in phr], "ro", "legend 'Chirp mean frequencies'"), "Mark chirp means")

boundPlaneHeight = maximum(sonog)/20 #The height of the planes drawn at the chirp boundaries

#Draw planes at the boundaries of the chirps
	function drawBoundsPlanes(gr::mglGraph)
		Alpha(gr, true)
		SetTranspType(gr, 1)
		for i in phrb
			FaceX(gr, mglPoint(i[1], 0, 0), 54, boundPlaneHeight, "H")
			FaceX(gr, mglPoint(i[2], 0, 0), 54, boundPlaneHeight, "H")
		end
	end

	push!(ops, drawBoundsPlanes, "Draw planes at chirp boundaries")

#Draw lines at the boundaries of the chirps
	lineBoundStyle = "r="
	function drawBoundsLines(gr::mglGraph)
		Alpha(gr, true)
		SetTranspType(gr, 1)
		for i in phrb
			Line(gr, mglPoint(i[1], 0, 0), mglPoint(i[1], 54, 0), lineBoundStyle)
			Line(gr, mglPoint(i[2], 0, 0), mglPoint(i[2], 54, 0), lineBoundStyle)
		end
	end

	push!(ops, drawBoundsLines, "Draw lines at chirp boundaries")
	push!(ops, gr->AddLegend(gr, "Chirp Boundaries", lineBoundStyle), "Set linestyle for lines at chirp boundaries")

#Draw smoothed pitch as a function of time
	chirpTimes = [Float64(mean(i)) for i in phrb]
	tone = [Float64(mean(i)) for i in phr] #Pitch as a function of time, only defined in the chirps.
	if length(chirpTimes) > 1 #Handle the case where chirpTimes is empty
		toneSpline = Spline(chirpTimes, tone)
		toneStart = mean(phrb[1])
		toneEnd = mean(phrb[end])
		toneSmooth = [Float64(toneSpline(Float64(i))) for i in toneStart:10:toneEnd]
		push!(ops, gr->Plot(gr, [ i for i in toneStart:(toneEnd-toneStart)/(size(toneSmooth, 1)-1):toneEnd], toneSmooth, [sonogramMax for i in toneSmooth], "g2", "legend 'Smoothed pitch vs time'"), "Draw smooth tone")
	else
		warn("Empty chirpTimes; will not plot smoothed pitch")
	end

#Legend
	push!(ops, gr->Legend(gr, 3, "Wbk#"), "Legend")

#Axes, colorbar, and labels
	push!(ops, gr->Label(gr, 'x', "Time (seconds)"))
	push!(ops, gr->Label(gr, 'y', "Frequency (Hz)"))
	push!(ops, gr->Label(gr, 'z', "Amplitude"))

	push!(ops, gr->SetRanges(gr, 0, size(sonog, 2)*windowstep/samplerate, (samplerate/windowlength)*lowharmonic, (samplerate/windowlength)*highharmonic), ) 
	push!(ops, gr->MathGL.Box(gr))
	push!(ops, gr->Axis(gr))
	push!(ops, gr->Colorbar(gr));

	return ops
end

export visualize3d
