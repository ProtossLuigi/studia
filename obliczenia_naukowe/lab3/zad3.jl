# Kajetan Bilski
function msiecznych(f, x0::Float64, x1::Float64, delta::Float64, epsilon::Float64,maxit::Int)
    if f(x0) <= epsilon
        return (x0,f(x0),0,0)
    end
    if f(x1) <= epsilon
        return (x1,f(x1),0,0)
    end
    x2 = x1 - (x1-x0)/(f(x1)-f(x0))
    x0 = x1
    x1 = x2
    it = 1
    while abs(x1-x0) > delta && abs(f(x1)) > epsilon && it < maxit
        x2 = x1 - (x1-x0)/(f(x1)-f(x0))
        x0 = x1
        x1 = x2
        it += 1
    end
    if abs(x1-x0) <= delta || abs(f(x1)) <= epsilon
        err = 0
    else
        err = 1
    end
    return (x1,f(x1),it,err)
end