module advent

include("Intcode.jl")

for i in 1:25
    fn = joinpath(@__DIR__, "day$i/day$i.jl")
    isfile(fn) && include(fn)
end

end
