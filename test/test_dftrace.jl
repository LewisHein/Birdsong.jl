#Note -- depends on test_syllablize.jl running first.
info("Testing syllable dominant frequency tracing...")

@test dftrace(a, syllables_boxed) == [[3, 3], [4, 2], [3]]
@test dftrace(a, syllables) == dftrace(a, syllables_boxed)
