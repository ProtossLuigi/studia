# Kajetan Bilski
include("zad123.jl")

function f(x)
    return MathConstants.e^x - 3*x
end

print(MetodyLiczenia.mbisekcji(f,0.0,1.0,0.0001,0.0001),"\n")
print(MetodyLiczenia.mbisekcji(f,1.0,2.0,0.0001,0.0001),"\n")