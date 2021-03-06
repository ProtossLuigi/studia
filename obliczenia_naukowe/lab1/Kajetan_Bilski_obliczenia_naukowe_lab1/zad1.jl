#Kajetan Bilski
#macheps dla Float16
macheps = Float16(1.)
while Float16(1.) + macheps / 2 > Float16(1.)
	global macheps /= 2
end
println(macheps)

#macheps dla Float32
macheps = Float32(1.)
while Float32(1.) + macheps / 2 > Float32(1.)
        global macheps /= 2
end
println(macheps)

#macheps dla Float64
macheps = Float64(1.)
while Float64(1.) + macheps / 2 > Float64(1.)
        global macheps /= 2
end
println(macheps)

#eta dla Float16
eta = Float16(1.)
while eta / 2 > Float16(0.0)
	global eta /= 2
end
println(eta)

println(nextfloat(Float16(0.0)))

#eta dla Float32
eta = Float32(1.)
while eta / 2 > Float32(0.0)
        global eta /= 2
end
println(eta)

println(nextfloat(Float32(0.0)))

#eta dla Float64
eta = Float64(1.)
while eta / 2 > Float64(0.0)
        global eta /= 2
end
println(eta)

println(nextfloat(Float64(0.0)))
println(floatmin(Float32))
println(floatmin(Float64))

#max dla Float16
x = Float16(1.)
while !isinf(x*2)
        global x *= 2
end
i = Float16(1.)
while !isinf(x+i)
        if x + i == x
                global i *= 2
        else
                global x += i
        end
end
println(x)
println(floatmax(Float16))

#max dla Float32
x = 1f0
while !isinf(x*2)
	global x *= 2
end
i = x
while !(x + i == x)
	if isinf(x + i)
		global i /= 2
	else
		global x += i
	end
end
println(x)
println(floatmax(Float32))

#max dla Float64
x = 1e0
while !isinf(x*2)
        global x *= 2
end
i = x
while x + i != x
        if isinf(x + i)
                global i /= 2
        else
                global x += i
        end
end
println(x)
println(floatmax(Float64))