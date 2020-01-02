module day4

"""
--- Day 4: Secure Container ---

You arrive at the Venus fuel depot only to discover it's protected by a password. The Elves had written the password on a sticky note, but someone threw it out.

However, they do remember a few key facts about the password:

    It is a six-digit number.
    The value is within the range given in your puzzle input.
    Two adjacent digits are the same (like 22 in 122345).
    Going from left to right, the digits never decrease; they only ever increase or stay the same (like 111123 or 135679).

Other than the range rule, the following are true:

    111111 meets these criteria (double 11, never decreases).
    223450 does not meet these criteria (decreasing pair of digits 50).
    123789 does not meet these criteria (no double).

How many different passwords within the range given in your puzzle input meet these criteria?

"""

const input = 246540:787419

function password_checker(pass)
    doubled(str) = any(a == b for (a, b) in zip(str, str[2:end]))
    ascending(str) = all(a <= b for (a, b) in zip(str, str[2:end]))
    return length(pass) == 6 && ascending(pass) && doubled(pass)
end

"""
An Elf just remembered one more important detail: the two adjacent matching digits are not part of a larger group of matching digits.

Given this additional criterion, but still ignoring the range rule, the following are now true:

    112233 meets these criteria because the digits never decrease and all repeated digits are exactly two digits long.
    123444 no longer meets the criteria (the repeated 44 is part of a larger group of 444).
    111122 meets the criteria (even though 1 is repeated more than twice, it still contains a double 22).
"""

function password_checkerB(pass)
    exactly_doubled(str) =
        any(a != b && b == c && c != d for (a, b, c, d) in
            zip(str, str[2:end], str[3:end] * " ", str[4:end] * "  "))
    ascending(str) = all(a <= b for (a, b) in zip(str, str[2:end]))
    return length(pass) == 6 && ascending(pass) && exactly_doubled(pass)
end

A() = count(password_checker ∘ string, input)
B() = count(password_checkerB ∘ string, input)

end
