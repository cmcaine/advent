"""
--- Day 3: Crossed Wires ---

The gravity assist was successful, and you're well on your way to the Venus refuelling station. During the rush back on Earth, the fuel management system wasn't completely installed, so that's next on the priority list.

Opening the front panel reveals a jumble of wires. Specifically, two wires are connected to a central port and extend outward on a grid. You trace the path each wire takes as it leaves the central port, one wire per line of text (your puzzle input).

The wires twist and turn, but the two wires occasionally cross paths. To fix the circuit, you need to find the intersection point closest to the central port. Because the wires are on a grid, use the Manhattan distance for this measurement. While the wires do technically cross right at the central port where they both start, this point does not count, nor does a wire count as crossing with itself.

For example, if the first wire's path is R8,U5,L5,D3, then starting from the central port (o), it goes right 8, up 5, left 5, and finally down 3:

...........
...........
...........
....+----+.
....|....|.
....|....|.
....|....|.
.........|.
.o-------+.
...........

Then, if the second wire's path is U7,R6,D4,L4, it goes up 7, right 6, down 4, and left 4:

...........
.+-----+...
.|.....|...
.|..+--X-+.
.|..|..|.|.
.|.-X--+.|.
.|..|....|.
.|.......|.
.o-------+.
...........

These wires cross at two locations (marked X), but the lower-left one is closer to the central port: its distance is 3 + 3 = 6.

What is the Manhattan distance from the central port to the closest intersection?

"""
module day3

using Base.Iterators: product
using Transducers


struct Segment
    x1::Int
    y1::Int
    x2::Int
    y2::Int
end

Segment(p1, p2) = Segment(p1..., p2...)
# Needed for intersection2, probably a bad interface.
Base.first(s::Segment) = [s.x1, s.y1]
Base.last(s::Segment) = [s.x2, s.y2]


"""

find the intersection of two line segments

Assumptions:
- segments only run in cardinal directions
- segments only overlap at junctions or when abutting
    - i.e. colinear segments may abut but do not overlap

"""
function intersection(a, b)
    "a is between b and c"
    between(a, b, c) = min(b, c) <= a <= max(b, c)

    if a.x1 == a.x2 && between(a.x1, b.x1, b.x2)
        if between(b.y1, a.y1, a.y2)
            return a.x1, b.y1
        elseif between(b.y2, a.y1, a.y2)
            return a.x1, b.y2
        end
    elseif a.y1 == a.y2 && between(a.y1, b.y1, b.y2)
        if between(b.x1, a.x1, a.x2)
            return b.x1, a.y1
        elseif between(b.x2, a.x1, a.x2)
            return b.x2, a.y1
        end
    end
    return nothing
end


"""

A more mathsy version. Handles diagonal lines. Slower. Poor handling for colinear segments

Derivation: http://www.cs.swan.ac.uk/~cssimon/line_intersection.html

"""
function intersection2(a, b)
    denom = (b.x2 - b.x1) * (a.y1 - a.y2) - (a.x1 - a.x2) * (b.y2 - b.y1)

    # Colinear
    iszero(denom) && return nothing

    # Handle abutting wires better at expense of speed
    #= if iszero(denom) =#
    #=     # Lines are colinear =#
    #=     # Check if the ends intersect =#
    #=     if first(a) in (first(b), last(b)) =#
    #=         return first(a) =#
    #=     elseif last(a) in (first(b), last(b)) =#
    #=         return last(a) =#
    #=     else =#
    #=         return nothing =#
    #=     end =#
    #= end =#

    ta = ((b.y1 - b.y2) * (a.x1 - b.x1) + (b.x2 - b.x1) * (a.y1 - b.y1)) / denom
    tb = ((a.y1 - a.y2) * (a.x1 - b.x1) + (a.x2 - a.x1) * (a.y1 - b.y1)) / denom

    if 0 <= ta <= 1 && 0 <= tb <= 1
        return [a.x1, a.y1] + ta * ([a.x2, a.y2] - [a.x1, a.y1])
    else
        # Not intersecting
        return nothing
    end
end


