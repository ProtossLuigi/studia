# Kajetan Bilski
module MetodyLiczenia

export mbisekcji, mstycznych, msiecznych

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

function mstycznych(f,pf,x0::Float64, delta::Float64, epsilon::Float64, maxit::Int)
    if abs(f(x0)) <= epsilon
        return (x0,f(x0),0,0)
    end
    if abs(pf(x0)) <= epsilon
        return (x0,f(x0),0,2)
    end
    x1 = x0 - f(x0)/pf(x0)
    it = 1
    while abs(x1-x0) > delta && abs(f(x1)) > epsilon && it < maxit && abs(pf(x1)) > epsilon
        x0 = x1
        x1 = x1 - f(x1)/pf(x1)
        it += 1
    end
    if abs(x1-x0) <= delta || abs(f(x1)) <= epsilon
        err = 0
    elseif it >= maxit
        err = 1
    elseif abs(pf(x1)) <= epsilon
        err = 2
    else
        err = 3
    end
    return (x1,f(x1),it,err)
end

function msiecznych(f, x0::Float64, x1::Float64, delta::Float64, epsilon::Float64,maxit::Int)
    if abs(f(x0)) <= epsilon
        return (x0,f(x0),0,0)
    end
    if abs(f(x1)) <= epsilon
        return (x1,f(x1),0,0)
    end
    x2 = x1 - (x1-x0)/(f(x1)-f(x0))*f(x1)
    x0 = x1
    x1 = x2
    it = 1
    while abs(x1-x0) > delta && abs(f(x1)) > epsilon && it < maxit
        x2 = x1 - ((x1-x0)/(f(x1)-f(x0)))*f(x1)
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
end