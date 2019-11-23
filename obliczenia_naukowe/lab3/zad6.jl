# Kajetan Bilski
include("zad123.jl")

function f1(x)
    return MathConstants.e^(1-x)-1
end

function f2(x)
    return x*MathConstants.e^-x
end

function pf1(x)
    return -MathConstants.e^(1-x)
end

function pf2(x)
    return MathConstants.e^-x-x*MathConstants.e^-x
end

print(MetodyLiczenia.mbisekcji(f1,0.0,1.5,0.00001,0.00001),"\n")

print(MetodyLiczenia.mstycznych(f1,pf1,0.5,0.0001,0.0001,20),"\n")

print(MetodyLiczenia.msiecznych(f1,0.0,2.0,0.0001,0.0001,20),"\n")

print(MetodyLiczenia.mbisekcji(f2,-0.5,1.0,0.0001,0.0001),"\n")

print(MetodyLiczenia.mstycznych(f2,pf2,0.5,0.0001,0.0001,20),"\n")

print(MetodyLiczenia.msiecznych(f2,1.0,0.5,0.0001,0.0001,20),"\n")

print(MetodyLiczenia.mstycznych(f1,pf1,7.0,0.0001,0.0001,20),"\n")

print(MetodyLiczenia.mstycznych(f2,pf2,1.1,0.0001,0.0001,20),"\n")

print(MetodyLiczenia.mstycznych(f2,pf2,1.0,0.0001,0.0001,20),"\n")