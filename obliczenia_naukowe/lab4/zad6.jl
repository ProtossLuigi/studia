include("zad1234.jl")

using Plots

for i = 5:5:15
    Interpolacja.rysujNnfx(abs,-1.,1.,i)
    savefig(string("zad6a_",i))
end

f(x) = 1/(1+x^2)
for i = 5:5:15
    Interpolacja.rysujNnfx(f,-5.,5.,i)
    savefig(string("zad6b_",i))
end