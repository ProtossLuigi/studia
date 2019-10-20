#Kajetan Bilski
function f(x)
    return sin(x)+cos(3.0*x)
end
function fprim(x)
    return cos(x)-3.0*sin(3.0*x)
end
function fprimapprox(x,h)
    return (f(x+h)-f(x))/h
end
for n = 0:54
    h = 2.0^-n
    println("n = " * string(n) * ", " * string(abs(fprim(1.0)-fprimapprox(1.0,h))))
end