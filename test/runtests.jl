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
