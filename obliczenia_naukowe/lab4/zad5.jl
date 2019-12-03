include("zad1234.jl")

using Plots

f(x) = MathConstants.e^x
for i = 5:5:15
    Interpolacja.rysujNnfx(f,0.,1.,i)
    savefig(string("zad5a_",i))
end

f(x) = (x^2)*sin(x)
for i = 5:5:15
    Interpolacja.rysujNnfx(f,-1.,1.,i)
    savefig(string("zad5b_",i))
end