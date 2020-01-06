using Plots

gr()

function makeTimePlots(results)
    xn = collect(10:10:200)
    xl = collect(2:6)
    xcond = collect(10.0:1.0:29.0)
    yn = zeros(20)
    yl = zeros(5)
    ycond = zeros(20)
    for i in ["elimination","withLU"]
        for j in ["withChoice","noChoice"]
            for k = 1:20
                yn[k] = results["n"][i][j][string(xn[k])].time/1000
            end
            plot(xn,yn,seriestype = :bar,legend = false)
            png("n_"*i*"_"*j)
        end
    end
    for i in ["elimination","withLU"]
        for j in ["withChoice","noChoice"]
            for k = 1:5
                yl[k] = results["l"][i][j][string(xl[k])].time/1000
            end
            plot(xl,yl,seriestype = :bar,legend = false)
            png("l_"*i*"_"*j)
        end
    end
    for i in ["elimination","withLU"]
        for j in ["withChoice","noChoice"]
            for k = 1:20
                ycond[k] = results["cond"][i][j][string(xcond[k])].time/1000
            end
            plot(xcond,ycond,seriestype = :bar,legend = false)
            png("cond_"*i*"_"*j)
        end
    end
end