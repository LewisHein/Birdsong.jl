typealias Syllable Tuple{Array{Int, 1}, Array{Int, 1}}
typealias SyllableBox Tuple{Tuple{Int, Int}, Tuple{Int, Int}}

@doc """
 # Type aliases
 * `Syllable` is an alias for `Tuple{Array{Int, 1}, Array{Int, 1}}`
 * `SyllableBox` is an alias for `Tuple{Tuple{Int, Int}, Tuple{Int, Int}}`
""" aliased_types

const aliased_types = 0 #Never used -- this is a hack to make Documenter.jl work
