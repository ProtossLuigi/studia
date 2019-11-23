# Kajetan Bilski
function mbisekcji(f, a::Float64, b::Float64, delta::Float64, epsilon::Float64)
    if sign(f(a)) == sign(f(b))
        return (0,0,0,1)
    end
    it = 0
    c = (b-a)/2+a
    while b-a > delta && abs(f(c)) > epsilon
        if sign(f(a)) == sign(f(c))
            a = c
        else
            b = c
        end
        c = (b-a)/2+a
        it += 1
    end
    return (c,f(c),it,0)
end