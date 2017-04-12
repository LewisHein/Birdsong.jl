info("Testing syllable finding...")

const sizea = 5
@test is_adjacent(sizea, 2, 2)
@test is_adjacent(sizea, 1, 2)
@test is_adjacent(sizea, 3, 2)
@test is_adjacent(sizea, 2, 6)
@test is_adjacent(sizea, 2, 7)
@test is_adjacent(sizea, 8, 2)
@test !is_adjacent(sizea, 2, 9)


a = [[1, 2, 3, 3, 2, 1] [1, 2, 4, 2, 2, 1] [1, 1, 1, 1, 1, 1] [1, 2, 3, 3, 2, 1] [1, 2, 3, 2, 2, 1] [1, 1, 1, 1, 1, 1] [1, 2, 3, 5, 1, 1] [1, 2, 2, 1, 1, 1] [1, 1, 1, 1, 1, 1] [1, 1, 3, 1, 1, 1] [1, 2, 3, 1, 2, 3] [3, 3, 3, 3, 3, 3] [1, 1, 1, 1, 1, 1] [1, 2, 4, 2, 3, 1] [1, 1, 1, 1, 1, 1]]
syllables = find_uncombined_syllables(a, 1.5, 3.5)
syllables_combined = combine_syllables(syllables, 4, 1)
syllables_boxed = syllable_boxes(syllables)

@test syllables == [Syllable([2, 3, 4, 5, 2, 3, 4, 5], [1, 1, 1, 1, 2, 2, 2, 2]), Syllable([2, 3, 4, 2, 3], [7, 7, 7, 8, 8]), Syllable([2, 3, 4, 5], [14, 14, 14, 14])]
@test syllables == combine_syllables(syllables, 3, 1) 
@test syllables_combined == [Syllable([2, 3, 4, 5, 2, 3, 4, 5, 2, 3, 4, 2, 3], [1, 1, 1, 1, 2, 2, 2, 2, 7, 7, 7, 8, 8]), Syllable([2, 3, 4, 5], [14, 14, 14, 14])]
@test syllables_boxed == [SyllableBox(2, 1, 5, 2), SyllableBox(2, 7, 4, 8), SyllableBox(2, 14, 5, 14)]
