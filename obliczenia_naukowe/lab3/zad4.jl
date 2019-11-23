# Kajetan Bilski
include("zad123.jl")

function f(x)
    return sin(x) - (x/2)^2
end

function pf(x)
    return cos(x) - x/2
end

print(MetodyLiczenia.mbisekcji(f,1.5,2.0,0.000005,0.000005),"\n")
print(MetodyLiczenia.mstycznych(f,pf,1.5,0.000005,0.000005,100),"\n")
print(MetodyLiczenia.msiecznych(f,1.0,2.0,0.000005,0.000005,100),"\n")