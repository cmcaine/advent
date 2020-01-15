module Intcode

using Base.Iterators: product

import Base: ==

export interpret_intcode!, interpret_intcode, readtape


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
    Tape{T}

A sparse vector of infinite size. Only non-zeros stored. Indexes are zero-based.

"""
struct Tape{T}
    initial::AbstractVector{T}
    additional::AbstractDict{T,T}
end

Tape(initial::AbstractVector{T}) where T = Tape(initial, Dict{T, T}())

Base.getindex(tape::Tape{T}, idx) where T =
    idx < length(tape.initial) ?
    tape.initial[idx+1] :
    haskey(tape.additional, idx) ?
    tape.additional[idx] :
    zero(T)

Base.setindex!(tape::Tape, value, idx) =
    idx < length(tape.initial) ?
        tape.initial[idx+1] = value :
        tape.additional[idx] = value

Base.eachindex(tape::Tape) =
    ((eachindex(tape.initial) .- 1)..., eachindex(tape.additional)...)

(==)(a::Tape, b::Tape) =
    eachindex(a) == eachindex(b) && all(a[i] == b[i] for i in eachindex(a))
(==)(a::Tape, v::AbstractVector) = a == Tape(v)
(==)(a::AbstractVector, b::Tape) = b == a


"""
    interpret_intcode!(tape, input=() -> parse(Int, readline()), output=println)

Run the intcode machine on tape, possibly modifying it. If input or output or required, call the provided functions.

Functions must support this interface:

input: () -> Int
output: Int -> Nothing

"""
function interpret_intcode!(tape, input=() -> parse(Int, readline()), output=println)
    tape = Tape(tape)

    # d for dereference
    d(x) = tape[tape[x]]
    d(x, y) = tape[tape[x]] = y

    PC = 0
    relative_base = 0
    while true
        op, modes = op_parse(tape[PC])

        # OPTIM: this could be really expensive if the compiler is not smart
        "value of parameter x"
        param(x) = if modes[x] == 1
            tape[PC+x]
        elseif modes[x] == 2
            tape[tape[PC+x] + relative_base]
        else
            d(PC+x)
        end

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
        elseif op == 9
            relative_base = param(1)
            PC += 2
        elseif op == 99
            return tape
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
