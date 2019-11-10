#Kajetan Bilski
using Plots
p = Float32[]
r = 3f0
append!(p,0.01f0)
for i = 1:40
    append!(p,p[end]+r*p[end]*(1-p[end]))
end
gr()
n = 0:40
#for i in x
#   print(getindex(p,i))
#end
plot(n,p,label=["bez obciecia"])
p = Float32[]
append!(p,0.01f0)
for i = 1:10
    append!(p,p[end]+r*p[end]*(1-p[end]))
end
append!(p,0.722f0+r*0.722f0*(1-0.722f0))
for i = 12:40
    append!(p,p[end]+r*p[end]*(1-p[end]))
end
plot!(n,p,label=["z obcieciem" ""])
savefig("zad5_1")
p = Float32[]
append!(p,0.01f0)
for i = 1:40
    append!(p,p[end]+r*p[end]*(1-p[end]))
end
plot(n,p,label=["Float32"])
p = Float64[]
append!(p,0.01f0)
for i = 1:40
    append!(p,p[end]+r*p[end]*(1-p[end]))
end
plot!(n,p,label=["Float64" ""])
savefig("zad5_2")