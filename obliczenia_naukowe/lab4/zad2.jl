function warNewton(x::Vector{Float64}, fx::Vector{Float64}, t::Float64)
    n = length(x)
    nt = fx[n]
    for i = 1:n-1
        nt = (t-x[n-i])*nt+fx[n-i]
    end
    return nt
end