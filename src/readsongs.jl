"""
    `function readsong(fname::String, starttime::Real, endtime::Real, dir::String=pwd())`
Given a file name, a working directory, a start time and an end time, read a segment of a song from a file

(note: This is primarily used as a helper function to the `readsongs_*` family of functions)
"""
function readsong(fname::String, starttime::Real, endtime::Real, dir::String=pwd())
    return wavread(dir*"/"*fname, Int(round(samplerate*starttime)):Int(round(samplerate*endtime)))[1][:, 1]
end


"""
    `function readsongs(calls::DataFrame; dir::String=pwd(), filenamecol::Symbol=:file, starttimecol::Symbol=:start_time, endtimecol::Symbol=:end_time)`

Given a DataFrame `calls`, read out each call in the DataFrame into an array of Float64 and return an array of all the arrays.

Parameters
----------
 - `calls`: A DataFrame, containing the call definitions. It must have the three following columns
 - `dir`: The directory where the files are located. Defaults to the current working directory
 - `filenamecol`: The name of the column in the DataFrame containing file names
 - `starttimecol`: The name of the column containing start times of calls
 - `endtimecol`: The name of the column containing end times of calls
Example:
--------
Given the following DataFrame:

        | Row |   Name   | start | end |
    x = |_____|__________|_______|_____|
        |  1  | rec1.wav |  0.02 | 1.6 |
        |  2  | rec1.wav |  1.9  | 3.7 |
        |  3  | rec2.wav |  3.5  | 5.1 |

The call `calls = readsongs(x, filenamecol=:Name, starttimecol=:start, endtimecol=:end)` will then
return an array containing the sound data in the file rec1.wav from .02 to 1.6 seconds, the sound data
in rec1.wav from 1.9 to 3.7 seconds, and the sound data in rec2.wav from 3.5 to 5.1 seconds.
"""

function readsongs(calls::DataFrame; dir::String=pwd(), filenamecol::Symbol=:file, starttimecol::Symbol=:start_time, endtimecol::Symbol=:end_time)
    #Check for sanity of calls
    if !haskey(calls, filenamecol)
	ArgumentError("Argument `calls` must have a column named '$filenamecol'")
    end
    if !haskey(calls, starttimecol)
	ArgumentError("Argument `calls` must have a column named '$starttimecol'")
    end
    if !haskey(calls, endtimecol)
	ArgumentError("Argument `calls` must have a column named '$endtimecol'")
    end

    nSongs = size(calls, 1)
    songs = Array{Array{Float64, 1}, 1}(nSongs)

@showprogress    for i in 1:nSongs
	songs[i] = readsong(calls[filenamecol][i], calls[starttimecol][i], calls[endtimecol][i], dir)
    end

    return songs
end


"""
    `function readsongs_dict(calls::DataFrame; dir::String=pwd(), filenamecol::Symbol=:file, starttimecol::Symbol=:start_time, endtimecol::Symbol=:end_time)`
Like `readsongs` but instead of an array, returns a dict with keys of the form 'filename_starttime-endtime'
"""
function readsongs_dict(calls::DataFrame; dir::String=pwd(), filenamecol::Symbol=:file, starttimecol::Symbol=:start_time, endtimecol::Symbol=:end_time)
    #Check for sanity of calls
    if !haskey(calls, filenamecol)
	ArgumentError("Argument `calls` must have a column named '$filenamecol'")
    end
    if !haskey(calls, starttimecol)
	ArgumentError("Argument `calls` must have a column named '$starttimecol'")
    end
    if !haskey(calls, endtimecol)
	ArgumentError("Argument `calls` must have a column named '$endtimecol'")
    end

    nSongs = size(calls, 1)
    songs = Dict{String, Array{Float64, 1}}()

@showprogress    for i in 1:nSongs
	name = calls[filenamecol][i]*"_"*"$(calls[starttimecol][i])"*"-"*"$(calls[endtimecol][i])"
	songs[name] = readsong(calls[filenamecol][i], calls[starttimecol][i], calls[endtimecol][i], dir)
    end

    return songs
end

"""
    `function readsongs_string(calls::DataFrame; dir::String=pwd(), filenamecol::Symbol=:file, starttimecol::Symbol=:start_time, endtimecol::Symbol=:end_time)`
Like readsongs_dict, but only returns an array containing what would be the keys of the dictionary
"""
function readsongs_string(calls::DataFrame; dir::String=pwd(), filenamecol::Symbol=:file, starttimecol::Symbol=:start_time, endtimecol::Symbol=:end_time)
    #Check for sanity of calls
    if !haskey(calls, filenamecol)
	ArgumentError("Argument `calls` must have a column named '$filenamecol'")
    end
    if !haskey(calls, starttimecol)
	ArgumentError("Argument `calls` must have a column named '$starttimecol'")
    end
    if !haskey(calls, endtimecol)
	ArgumentError("Argument `calls` must have a column named '$endtimecol'")
    end

    nSongs = size(calls, 1)
    songs = Array{String, 1}(nSongs)

    for i in 1:nSongs
	name = calls[filenamecol][i]*"_"*"$(calls[starttimecol][i])"*"-"*"$(calls[endtimecol][i])"
	songs[i] = name
    end

    return songs
end


export readsong
export readsongs
export readsongs_dict
export readsongs_string
