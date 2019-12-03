include("zad1234.jl")

r = Interpolacja.ilorazyRoznicowe([-1.0,0,1,2,4],[25.0,10,15,10,90])
if r == [25.0,-15,10,-5,2]
    println("test successful")
else
    println("test failed")
end

f(x) = x^3 + 2*x^2 + 3*x + 4
xarr = collect(1.0:4.0)
r = Interpolacja.ilorazyRoznicowe(xarr,f.(xarr))
works = true
for i = 5.:10.
    if Interpolacja.warNewton(xarr,r,i) != f(i)
        works = false
    end
end
if works
    println("test successful")
else
    println("test failed")
end

if Interpolacja.naturalna(xarr,r) == [4.,3.,2.,1.]
    println("test successful")
else
    println("test failed")
end

Interpolacja.rysujNnfx(abs,-2.,2.,4)