module day5

using ..Intcode

const testProg = Intcode.readtape(joinpath(@__DIR__, "input.txt"))

A() = interpret_intcode(testProg, [1])[2][end]
B() = interpret_intcode(testProg, [5])[2][1]

end
