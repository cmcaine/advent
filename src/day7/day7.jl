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
A() = maximum_output(readtape(joinpath(@__DIR__, "input.txt")))

make_amp(tape) = (input::Int, phase::Int) ->
    interpret_intcode(tape, [phase, input])[2][1]

make_amp_stack(amp) = (phases) ->
    foldl(amp, phases; init=0)

make_amp_stack(tape::AbstractVector) = make_amp_stack(make_amp(tape))

maximum_output(amp) =
    maximum(phases -> (make_amp_stack(amp)(phases), phases),
            permutations(0:4, 5))


"""

--- Part Two ---

It's no good - in this configuration, the amplifiers can't generate a large enough output signal to produce the thrust you'll need. The Elves quickly talk you through rewiring the amplifiers into a feedback loop.

Given phases 5-9, each program will now accept 1 or more inputs before eventually terminating. Each amplifier is expected to run for the same number of iterations.

When every amplifier has halted, the last output from the final amplifier in the chain is the signal to the thrusters.

Changes required:

 - amplifiers are now stateful
 - need to monitor for termination
 - need to be able to pause execution
    - could do this with the callbacks I set up for input and output without using Julia's async routines, but I'd have to adapt the interpreter to be pausable. If I'd made it more functional in the first place I might not have this problem ;)

    - Use Julia's tasks (better to practice the things I'll actually use, anyway :)
        - associate two channels with each machine.
        - input() = take!(chan1); output(x) = put!(chan2, x);
        - make each machine a Task with @async
        - channels of adjacent machines are shared. last channel loops back around.
        - wait on last task then take the result from the last channel (which will still be there because no one else will take it.
        - The last channel needs to be buffered or the task will never finish.

"""
B() = maximum_output_feedback(readtape(joinpath(@__DIR__, "input.txt")))


function feedback_amp_stack(tape, phases)
    channels = [Channel{Int}(1) for _ in phases]
    tasks = map(enumerate(phases)) do (idx, phase)
        inchan = channels[idx]
        outchan = channels[idx + 1 > length(phases) ? 1 : idx + 1]
        put!(inchan, phase)
        @async interpret_intcode(tape, () -> take!(inchan), v -> put!(outchan, v))
    end
    put!(channels[1], 0)
    wait(tasks[end])
    return take!(channels[1])
end


# It's a bit scruffy just having _feedback on the names, but I don't think it would be any clearer if I defined some custom AmpStack types and did multiple dispatch.
maximum_output_feedback(tape) =
    maximum(phases -> (feedback_amp_stack(tape, phases), phases),
            permutations(5:9, 5))

end
