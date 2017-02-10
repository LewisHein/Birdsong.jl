module Birdsong
using STFT
using WAV
using FDA
using DataFrames
using ProgressMeter

include("constants.jl")
include("typealiases.jl")

include("callTrace.jl")
include("find_sound.jl")
include("readsongs.jl")
include("sonogram.jl")
include("syllableFinder.jl")
include("tonesmooth.jl")
include("visualize3d.jl")

end # module
