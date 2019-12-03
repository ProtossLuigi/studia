module Interpolacja

using Plots

function ilorazyRoznicowe(x::Vector{Float64}, f::Vector{Float64})
    n = length(x)
    r = zeros(Float64, n)
    a = zeros(Float64, n)
    for i = 1:n
        r[i] = f[i]
        for k = 1:i-1
            r[i-k] = (r[i-k+1] - r[i-k])/(x[i] - x[i-k])
        end
        a[i] = r[1]
    end
    return a
end

function warNewton(x::Vector{Float64}, fx::Vector{Float64}, t::Float64)
    n = length(x)
    nt = fx[n]
    for i = 1:n-1
        nt = (t-x[n-i])*nt+fx[n-i]
    end
    return nt
end

function naturalna(x::Vector{Float64}, fx::Vector{Float64})
    n = length(x)
    a = zeros(Float64, n)
    a[n] = fx[n]
    for i = 1:n-1
        a[n-i] = fx[n-i]
        for k = n-i:n-1
            a[k] = a[k]-x[n-i]*a[k+1]
        end
    end
    return a
end

function rysujNnfx(f,a::Float64,b::Float64,n::Int)
    h = (b-a)/n
    x = zeros(Float64, n+1)
    for i = 0:n
        x[i+1] = a+i*h
    end
    ir = ilorazyRoznicowe(x,f.(x))
    points = 100
    pyplot()
    r = a:(b-a)/points:b
    w(y) = warNewton(x,ir,y)
    plot(r,w.(r))
    plot!(r,f.(r))
end
end