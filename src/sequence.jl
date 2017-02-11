#=
Note: This file was taken from the TimeWarp.jl package

The TimeWarp.jl package is licensed under the MIT "Expat" License:

> Copyright (c) 2016: Alex Williams and Joseph Fowler
> 
> Permission is hereby granted, free of charge, to any person obtaining a copy
> of this software and associated documentation files (the "Software"), to deal
> in the Software without restriction, including without limitation the rights
> to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
> copies of the Software, and to permit persons to whom the Software is
> furnished to do so, subject to the following conditions:
> 
> The above copyright notice and this permission notice shall be included in all
> copies or substantial portions of the Software.
> 
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
> IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
> FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
> AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
> LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
> OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> SOFTWARE.
=#

using Base.Cartesian

"""
    Sequence{N,T}(::AbstractArray)

A `Sequence` is a thin wrapper around a multi-dimensional array that 
allows you to index it like a vector. For example, the following
code shows a 10-dimensional time series, sampled at 100 time points:

```
data = randn(10,100)
seq = Sequence(data)
seq[1] == data[:,1] # true
```

This generalizes to higher-order arrays. Consider a time series
where a 10x10 matrix of data is collected at 100 time points:

```
data = randn(10,10,100)
seq = Sequence(data)
seq[1] == data[:,:,1] # true
```
"""
immutable Sequence{N,T} <: AbstractArray{T,1}
    val::AbstractArray{T,N}
end

Base.size{N}(x::Sequence{N}) = (size(x.val,N),)
Base.eltype{N,T}(x::Sequence{N,T}) = T

@generated function Base.getindex{N}(x::Sequence{N}, i)
    :( x.val[@ntuple($N, (n-> n==$N ? i : Colon()))...] )
end

@generated function Base.setindex!{N}(x::Sequence{N}, val, i)
    :( x.val[@ntuple($N, (n-> n==$N ? i : Colon()))...] = val )
end
