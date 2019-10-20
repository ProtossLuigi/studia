#Kajetan Bilski
function f(x)
    return sqrt(x*x+1)-1
end
function g(x)
    return (x*x)/(sqrt(x*x+1)+1)
end
for i = 1:16
    println("f(8^-" * string(i) * ") = " * string(f(8e0^-i)))
    println("g(8^-" * string(i) * ") = " * string(g(8e0^-i)))
end