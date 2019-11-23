# Kajetan Bilski
include("zad123.jl")

function linear(x)
    return x*2
end

function two(x)
    return 2
end

function logd(x)
    return 1/x
end

function polynomial(x)
    return x^3 - 1
end

function polyd(x)
    return 6*(x^2)
end

function test()

    t = MetodyLiczenia.mbisekcji(cos,0.0,4.0,0.00001,0.000001)
    if isapprox(Float64(pi)/2,t[1]; atol = 0.00001)
        print("test successful\n")
    else
        print("test failed\n")
    end

    t = MetodyLiczenia.mbisekcji(cos,0.0,Float64(pi),0.00001,0.000001)
    if t[3] > 0
        print("test failed\n")
    else
        print("test successful\n")
    end

    t = MetodyLiczenia.mbisekcji(cos,0.1,0.2,0.00001,0.000001)
    if t[4] != 1
        print("test failed\n")
    else
        print("test successful\n")
    end

    t = MetodyLiczenia.mstycznych(linear,two,2.0,0.00001,0.000001,1)
    if isapprox(t[1],0.0; atol = 0.00001)
        print("test successful\n")
    else
        print("test failed\n")
    end

    t = MetodyLiczenia.mstycznych(log,logd,2.0,0.00001,0.000001,10)
    if isapprox(t[1],1.0; atol = 0.00001)
        print("test successful\n")
    else
        print("test failed\n")
    end

    t = MetodyLiczenia.msiecznych(linear,4.0,2.0,0.00001,0.000001,10)
    if isapprox(t[1],0.0; atol = 0.00001)
        print("test successful\n")
    else
        print("test failed\n")
    end

    t = MetodyLiczenia.msiecznych(polynomial,2.0,2.5,0.00000001,0.00000001,200)
    if isapprox(t[1],1.0; atol = 0.00000001)
        print("test successful\n")
    else
        print("test failed\n")
    end
end

test()