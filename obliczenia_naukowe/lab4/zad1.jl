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