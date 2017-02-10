using Birdsong
import Birdsong: is_adjacent
using Base.Test

# write your own tests here

const sizea = 5
@test is_adjacent(sizea, 2, 2)
@test is_adjacent(sizea, 1, 2)
@test is_adjacent(sizea, 3, 2)
@test is_adjacent(sizea, 2, 6)
@test is_adjacent(sizea, 2, 7)
@test is_adjacent(sizea, 8, 2)
@test !is_adjacent(sizea, 2, 9)


a = [[1, 2, 3, 3, 2, 1] [1, 2, 4, 2, 2, 1] [1, 1, 1, 1, 1, 1] [1, 2, 3, 3, 2, 1] [1, 2, 3, 2, 2, 1]]
syllables = find_syllables(a, 1.5, 3.5)


@test syllables == Set([2, 3, 4, 5, 8, 9, 10, 11])
