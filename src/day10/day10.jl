module day10

using Test

"list of asteroid locations"
function parse_map(map)
    x = 0
    y = 0
    asteroids = Vector{Tuple{Int, Int}}()
    for c in map
        if c == '\n'
            y += 1
            x = 0
            continue
        elseif c == '#'
            push!(asteroids, (x, y))
        end
        x += 1
    end
    return asteroids
end


readinput() = parse_map(read(joinpath(@__DIR__, "input.txt"), String))


"""
    angle(station, asteroid)

Given the vector station -> asteroid, the gradient and a quadrant identifier
are together a lossless and unique representation of the angle.

Q: Why use this weird definition rather than the standard atan(b/a)?
A: Arctan is an approximation and I would like to be able to identify when angles are identical.

Q: Could you just round/truncate the value from atan and compare on that?
A: No, doesn't work (or I messed it up).

Q: Could you use isapprox()?
A: Maybe? But then we'll have n^2 comparisons to do.

"""
angle(station, asteroid) = let shifted = asteroid .- station
    Rational(shifted...), >=(0).(shifted)
end


"""
    findbest(asteroids) -> (num_visible, location)
"""
findbest(asteroids) =
    maximum(asteroids) do station
        length(unique(map(
                          asteroid -> angle(station, asteroid),
                          setdiff(asteroids, (station,))))), station
    end


A() = findbest(readinput())


@testset "day10A" begin
    m1 = """
        .#..#
        .....
        #####
        ....#
        ...##
        """

    m2 = """
        ......#.#.
        #..#.#....
        ..#######.
        .#.#.###..
        .#..#.....
        ..#....#.#
        #..#....#.
        .##.#..###
        ##...#..#.
        .#....####
        """

    @test findbest(parse_map(m1)) == (8, (3, 4))
    @test findbest(parse_map(m2)) == (33, (5, 8))

    @test A() == (303, (26, 29))
end


# Part 2
#
# Use a spinning laser to destroy asteroids, work out which the 200th laser to be destroyed is.
#
# This would be really easy with a more traditional representation of angles ;)
#
# Just need to sort the angles and pick the 200th... but that's a bit tricky
#


"""
    lessthan_angle(a, b)

We want to start in the negative y direction and proceed clockwise.

This took a while to get right and is a bit fiddly.

Possibly better to use the weird angle definition for uniqueness checking and
arctan method for ordering the unique angles.

The quadrant identifiers are the tuple `>=(0).(asteroid .- station)`

The quadrants go:

(1,0), (1,1), (0,1), (0,0)

Quadrants all descend:

[0, -inf)
[inf, 0]
(-inf, 0]
(inf, 0)

0 -> negatives
inf -> 0
negatives -> -Inf
bignums -> smallnums

"""
function lessthan_angle(a, b)
    if a[2] == b[2]
        return a[1] > b[1]
    else
        if a[2] == (true, false)
            return true
        elseif b[2] == (true, false)
            return false
        else
            return a[2] > b[2]
        end
    end
end


"""
location of nth asteroid to get lasered

I think this is pretty ugly :(

"""
function lucky_bet(station, asteroids, n = 200)
    asteroids = setdiff(asteroids, (station,))
    while true
        angles = map(asteroid -> angle(station, asteroid),
                     asteroids)

        "closest asteroid with this angle"
        closest(angle) = last(minimum(asteroids[angles .== (angle,)]) do asteroid
            # euclid. distance
            # sqrt not required because it is monotone.
            sum((asteroid .- station).^2), asteroid
        end)

        if n - length(unique(angles)) <= 0
            # The nth unique angle points to the nth asteroid to be destroyed
            nth_angle = unique(angles[sortperm(angles, lt=lessthan_angle)])[n]
            return closest(nth_angle)
        else
            n -= length(unique(angles))
            # remove the closest asteroids at each angle
            asteroids = setdiff(asteroids, map(closest, unique(angles)))
        end
    end
end


B() = lucky_bet((26,29), readinput())


@testset "day10B" begin
    asteroids = parse_map("""
        .#..##.###...#######
        ##.############..##.
        .#.######.########.#
        .###.#######.####.#.
        #####.##.#.##.###.##
        ..#####..#.#########
        ####################
        #.####....###.#.#.##
        ##.#################
        #####.##.###..####..
        ..######..##.#######
        ####.##.####...##..#
        .#####..#.######.###
        ##...#.##########...
        #.##########.#######
        .####.#.###.###.#.##
        ....##.##.###..#####
        .#.#.###########.###
        #.#.#.#####.####.###
        ###.##.####.##.#..##
        """)
    station = findbest(asteroids)[2]
    @test station == (11,13)
    @test lucky_bet(station, asteroids, 1) == (11,12)
    @test lucky_bet(station, asteroids, 2) == (12,1)
    @test lucky_bet(station, asteroids, 3) == (12,2)
    @test lucky_bet(station, asteroids) == (8,2)
    # Test the case where you can't see the nth asteroid initially
    @test lucky_bet(station, asteroids, 211) == (11,11)

    @test B() == (4,8)
end

end
