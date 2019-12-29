module blocksys

using SparseArrays, DelimitedFiles, LinearAlgebra

export A

A = sparse([],[],[])
ref = zeros(0)
nzCount = zeros(0)
x = zeros(0)
b = zeros(0)
n = 0
l = 0

function loadMatrix(filename)
    data = readdlm(filename,' ')
    global n = data[1,1]
    global l = data[1,2]
    s = size(data,1)
    I = zeros(s-1)
    J = zeros(s-1)
    V = zeros(s-1)
    for i = 2:s
        I[i-1] = data[i,1]
        J[i-1] = data[i,2]
        V[i-1] = data[i,3]
    end
    global A = sparse(I,J,V)
end

function loadVector(filename)
    data = readdlm(filename,' ')
    global b = zeros(Int(data[1]))
    for i = 1:Int(data[1])
        b[i] = data[i+1]
    end
end

function swapLines(iteration,toY)
    global A,b,ref
    lineToSwap = iteration
    for i = iteration+1:toY
        if abs(A[ref[i],iteration]) > abs(A[ref[lineToSwap],iteration])
            lineToSwap = i
        end
    end
    if lineToSwap != iteration
        temp = ref[iteration]
        ref[iteration] = ref[lineToSwap]
        ref[lineToSwap] = temp
    end
end

function elimination(withChoice)
    global n,l,A,b,x,ref
    x = zeros(n)
    v = Int(n / l)
    ref = collect(1:n)
    if v == 1
        for i = 1:n
            if withChoice
                swapLines(i,n)
            end
            for j = i+1:n
                lij = A[ref[j],i] / A[ref[i],i]
                for k = i:n
                    A[ref[j],k] -= lij * A[ref[i],k]
                end
                b[ref[j]] -= lij * b[ref[i]]
            end
        end
        for i = 0:n-1
            x[n-i] = b[ref[n-i]]
            for j = 0:i-1
                x[n-i] -= A[ref[n-i],n-j] * x[n-j]
            end
            x[n-i] /= A[ref[n-i],n-i]
        end
    else
        for i = 1:l-2
            if withChoice
                swapLines(i,l)
            end
            for j = i+1:l
                lij = A[ref[j],i] / A[ref[i],i]
                for k = i:l*2
                    A[ref[j],k] -= lij * A[ref[i],k]
                end
                b[ref[j]] -= lij * b[ref[i]]
            end
        end
        for block = l-1:l:n-2*l-1
            for i = block:block+l-1
                if withChoice
                    swapLines(i,block+l+1)
                end
                for j = i+1:block+l+1
                    lij = A[ref[j],i] / A[ref[i],i]
                    for k = i:block+2*l+1
                        A[ref[j],k] -= lij * A[ref[i],k]
                    end
                    b[ref[j]] -= lij * b[ref[i]]
                end
            end
        end
        for i = n-l-1:n-1
            if withChoice
                swapLines(i,n)
            end
            for j = i+1:n
                lij = A[ref[j],i] / A[ref[i],i]
                for k = i:n
                    A[ref[j],k] -= lij * A[ref[i],k]
                end
                b[ref[j]] -= lij * b[ref[i]]
            end
        end
        for i = 0:n-1
            x[n-i] = b[ref[n-i]]
            for j = if (i > 2*l+2) i-2*l-2:i-1 else 0:i-1 end
                x[n-i] -= A[ref[n-i],n-j] * x[n-j]
            end
            x[n-i] /= A[ref[n-i],n-i]
        end
    end
end

function decomposition(withChoice)
    global n,l,A,ref,nzCount
    v = Int(n / l)
    ref = collect(1:n)
    nzCount = [Array{Int,1}(zeros(0)) for i = 1:n]
    if v == 1
        for i = 1:n
            if withChoice
                swapLines(i,n)
            end
            for j = i+1:n
                lij = A[ref[j],i] / A[ref[i],i]
                A[ref[j],i] = lij
                append!(nzCount[ref[j]],i)
                for k = i+1:n
                    A[ref[j],k] -= lij * A[ref[i],k]
                end
            end
        end
    else
        for i = 1:l-2
            if withChoice
                swapLines(i,l)
            end
            for j = i+1:l
                lij = A[ref[j],i] / A[ref[i],i]
                A[ref[j],i] = lij
                append!(nzCount[ref[j]],i)
                for k = i+1:l*2
                    A[ref[j],k] -= lij * A[ref[i],k]
                end
            end
        end
        for block = l-1:l:n-2*l-1
            for i = block:block+l-1
                if withChoice
                    swapLines(i,block+l+1)
                end
                for j = i+1:block+l+1
                    lij = A[ref[j],i] / A[ref[i],i]
                    A[ref[j],i] = lij
                    append!(nzCount[ref[j]],i)
                    for k = i+1:block+2*l+1
                        A[ref[j],k] -= lij * A[ref[i],k]
                    end
                end
            end
        end
        for i = n-l-1:n-1
            if withChoice
                swapLines(i,n)
            end
            for j = i+1:n
                lij = A[ref[j],i] / A[ref[i],i]
                A[ref[j],i] = lij
                append!(nzCount[ref[j]],i)
                for k = i+1:n
                    A[ref[j],k] -= lij * A[ref[i],k]
                end
            end
        end
    end
end

function solveWithLU()
    global A,ref,b,x,l,n,nzCount
    y = zeros(n)
    for i = 1:n
        y[i] = b[ref[i]]
        for j = nzCount[ref[i]]
            y[i] -= A[ref[i],j] * y[j]
        end
    end
    x = zeros(n)
    for i = 0:n-1
        x[n-i] = y[n-i]
        for j = if (i > 2*l+2) i-2*l-2:i-1 else 0:i-1 end
            x[n-i] -= A[ref[n-i],n-j] * x[n-j]
        end
        x[n-i] /= A[ref[n-i],n-i]
    end
end

function generateB()
    global A,b,n,l
    v = Int(n / l)
    b = zeros(n)
    if v == 1
        b = A * ones(n)
    else
        for i = 1:l
            for j = 1:l
                b[i] += A[i,j]
            end
            b[i] += A[i,i+l]
        end
        for block = 1:v-2
            for i = block*l+1:block*l+l
                for j = block*l-1:block*l+l
                    b[i] += A[i,j]
                end
                b[i] += A[i,i+l]
            end
        end
        for i = n-l+1:n
            for j = n-l-1:n
                b[i] += A[i,j]
            end
        end
    end
end

function printX(filename,withError)
    global x,n
    io = open(filename,"w")
    if withError
        println(io,getError())
    end
    for i = 1:n
        println(io,x[i])
    end
    close(io)
end

function getError()
    global x,n
    norm(x - ones(n))/norm(ones(n))
end

end