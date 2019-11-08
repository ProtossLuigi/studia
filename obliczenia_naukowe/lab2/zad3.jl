# Kajetan Bilski
using LinearAlgebra
using Plots
include("hilb.jl")
include("matcond.jl")
function hilb_gauss(n)
    A = hilb(n)
    x = fill(1,(n,1))
    b = A*x
    approxx = A\b
    return norm(approxx - x)/norm(x)
end

function hilb_inv(n)
    A = hilb(n)
    x = fill(1,(n,1))
    b = A*x
    approxx = inv(A)*b
    return norm(approxx - x)/norm(x)
end

function matcond_gauss(n,c)
    A = matcond(n,Float64(c))
    x = fill(1,(n,1))
    b = A*x
    approxx = A\b
    return norm(approxx - x)/norm(x)
end

function matcond_inv(n,c)
    A = matcond(n,Float64(c))
    x = fill(1,(n,1))
    b = A*x
    approxx = inv(A)*b
    return norm(approxx - x)/norm(x)
end

function gauss_mean(n,c,r)
    s = 0
    for i = 1:r
        s += matcond_gauss(n,c)
    end
    return s/r
end

function inv_mean(n,c,r)
    s = 0
    for i = 1:r
        s += matcond_inv(n,c)
    end
    return s/r
end
n = 2:300
gr()
plot(n,hilb_gauss.(n))
savefig("hilbert_gauss")
plot(n,hilb_inv.(n))
savefig("hilbert_inwersja")
io = open("hilbert_gauss.csv","w")
write(io,"n,val\n")
for i in n
    write(io,string(i,",",hilb_gauss(i),"\n"))
end
close(io)
io = open("hilbert_inwersja.csv","w")
write(io,"n,val\n")
for i in n
    write(io,string(i,",",hilb_inv(i),"\n"))
end
close(io)
n = (5,10,20)
c = (1,10,10^3,10^7,10^12,10^16)
r = 1000
io = open("matcond_gauss.csv","w")
write(io,"n,c,val\n")
for i in n
    for j in c
        write(io,string(i,",",j,",",gauss_mean(i,j,r),"\n"))
    end
end
close(io)
io = open("matcond_inwersja.csv","w")
write(io,"n,c,val\n")
for i in n
    for j in c
        write(io,string(i,",",j,",",inv_mean(i,j,r),"\n"))
    end
end
close(io)