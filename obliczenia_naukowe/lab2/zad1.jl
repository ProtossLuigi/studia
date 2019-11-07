#Kajetan Bilski
function scalar32()
    x = Float32[2.718281828,-3.141592654,1.414213562,0.577215664,0.301029995]
    y = Float32[1486.2497,878366.9879,-22.37492,4773714.647,0.000185049]

    #"w przód"
    s = 0f0
    for i = 1:size(x,1)
        s += x[i] * y[i]
    end
    println(s)

    #"w tył"
    s = 0f0
    for i = 1:size(x,1)
        s += x[size(x,1)-i+1] * y[size(x,1)-i+1]
    end
    println(s)

    # z - tablica iloczynów do zsumowania
    z = Array{Float32,1}(undef, length(x))
    for i = 1:size(x,1)
        z[i] = x[i] * y[i]
    end
    sort!(z)

    # od największego do najmniejszego
    s = 0f0
    pos = 0f0
    neg = 0f0
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

    # od najmniejszego do największego
    s = 0f0
    pos = 0f0
    neg = 0f0
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
#to samo tylko dla Float64
function scalar64()
    x = Float64[2.718281828,-3.141592654,1.414213562,0.5772156649,0.3010299957]
    y = Float64[1486.2497,878366.9879,-22.37492,4773714.647,0.000185049]

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
scalar32()
scalar64()