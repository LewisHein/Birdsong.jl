module Birdsong
using STFT
using WAV
using FDA
using DataFrames
using ProgressMeter

#Universal things that are package internals
include("constants.jl")
include("typealiases.jl")

#Functions that are package internals
include("dtw/dtw.jl")

#Functions that are exported for the user
include("callTrace.jl")
include("find_sound.jl")
include("readsongs.jl")
include("sonogram.jl")
include("syllableFinder.jl")
include("tonesmooth.jl")
include("visualize3d.jl")

end # module
