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