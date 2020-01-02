using Test: @test, @testset


# Day 1

const day1A = sum(x -> x ÷ 3 - 2, parse.(Int, readlines("day1.txt")))

# 1b
function fuelcost(x)
    f(x) = x ÷ 3 - 2
    return f(x) > 0 ? f(x) + fuelcost(f(x)) : 0
end

@test fuelcost(14) == 2
@test fuelcost(1969) == 966

const day1B = sum(fuelcost, parse.(Int, readlines("day1.txt")))


# Day 2

using Base.Iterators: product

function interpret_intcode!(tape)
    # d for dereference
    d(x) = tape[tape[x]+1]
    d(x, y) = tape[tape[x]+1] = y
    headpos = 1
    while true
        head = tape[headpos]
        if head == 1
            d(headpos+3, d(headpos+1) + d(headpos+2))
        elseif head == 2
            d(headpos+3, d(headpos+1) * d(headpos+2))
        elseif head == 99
            return tape
        else
            throw(DomainError("Unfestive opcode $head"))
        end
        headpos += 4
    end
end

interpret_intcode(tape) = interpret_intcode!(copy(tape))

@testset "day2" begin
    @test interpret_intcode([1, 0, 0, 0, 99]) == [2, 0, 0, 0, 99]
    @test interpret_intcode([2,3,0,3,99]) == [2,3,0,6,99]
    @test interpret_intcode([1,1,1,4,99,5,6,0,99]) == [30,1,1,4,2,5,6,0,99]
    @test interpret_intcode([1,9,10,3,2,3,11,0,99,30,40,50]) == [3500,9,10,70,2,3,11,0,99,30,40,50]
end

const day2input = parse.(Int, split(readline("day2a.txt"), ","))

function gravity_assist(a, b)
    day2input[2:3] = [a, b]
    return interpret_intcode(day2input)[1]
end

const day2A = gravity_assist(12, 2)
const day2B = first(100 * a + b for (a, b) in product(0:99, 0:99) if gravity_assist(a, b) == 19690720)
