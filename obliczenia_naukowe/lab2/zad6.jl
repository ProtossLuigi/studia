using Plots
function iterate(x0,c)
    v = Float64[]
    append!(v,x0)
    for i = 1:40
        append!(v,v[end]^2+c)
    end
    return v
end
r = 0:40
gr()
c = [-2.0,-2.0,-2.0,-1.0,-1.0,-1.0,-1.0]
x = [1.0,2.0,1.99999999999999,1.0,-1.0,0.75,0.25]
for i = 1:7
    plot(r,iterate(x[i],c[i]),label=["x(n)"])
    savefig(string("zad6_",i))
end