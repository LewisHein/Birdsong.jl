"""A helper function to turn a linear index into a 2-D Array into a row index (I.E., a position down in a column)"""
function index1(size1::Integer, index::Integer)
    @assert index > 0
    if (index%size1) != 0
	return (index%size1)
    else
	return size1
    end
end

"""A helper function to turn a linear index into a 2-D Array into a column index (I.E., a position along in a row)"""
function index2(size1::Integer, index::Integer)
    return div(index-1, size1)+1
end

"""Given dimension 1 of a 2-D array and two indecies, determine if index1 is adjacent to index2"""
function is_adjacent(size1::Integer, index1::Integer, index2::Integer)
    if abs(index1 - index2)  <=  1 || abs(abs(index1 - index2) - size1) <= 1
	return  true
    end

    return false
end


"""
 `find_syllables{T}(sonogram::AbstractArray{T, 2}, thresholdlow::T, thresholdhigh::T)`

Find syllables in a bird call, with an algorithm very similar to the one presented by [1]
    
Parameters
----------
 - `sonogram`: A sonogram of the bird call
 - `thresholdlow`: The threshold below which values in `sonogram` are judged to be noise
 - `thresholdhigh`: The threshold above which values in `sonogram` trigger the syllable search (see below)

Return value
------------
 - An `Array` of `Tuple`s of `Array`s. Element 1 of each tuple contains the first indecies (down column) and element 2 the second indecies (along row) for each element
 of `sonogram` that is part of that particular syllable.

Algorithm
---------
The algorithm is (roughly) as follows:
 1) Search through `sonogram` for values greater than `thresholdhigh`. For each such value `v`:
  1.1) If the value is already in a previously found syllable, skip it and go on to the next
  1.2) Note every index `i` in `sonogram` greater than `thresholdlow` and adjacent to the index of `v`
  1.3) Note every index `i_2` in `sonogram greater than `thresholdlow` and adjacent to `i`
  1.4) And so on, until no more adjacent values greater than `thresholdlow` are found. This clump of adjacent values constitutes one _syllable_
 Note: Steps 1.1-1.4 are what are referred to above as the "syllable search"
 Further note: The above describes what is, in effect done, but not how. How is below in the code.
"""
function find_uncombined_syllables{T}(sonogram::AbstractArray{T, 2}, thresholdlow::Real, thresholdhigh::Real)
    syllables = Array{Tuple{Array{Int, 1}, Array{Int, 1}}, 1}()
    const size1 = size(sonogram, 1)

    indecies = find(x->x>thresholdlow, sonogram)
    
    while !isempty(indecies)
	seed_index = indecies[1]
	adjacent_indecies = find(x->is_adjacent(size1, x, seed_index), indecies)
	to_add_to_adjacent_indecies = adjacent_indecies # Note: this doesn't actually get added; It's just so that the loop below will work properly the first time around

	done_adding_indecies = false
	while !done_adding_indecies
	    nadj_inds = length(adjacent_indecies)
	    last_added = to_add_to_adjacent_indecies
	    to_add_to_adjacent_indecies = Int[]
	    for index in view(indecies, last_added)
		for (j, jindex) in enumerate(indecies)
		    if is_adjacent(size1, jindex, index) && !(j in adjacent_indecies)
			push!(adjacent_indecies, j)
			push!(to_add_to_adjacent_indecies, j)
		    end
		end
	    end
	    if length(adjacent_indecies) == nadj_inds
		done_adding_indecies = true
	    end
	end
	sort!(adjacent_indecies)
		
	syllables_temp = indecies[adjacent_indecies]
	syllables_temp1 = map(i->index1(size1, i), syllables_temp)
	syllables_temp2 = map(i->index2(size1, i), syllables_temp)
	@assert !any(x->x<=0, syllables_temp1)
	@assert !any(x->x>size1, syllables_temp1)
	@assert !any(x->x<=0, syllables_temp2)
	@assert !any(x->x>size(sonogram, 2), syllables_temp2)

	
	if any(x->x>thresholdhigh, view(sonogram, syllables_temp))
	   push!(syllables, (syllables_temp1, syllables_temp2))
	end
	
	deleteat!(indecies, adjacent_indecies)
	
    end

    return syllables
end


"""
Take a set of syllables (problably output from `find_uncombined_syllables`) and combine syllables seperated by small time-gaps

Parameters
----------
 - `Syllables`: A set of syllables as an array of arrays, each array containing a set of indecies that is one syllable
 - `maxTimeGap`: The maximum time gap (in seconds) allowed between syllables before they are considered really and truly seperate
 - `conversion_factor`: The multiplier to convert maxTimeGap from units of seconds into units of indecies (which is what syllables are in).
"""
function combine_syllables(syllables_in::AbstractArray{Syllable, 1}, maxTimeGap::Real, conversion_factor::Real=samplerate/windowstep)
    maxTimeGap *= conversion_factor
    syllables_in = copy(syllables_in)
    syllables = Tuple{Array{Int, 1}, Array{Int, 1}}[]
    nsyllables = length(syllables_in)

    while length(syllables_in) > 0
        syllable_temp = [syllables_in[1][1], syllables_in[1][2]]
	todelete = Int[1]
	for i in 2:length(syllables_in)
	    max_col_syll1 = maximum(syllables_in[i-1][2])
	    min_col_syll2 = minimum(syllables_in[i][2])
	    
	    if max_col_syll1 <= (min_col_syll2 + maxTimeGap)
		syllable_temp[1] = union(syllable_temp[1], syllables_in[i][1])
		syllable_temp[2] = union(syllable_temp[2], syllables_in[i][2])
		push!(todelete, i)
	    else
		break
	    end
	end

	push!(syllables, (syllable_temp[1], syllable_temp[2]))

	deleteat!(syllables_in, todelete)
    end

    return syllables
end

"""
`function syllable_box(syllable{Tuple{Array{Int, 1}, Array{Int, 1}}})`
Returns the upper left and lower right corners of a box containing the syllable `syllable`
"""
function syllable_box(syllable::Syllable)::SyllableBox
    @assert !any(x->x==0, syllable[1])
    @assert !any(x->x==0, syllable[2])
    return ((minimum(syllable[1]), minimum(syllable[2])), (maximum(syllable[1]), maximum(syllable[2])))
end

"""
`function syllable_boxes(syllables::AbstractArray{Tuple{Array{Int, 1}, Array{Int, 1}}, 1})`
Returns the upper left and lower right corners of a box containing each syllable in `syllables`
"""
function syllable_boxes(syllables::AbstractArray{Syllable, 1})
    boxes = map(syllable_box, syllables)
#=    boxes = similar(syllables, Tuple{Tuple{Int, Int}, Tuple{Int, Int}})
    
    for (i, syll) in enumerate(syllables)
	boxes[i] = 
    end=#

    return boxes
end

export find_uncombined_syllables
export combine_syllables
export syllable_box
export syllable_boxes
