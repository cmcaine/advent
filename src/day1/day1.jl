module day1

const input = parse.(Int, readlines(joinpath(@__DIR__, "input.txt")))

A() = sum(x -> x ÷ 3 - 2, input)

# 1b
function fuelcost(x)
    f(x) = x ÷ 3 - 2
    return f(x) > 0 ? f(x) + fuelcost(f(x)) : 0
end

B() = sum(fuelcost, input)

end
