function scalar()
    x = [2.718281828,-3.141592654,1.414213562,0.5772156649,0.3010299957]
    y = [1486.2497,878366.9879,-22.37492,4773714.647,0.000185049]

    s = 0.0
    for i = 1:size(x,1)
        s += x[i] * y[i]
    end
    println(s)

    s = 0.0
    for i = 1:size(x,1)
        s += x[size(x,1)-i+1] * y[size(x,1)-i+1]
    end
    println(s)

    z = Array{Float64,1}(undef, length(x))
    for i = 1:size(x,1)
        z[i] = x[i] * y[i]
    end
    sort!(z)

    s = 0.0
    pos = 0.0
    neg = 0.0
    for i = 1:length(z)
        if z[i] < 0.0
            neg += z[i]
        else
            break
        end
    end
    for i = 0:length(z)-1
        if z[length(z)-i] > 0.0
            pos += z[length(z)-i]
        else
            break
        end
    end
    s = neg + pos
    println(s)

    s = 0.0
    pos = 0.0
    neg = 0.0
    for i = 0:length(z)-1
        if z[length(z)-i] < 0.0
            neg += z[length(z)-i]
        end
    end
    for i = 1:length(z)
        if z[i] > 0.0
            pos += z[i]
        end
    end
    s = neg + pos
    println(s)
end
scalar()