include("zad1.jl")
include("zad2.jl")
using Plots

function rysujNnfx(f,a::Float64,b::Float64,n::Int)
    h = (b-a)/n
    x = zeros(Float64, n+1)
    for i = 0:n
        x[i+1] = a+i*h
    end
    ir = ilorazyRoznicowe(x,f.(x))
    points = 1024
    pyplot()
    r = a:(b-a)/points:b
    w(y) = warNewton(x,ir,y)
    plot(r,w.(r))
    plot!(r,f.(r))
end