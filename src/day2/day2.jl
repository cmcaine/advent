module day2

using ..Intcode
using Base.Iterators: product

const day2tape = parse.(Int, split(readline(joinpath(@__DIR__, "input.txt")), ","))

function gravity_assist(a, b)
    tape = copy(day2tape)
    tape[2:3] = [a, b]
    interpret_intcode!(tape)
    return tape[1]
end

const A() = gravity_assist(12, 2)
const B() = first(100 * a + b for (a, b) in product(0:99, 0:99) if gravity_assist(a, b) == 19690720)

end
