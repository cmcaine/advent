module day6

using Base.Iterators: flatten
using LightGraphs: SimpleDiGraph, add_edge!, gdistances

"""
    count_orbits(sys)

Number of direct and indirect orbits in a system of orbiting bodies.

COM -> A -> B -> C

= 6 orbits

For each entity, the number of orbits == path length to COM.

"""
count_orbits(sys) = sum(gdistances(sys, 1))

count_orbits(sys::AbstractString) = count_orbits(read_orbits(sys))


"""
    read_orbits(str)

Can probably count as we read.

Each entity directly orbits exactly one other, but entities may appear in the input before the thing that they orbit, so we either need to re-order the input or build a graph.

Things wot we could do:

 - Build an adjacency list with strings as node keys then write my own path length calculation.
    - Pretty easy. Just iterate through the tree defined by the adjacency list, recording the depth that we see each node at (or just `acc += depth` for each node).
    - Strings are three characters long, so plausibly just int comparisons.
 - Build a LightGraphs Digraph and just use gdistances on it
    - Need to precalculate the number of nodes and map from strings to ints
    - gdistances doesn't know the special properties of the graph, so it may be
    slower than it could be.

"""
function read_orbits(str)
    orbits = split.(split(str, '\n'), ')')
    key = Dict(k => i for (i, k) in enumerate(unique(["COM", flatten(orbits)...])))
    g = SimpleDiGraph(length(key))
    for (principal, satellite) in orbits
        add_edge!(g, key[principal], key[satellite])
    end
    return g
end

A() = count_orbits(read_orbits(strip(String(read(joinpath(@__DIR__, "input.txt"))))))

end
