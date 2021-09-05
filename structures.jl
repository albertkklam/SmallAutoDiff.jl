abstract type Node end

mutable struct NodeParameters
    size::Union{Int, NTuple{N, Int}} where {N}
    eltype::Type
    name::Union{Nothing, String}
end

NodeParameters(size::Union{Int, NTuple{N, Int}}, eltype::Type) where {N} = NodeParameters(size, eltype, nothing)

mutable struct Counter{T}
    node_type::T
    count::Int
end

Counter(node_type::Union{Node, Type{<:Node}}) = Counter(node_type, 0)

mutable struct VariableNode <: Node
    size::Union{Int, NTuple{N, Int}} where {N}
    eltype::Type
    name::String

    val::Symbol
end

function VariableNode(node_parameters::NodeParameters, val::Symbol, counter::Union{Nothing, Counter}=nothing)
    if !(isnothing(counter))
        counter.count += 1
        name = isnothing(node_parameters.name) ? "var_$(counter.count)" : node_parameters.name
    else
        name = isnothing(node_parameters.name) ? "var_1" : node_parameters.name
    end
    return VariableNode(node_parameters.size, node_parameters.eltype, name, val)
end

mutable struct ConstantNode <: Node
    size::Union{Int, NTuple{N, Int}} where {N}
    eltype::Type
    name::String

    val::Symbol
end

function ConstantNode(node_parameters::NodeParameters, val::Symbol, counter::Union{Nothing, Counter}=nothing)
    if !(isnothing(counter))
        counter.count += 1
        name = isnothing(node_parameters.name) ? "const_$(counter.count)" : node_parameters.name
    else
        name = isnothing(node_parameters.name) ? "const_1" : node_parameters.name
    end
    return ConstantNode(node_parameters.size, node_parameters.eltype, name, val)
end

mutable struct OperationalNode <: Node
    size::Union{Int, NTuple{N, Int}} where {N}
    eltype::Type
    name::String

    result::Symbol
    operand::String
    left_operand::Union{VariableNode, ConstantNode}
    right_operand::Union{Nothing, VariableNode, ConstantNode}
end

function OperationalNode(node_parameters::NodeParameters, 
                         result::Symbol, operand::String, 
                         left_operand::Union{VariableNode, ConstantNode}, 
                         right_operand::Union{Nothing, VariableNode, ConstantNode}=nothing,
                         counter::Union{Nothing, Counter}=nothing)
    if !(isnothing(counter))
        counter.count += 1
        name = isnothing(node_parameters.name) ? "$(operand)_$(counter.count)" : node_parameters.name
    else
        name = isnothing(node_parameters.name) ? "$(operand)_1" : node_parameters.name
    end
    return OperationalNode(node_parameters.size, node_parameters.eltype, name, result, operand, left_operand, right_operand)
end
