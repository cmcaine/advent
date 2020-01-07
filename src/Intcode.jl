module Intcode

using Base.Iterators: product
using OffsetArrays: OffsetVector

export interpret_intcode!, interpret_intcode


"""
    ParameterModes(explicit_modes)

"""
struct ParameterModes
    # Reversed vec of explicitly declared modes
    ms::Vector{Int}
end

"""
    getindex(pm::ParameterModes, i)

The mode of the i^th parameter. The default mode is 0 (positional).

"""
Base.getindex(pm::ParameterModes, i::Int) = begin
    length(pm.ms) < i ? 0 : pm.ms[end-i+1]
end


"""
    op_parse(x)

 - opcode = Two least-significant digits
 - param modes = each digit after, right to left.

```jldoctest
julia> op_parse(1001)
(1, ParameterModes([1, 0]))
```

"""
function op_parse(x)
    x < 100 && return x, ParameterModes([])

    # Indexing below is safe: length(x) >= 3
    x = string(x)
    op = parse(Int, x[end-1:end])
    x = x[1:end-2]
    param_modes = map(i -> parse(Int, x[i]), eachindex(x))
    return op, ParameterModes(param_modes)
end


"""
    interpret_intcode!(tape, input::T) where T <: AbstractVector

Feed a vector of known inputs and return the modified tape and a vector of all outputs.

"""
function interpret_intcode!(tape, input::T) where T <: AbstractVector
    arrayinput(A) = let i = 0
        () -> (i += 1; A[i])
    end
    saveoutput(A) = v -> push!(A, v)

    output=similar(tape, 0)
    tape = interpret_intcode!(tape, arrayinput(input), saveoutput(output))

    return tape, output
end


"""
    interpret_intcode!(tape, input=() -> parse(Int, readline()), output=println)

Run the intcode machine on tape, possibly modifying it. If input or output or required, call the provided functions.

Functions must support this interface:

input: () -> Int
output: Int -> Nothing

"""
function interpret_intcode!(tape, input=() -> parse(Int, readline()), output=println)
    tape = OffsetVector(tape, 0:length(tape)-1)

    # d for dereference
    d(x) = tape[tape[x]]
    d(x, y) = tape[tape[x]] = y

    PC = 0
    while true
        op, modes = op_parse(tape[PC])

        # OPTIM: this could be really expensive if the compiler is not smart
        "value of parameter x"
        param(x) = modes[x] == 1 ? tape[PC+x] : d(PC+x)

        if op == 1
            d(PC+3, param(1) + param(2))
            PC += 4
        elseif op == 2
            d(PC+3, param(1) * param(2))
            PC += 4
        elseif op == 3
            d(PC+1, input())
            PC += 2
        elseif op == 4
            output(param(1))
            PC += 2
        elseif op == 5
            param(1) != 0 ? (PC = param(2)) : (PC += 3)
        elseif op == 6
            param(1) == 0 ? (PC = param(2)) : (PC += 3)
        elseif op == 7
            d(PC+3, param(1) < param(2) ? 1 : 0)
            PC += 4
        elseif op == 8
            d(PC+3, param(1) == param(2) ? 1 : 0)
            PC += 4
        elseif op == 99
            return parent(tape)
        else
            throw(DomainError("Unfestive opcode $op"))
        end
    end
end


"""
    interpret_intcode(tape, args...) = interpret_intcode!(copy(tape), args...)
"""
interpret_intcode(tape, args...) = interpret_intcode!(copy(tape), args...)


function readtape(filename)
    return parse.(Int, split(readline(filename), ","))
end


end
