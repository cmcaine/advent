using Test: @test, @testset
using advent
using advent.Intcode

@testset "day1" begin
    fuelcost = advent.day1.fuelcost
    @test fuelcost(14) == 2
    @test fuelcost(1969) == 966
    @test advent.day1.A() == 3273715
    @test advent.day1.B() == 4907702
end


@testset "Intcode" begin
    # day 2
    @test interpret_intcode([1, 0, 0, 0, 99]) == [2, 0, 0, 0, 99]
    @test interpret_intcode([2,3,0,3,99]) == [2,3,0,6,99]
    @test interpret_intcode([1,1,1,4,99,5,6,0,99]) == [30,1,1,4,2,5,6,0,99]
    @test interpret_intcode([1,9,10,3,2,3,11,0,99,30,40,50]) ==
        [3500,9,10,70,2,3,11,0,99,30,40,50]


    # day 5

    @testset "IO" begin
        @test interpret_intcode!([4, 0, 99], []) == ([4, 0, 99], [4])
        @test interpret_intcode!([3, 1, 99], [5]) == ([3, 5, 99], [])
    end

    @testset "parameter modes" begin
        @test interpret_intcode!([01101, 3, 3, 0, 99]) == [6, 3, 3, 0, 99]
        @test interpret_intcode!([00101, 3, 0, 0, 99]) == [104, 3, 0, 0, 99]
        # Ignore parameter mode on destination parameter
        @test interpret_intcode!([11101, 3, 3, 0, 99]) == [6, 3, 3, 0, 99]
    end

    @testset "comparisons" begin
        # Test if input is 8
        @test interpret_intcode([3,3,1108,-1,8,3,4,3,99], [8])[2] == [1]
        @test interpret_intcode([3,3,1108,-1,8,3,4,3,99], [7])[2] == [0]
        # Test if input is < 8
        @test interpret_intcode([3,9,7,9,10,9,4,9,99,-1,8], [7])[2] == [1]
        @test interpret_intcode([3,9,7,9,10,9,4,9,99,-1,8], [8])[2] == [0]
        @test interpret_intcode([3,9,7,9,10,9,4,9,99,-1,8], [9])[2] == [0]
        @test interpret_intcode([3,3,1107,-1,8,3,4,3,99], [9])[2] == [0]
    end

    @testset "jumps" begin
        # output 0 if input is 0, else 1
        @test interpret_intcode([3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9], [0])[2] == [0]
        @test interpret_intcode([3,3,1105,-1,9,1101,0,0,12,4,12,99,1], [0])[2] == [0]
    end

    @testset "day5 test program" begin
        testProg = readtape(joinpath(@__DIR__, "../src/day5/input.txt"))
        @test all(interpret_intcode(testProg, [1])[2][1:end-1] .== 0)
        @test interpret_intcode(
            [3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
             1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
             999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99],
            [7])[2] == [999]
    end
end


@testset "day2" begin
    @test advent.day2.A() == 11590668
    @test advent.day2.B() == 2254
end


@testset "day3" begin

    @testset "intersection" begin
        Segment = advent.day3.Segment
        intersection = advent.day3.intersection

        A = Segment(0, 0, 5, 0)
        B = Segment(2, 2, 2, -1)
        C = Segment(0, 0, 1, 0)
        D = Segment(1, 0, 2, 0)

        @test intersection(A, B) == intersection(B, A) == (2, 0)
        @test intersection(C, D) == intersection(D, C) == (1, 0)
        @test intersection(B, C) == intersection(C, B) == nothing
    end

    sample1 = [
        "R75,D30,R83,U83,L12,D49,R71,U7,L72",
        "U62,R66,U55,R34,D71,R55,D58,R83"
    ]

    sample2 = [
        "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51",
        "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"
    ]

    delay_tracking_segments = advent.day3.delay_tracking_segments
    @test delay_tracking_segments(split.(sample1, ",")[1])[end].delay == 410

    closest_intersection = advent.day3.closest_intersection
    @test closest_intersection(sample1) == 159
    @test closest_intersection(sample2) == 135

    min_delay = advent.day3.min_delay
    @test min_delay(sample1) == 610
    @test min_delay(sample2) == 410

    @test advent.day3.A() == 280
    @test advent.day3.B() == 10554
end


@testset "day4" begin
    password_checkerB = advent.day4.password_checkerB
    @test password_checkerB("112233")
    @test !password_checkerB("123444")
    @test password_checkerB("111122")
    @test password_checkerB("123455")

    @test advent.day4.A() == 1063
    @test advent.day4.B() == 686
end

@testset "day5" begin
    @test advent.day5.A() == 13978427
    @test advent.day5.B() == 11189491
end

@testset "day6" begin
    @test advent.day6.count_orbits("""COM)B
    B)C
    C)D
    D)E
    E)F
    B)G
    G)H
    D)I
    E)J
    J)K
    K)L""") == 42

    # Re-orderings permitted
    @test advent.day6.count_orbits("""COM)B
    C)D
    B)C
    D)E
    E)F
    B)G
    G)H
    D)I
    E)J
    J)K
    K)L""") == 42

    @test advent.day6.A() == 142915

    @test advent.day6.transfers_to_santa("""COM)B
    B)C
    C)D
    D)E
    E)F
    B)G
    G)H
    D)I
    E)J
    J)K
    K)L
    K)YOU
    I)SAN""") == 4

    @test advent.day6.B() == 283
end

@testset "day7" begin
    @test advent.day7.maximum_output([3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0]) ==
        (43210, [4,3,2,1,0])
    @test advent.day7.maximum_output([3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,
                                      23,1,24,23,23,4,23,99,0,0]) ==
        (54321, [0:4...])
    @test advent.day7.maximum_output([3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,
                                      1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0]) ==
        (65210, [1,0,4,3,2])

    @test advent.day7.A() == (34852, [1,3,2,4,0])

    mof = advent.day7.maximum_output_feedback

    @test mof([3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,
               27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5]) == (139629729, [9,8,7,6,5])

    @test mof([3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,
               1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,
               1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,
               56,-1,56,1005,56,6,99,0,0,0,0,10]) ==
        (18216, [9, 7, 8, 5, 6])

    @test advent.day7.B() == (44282086, [6, 9, 5, 8, 7])
end

@testset "day8" begin
    @test advent.day8.A() == 1560
    @test advent.day8.decode(parse.(Int, split("0222112222120000", "")), 2, 2) == [0 1; 1 0]
end
