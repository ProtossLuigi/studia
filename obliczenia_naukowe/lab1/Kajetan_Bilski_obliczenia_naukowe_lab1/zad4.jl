#Kajetan Bilski

function find_min()
    x = nextfloat(1e0)
    while x * (1/x) == 1
        x = nextfloat(x)
    end
    println(x)
end
find_min()