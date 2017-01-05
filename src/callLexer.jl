#=function phrases(fileName::ASCIIString, cutoffPercent::Number)
  songData = collect(wavread(fileName)[1])
  songStft = stft(songData, 1, -1, stftUtils.gaussian(256), 10, 10, 64, stftUtils.powSpec)
  songTrace = centroidfrequencies(songStft)
  songEnvelope = envelope(songStft, Array{Int}(round(songTrace)), 10)
  kernelsmooth!(songEnvelope, FDA.uniform(50))

  cutoffFactor = cutoffPercent / 100;
  cutoff = maximum(songEnvelope) * cutoffFactor
  chirps = Array{Array{Float64, 1}, 1}(0)

  inAPhrase::Bool = false
  idx::Int = 0
  
  for envelopeSample in 1:size(songEnvelope, 1)
    
    if inAPhrase
      if songEnvelope[envelopeSample] > cutoff
        push!(chirps[idx], songTrace[envelopeSample])
      else
        inAPhrase = false
      end
  
  else
  
      if songEnvelope[envelopeSample] > cutoff
        push!(chirps, Array{Float64, 1}(0))
        inAPhrase = true
        idx += 1
	push!(chirps[end], songTrace[envelopeSample])
      end
    end
  end

  return chirps
end=#

"""Given a two-dimensional array that is assumed to be a sonogram of a bird song,
find the start and end times (as indecies in the time dimension of the sonogram) 
of chirps in the song This is done by finding the centroid frequencies of the sonogram
and then computing the amlpitude of the signal along the path defined by the sonogram.
Then, if a point is suffuciently small relative to the largest point in it's surroundings,
it is deemed to not be in a chirp"""
function phraseBoundaries{T}(song::AbstractArray{T, 1}, cutoffPercent::Number)
	songEnvelope = envelope_along_centroid(song, STFT.gaussian(windowlength), windowstep, lowharmonic, highharmonic, STFT.powSpec, bandwidth)
	#kernelsmooth!(songEnvelope, FDA.uniform(50))

	cutoffFactor = cutoffPercent / 100;
	cutoffWindowLength = Int(floor(size(songEnvelope, 1)/10)) # The cutoff used in deciding whether something is a chirp or not is the maximum value of the envelope inside a window of this length, multiplied by cutoffFactor
	chirps = Array{Tuple{Int64, Int64}, 1}()

	inAPhrase = false
	idx = 0

	startSample = 0
	for envelopeSample in 1:size(songEnvelope, 1)
		cutoffWindowStart = min(max(Int(round(envelopeSample-cutoffWindowLength/2)), 1), size(songEnvelope, 1)-cutoffWindowLength) #Make the window start at the beginning, stay there until envelopeSample moves past the middle, move to the end with envelopeSample, and stop there until envelopeSample gets to the end
		cutoffWindowEnd = cutoffWindowStart+cutoffWindowLength
		cutoffWindow = view(songEnvelope, cutoffWindowStart:cutoffWindowEnd)

		cutoff = maximum(cutoffWindow)*cutoffFactor
		if inAPhrase
			if songEnvelope[envelopeSample] > cutoff
				continue
			else
				push!(chirps, tuple(startSample, envelopeSample))
				inAPhrase = false
			end
		else
			if songEnvelope[envelopeSample] > cutoff
				startSample = envelopeSample
				inAPhrase = true
			end
		end
	end
	return chirps
end

"""Given the file name of a bird call, seperate it into chirps. and return the start and end times (in samples/window step, so in 4410ths of a second fo a normal audio file and a  window step of 10 samples)"""
function phraseBoundaries(fileName::AbstractString, cutoffPercent::Number)
	song = wavread(fileName)[1][:, 1]

	return phraseBoundaries(songStft, cutoffPercent)
end

"""Given a  sonogram of a bird call, seperate it into chirps and return the pitch as a function of time within those chirps"""
function phrases{T}(song::AbstractArray{T, 1}, cutoffPercent::Number)
	phraseEdges = phraseBoundaries(song, cutoffPercent)
	
	songTrace = centroidfrequencies(song, STFT.gaussian(windowlength), windowstep, lowharmonic, highharmonic, STFT.powSpec)
	phrases = Array{Array{Float64, 1}, 1}(0)

	for phrase in phraseEdges
		push!(phrases, songTrace[phrase[1]:phrase[2]])
	end

	return phrases
end

"""Given the file name of a bird call, seperate it into chirps and return the pitch as a function of time within those chirps"""
function phrases(fileName::AbstractString, cutoffPercent::Number)
	phrases(sonogram(fileName))
end

export phraseBoundaries
export phrases

