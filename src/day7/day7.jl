module day7

using ..advent.Intcode
using Combinatorics: permutations

"""
--- Day 7: Amplification Circuit ---

Based on the navigational maps, you're going to need to send more power to your ship's thrusters to reach Santa in time. To do this, you'll need to configure a series of amplifiers already installed on the ship.

There are five amplifiers connected in series; each one receives an input signal and produces an output signal. They are connected such that the first amplifier's output leads to the second amplifier's input, the second amplifier's output leads to the third amplifier's input, and so on. The first amplifier's input value is 0, and the last amplifier's output leads to your ship's thrusters.

Puzzle input is the Amplifier Controller Software and each amplifier runs a copy of it.

Each amp takes two inputs, their phase (an integer between 0 and 4) and their initial input value. Each amp provides one output, the amplified value.

Find the phase sequence that maximises the output.

"""

make_amp(tape) = (input::Int, phase::Int) ->
    interpret_intcode(tape, [phase, input])[2][1]

make_amp_stack(amp) = (phases) ->
    foldl(amp, phases; init=0)

make_amp_stack(tape::AbstractVector) = make_amp_stack(make_amp(tape))

maximum_output(amp) =
    maximum(phases -> (make_amp_stack(amp)(phases), phases),
            permutations(0:4, 5))

A() = maximum_output(readtape(joinpath(@__DIR__, "input.txt")))

end