function segments(directions)
    current_location = [0,0]
    acc = Segment[]
    for instr in directions
        dir, dist = instr[1], parse(Int, instr[2:end])
        next_location = if dir == 'U'
            current_location + [0, dist]
        elseif dir == 'D'
            current_location + [0, -dist]
        elseif dir == 'L'
            current_location + [-dist, 0]
        elseif dir == 'R'
            current_location + [dist, 0]
        else
            error("I cannot go there")
        end
        push!(acc, Segment(current_location, next_location))
        current_location = next_location
    end
    return acc
end


struct DelayedSegment
    delay::Int
    seg::Segment
end


function delay_tracking_segments(directions)
    current_location = [0,0]
    current_delay = 0
    acc = DelayedSegment[]
    for instr in directions
        dir, dist = instr[1], parse(Int, instr[2:end])
        next_location = if dir == 'U'
            current_location + [0, dist]
        elseif dir == 'D'
            current_location + [0, -dist]
        elseif dir == 'L'
            current_location + [-dist, 0]
        elseif dir == 'R'
            current_location + [dist, 0]
        else
            error("I cannot go there")
        end
        push!(acc, DelayedSegment(current_delay, Segment(current_location, next_location)))
        current_location = next_location
        current_delay += dist
    end
    return acc
end


#=

segments(["U8", "D4", "L1", "R1"])

s1 = segments(split("R75,D30,R83,U83,L12,D49,R71,U7,L72", ","))
s2 = segments(split("U62,R66,U55,R34,D71,R55,D58,R83", ","))


@btime ((s1, s2) ->
minimum(
    filter(!iszero,
    map(t -> sum(abs, t),
    filter(!isnothing,
    map(((a, b),) -> intersection1(a, b),
    product(s1, s2)
)))))
)($s1, $s2)

@btime ((s1, s2) ->
product(s1, s2) |>
    xs -> map(((a, b),) -> intersection1(a, b), xs) |>
    xs -> filter(!isnothing, xs) |>
    xs -> map(t -> sum(abs, t), xs) |>
    xs -> filter(!iszero, xs) |>
    minimum
)($s1, $s2)

# This is like 2.5x faster and can be made parallel by swapping foldl for reduce
@btime ((s1, s2) ->
foldl(min,
      Map(((a, b),) -> intersection1(a, b)) |>
          Filter(!isnothing) |>
          Map(t -> sum(abs, t)) |>
          Filter(!iszero),
      product(s1, s2)
     )
)($s1, $s2)

=#


function closest_intersection(wires)
    s1, s2 = segments.(split(l, ",") for l in wires)
    return foldl(min,
          Map(((a, b),) -> intersection(a, b)) |>
              Filter(!isnothing) |>
              Map(t -> sum(abs, t)) |>
              Filter(!iszero),
          product(s1, s2)
         )
end


"""

> It turns out that this circuit is very timing-sensitive; you actually need to minimize the signal delay.

> To do this, calculate the number of steps each wire takes to reach each intersection; choose the intersection where the sum of both wires' steps is lowest. If a wire visits a position on the grid multiple times, use the steps value from the first time it visits that position when calculating the total value of a specific intersection.

This sentence isn't very clear: "If a wire visits a position on the grid multiple times, use the steps value from the first time it visits that position when calculating the total value of a specific intersection."

If the wires touch at every crossing point then I should recompute the delays after checking self-intersections in delay_tracking_segments().

"""
function min_delay(wires)
    s1, s2 = delay_tracking_segments.(split(l, ",") for l in wires)

    f((a, b),) = begin
        inter = intersection(a.seg, b.seg)
        if isnothing(inter)
            # This will be filtered out by the next step.
            return 0
        else
            # Return the delay to the intersection
            return (a.delay + b.delay
                    + sum(abs, first(a.seg) .- inter)
                    + sum(abs, first(b.seg) .- inter))
        end
    end

    return foldl(min,
                 Map(f) |> Filter(!iszero),
                 product(s1, s2))
end


A() = closest_intersection(readlines(joinpath(@__DIR__, "input.txt")))
B() = min_delay(readlines(joinpath(@__DIR__, "input.txt")))

end
