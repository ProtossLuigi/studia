include("./blocksys.jl")
include("./matrixgen.jl")

using BenchmarkTools,.blocksys,.matrixgen,Plots

function eliminationWithLU(A,b,n,l,withChoice)
    (LU,ref,nzCount) = blocksys.decomposition(A,n,l,withChoice)
    blocksys.solveWithLU(LU,ref,nzCount,n,l,b)
end

function masstest()
    suite = BenchmarkGroup()
    for key1 in ["n","l","cond"]
        suite[key1] = BenchmarkGroup()
        for key2 in ["elimination","withLU"]
            suite[key1][key2] = BenchmarkGroup()
            for key3 in ["noChoice","withChoice"]
                suite[key1][key2][key3] = BenchmarkGroup()
            end
        end
    end
    A = b = n = l = 0
    for i = 10:10:200
        suite["n"]["elimination"]["noChoice"][i] = @benchmarkable blocksys.elimination(A,b,n,l,false) setup=(matrixgen.blockmat($i,5,10.,"M.txt"); (A,n,l)=blocksys.loadMatrix("M.txt"); b=blocksys.generateB(A,n,l))
        suite["n"]["elimination"]["withChoice"][i] = @benchmarkable blocksys.elimination(A,b,n,l,true) setup=(matrixgen.blockmat($i,5,10.,"M.txt"); (A,n,l)=blocksys.loadMatrix("M.txt"); b=blocksys.generateB(A,n,l))
        suite["n"]["withLU"]["noChoice"][i] = @benchmarkable eliminationWithLU(A,b,n,l,false) setup=(matrixgen.blockmat($i,5,10.,"M.txt"); (A,n,l)=blocksys.loadMatrix("M.txt"); b=blocksys.generateB(A,n,l))
        suite["n"]["withLU"]["withChoice"][i] = @benchmarkable eliminationWithLU(A,b,n,l,true) setup=(matrixgen.blockmat($i,5,10.,"M.txt"); (A,n,l)=blocksys.loadMatrix("M.txt"); b=blocksys.generateB(A,n,l))
    end
    for i = 2:6
        suite["l"]["elimination"]["noChoice"][i] = @benchmarkable blocksys.elimination(A,b,n,l,false) setup=(matrixgen.blockmat(720,$i,10.,"M.txt"); (A,n,l)=blocksys.loadMatrix("M.txt"); b=blocksys.generateB(A,n,l))
        suite["l"]["elimination"]["withChoice"][i] = @benchmarkable blocksys.elimination(A,b,n,l,true) setup=(matrixgen.blockmat(720,$i,10.,"M.txt"); (A,n,l)=blocksys.loadMatrix("M.txt"); b=blocksys.generateB(A,n,l))
        suite["l"]["withLU"]["noChoice"][i] = @benchmarkable eliminationWithLU(A,b,n,l,false) setup=(matrixgen.blockmat(720,$i,10.,"M.txt"); (A,n,l)=blocksys.loadMatrix("M.txt"); b=blocksys.generateB(A,n,l))
        suite["l"]["withLU"]["withChoice"][i] = @benchmarkable eliminationWithLU(A,b,n,l,true) setup=(matrixgen.blockmat(720,$i,10.,"M.txt"); (A,n,l)=blocksys.loadMatrix("M.txt"); b=blocksys.generateB(A,n,l))
    end
    for i = 10.0:1.0:29.0
        suite["cond"]["elimination"]["noChoice"][i] = @benchmarkable blocksys.elimination(A,b,n,l,false) setup=(matrixgen.blockmat(720,5,$i,"M.txt"); (A,n,l)=blocksys.loadMatrix("M.txt"); b=blocksys.generateB(A,n,l))
        suite["cond"]["elimination"]["withChoice"][i] = @benchmarkable blocksys.elimination(A,b,n,l,true) setup=(matrixgen.blockmat(720,5,$i,"M.txt"); (A,n,l)=blocksys.loadMatrix("M.txt"); b=blocksys.generateB(A,n,l))
        suite["cond"]["withLU"]["noChoice"][i] = @benchmarkable eliminationWithLU(A,b,n,l,false) setup=(matrixgen.blockmat(720,5,$i,"M.txt"); (A,n,l)=blocksys.loadMatrix("M.txt"); b=blocksys.generateB(A,n,l))
        suite["cond"]["withLU"]["withChoice"][i] = @benchmarkable eliminationWithLU(A,b,n,l,true) setup=(matrixgen.blockmat(720,5,$i,"M.txt"); (A,n,l)=blocksys.loadMatrix("M.txt"); b=blocksys.generateB(A,n,l))
    end
    return suite
end

function testPrecision()
    gr()
    xn = collect(10:10:200)
    xl = collect(2:6)
    xcond = collect(10.0:1.0:29.0)
    yn = [zeros(20) for i=1:4]
    yl = [zeros(5) for i=1:4]
    ycond = [zeros(20) for i=1:4]
    labels = ["Gauss z wyborem","dwuetapowe z wyborem"]
    for i = 1:20
        matrixgen.blockmat(xn[i],5,10.,"M.txt")
        (A,n,l) = blocksys.loadMatrix("M.txt")
        b = blocksys.generateB(A,n,l)
        x = blocksys.elimination(A,b,n,l,false)
        yn[1][i] = blocksys.getError(x,n)
        x = blocksys.elimination(A,b,n,l,true)
        yn[2][i] = blocksys.getError(x,n)
        x = eliminationWithLU(A,b,n,l,false)
        yn[3][i] = blocksys.getError(x,n)
        x = eliminationWithLU(A,b,n,l,true)
        yn[4][i] = blocksys.getError(x,n)
    end
    y = [yn[2] #=yn[3]=# yn[4]]
    plot(xn,y,label = labels)
    png("precision_n_3")
    for i = 1:5
        matrixgen.blockmat(720,xl[i],10.,"M.txt")
        (A,n,l) = blocksys.loadMatrix("M.txt")
        b = blocksys.generateB(A,n,l)
        x = blocksys.elimination(A,b,n,l,false)
        yl[1][i] = blocksys.getError(x,n)
        x = blocksys.elimination(A,b,n,l,true)
        yl[2][i] = blocksys.getError(x,n)
        x = eliminationWithLU(A,b,n,l,false)
        yl[3][i] = blocksys.getError(x,n)
        x = eliminationWithLU(A,b,n,l,true)
        yl[4][i] = blocksys.getError(x,n)
    end
    y = [yl[2] #=yl[3]=# yl[4]]
    plot(xl,y,label = labels)
    png("precision_l_3")
    for i = 1:20
        matrixgen.blockmat(720,5,xcond[i],"M.txt")
        (A,n,l) = blocksys.loadMatrix("M.txt")
        b = blocksys.generateB(A,n,l)
        x = blocksys.elimination(A,b,n,l,false)
        ycond[1][i] = blocksys.getError(x,n)
        x = blocksys.elimination(A,b,n,l,true)
        ycond[2][i] = blocksys.getError(x,n)
        x = eliminationWithLU(A,b,n,l,false)
        ycond[3][i] = blocksys.getError(x,n)
        x = eliminationWithLU(A,b,n,l,true)
        ycond[4][i] = blocksys.getError(x,n)
    end
    y = [ycond[2] #=ycond[3]=# ycond[4]]
    plot(xcond,y,label = labels)
    png("precision_cond_3")
end