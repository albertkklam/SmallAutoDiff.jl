abstract type Node end

mutable struct VariableNode <: Node
    size::NTuple{N, Int} where {N}
    eltype::Type
    name::String
end

mutable struct ConstantNode <: Node
    size::NTuple{N, Int} where {N}
    eltype::Type
    name::String
end

mutable struct Counter{T}
    node_type::T
    count::Int
end

Counter(node_type::Type{<:Node}) = Counter(node_type, 0)

function VariableNode(counter::Counter, size::NTuple{N, Int}, eltype::Type, name::Union{Nothing, String}=nothing) where {N}
    counter.count += 1
    name = isnothing(name) ? "var_$(counter.count)" : name
    return VariableNode(size, eltype, name)
end

function ConstantNode(counter::Counter, size::NTuple{N, Int}, eltype::Type, name::Union{Nothing, String}=nothing) where {N}
    counter.count += 1
    name = isnothing(name) ? "const_$(counter.count)" : name
    return ConstantNode(size, eltype, name)
end

