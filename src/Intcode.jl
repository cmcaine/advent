module Intcode

using Base.Iterators: product

export interpret_intcode!, interpret_intcode

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

end
