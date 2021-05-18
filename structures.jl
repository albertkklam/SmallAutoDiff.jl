abstract type Node end

mutable struct NodeParameters
    size::NTuple{N, Int} where {N}
    eltype::Type
    name::Union{Nothing, String}
end

NodeParameters(size::NTuple{N, Int}, eltype::Type) where {N} = NodeParameters(size, eltype, nothing)

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

mutable struct OperationalNode <: Node
    size::Union{Nothing, NTuple{N, Int}} where {N}
    eltype::Union{Nothing, Type}
    name::Union{Nothing, String}

    operand::String
    left_operand::Union{Nothing, Node}
    right_operand::Union{Nothing, Node}
end

OperationalNode(operand_name::String) = OperationalNode(nothing, nothing, nothing, operand_name, nothing, nothing)

mutable struct Counter{T}
    node_type::T
    count::Int
end

Counter(node_type::Union{Node, Type{<:Node}}) = Counter(node_type, 0)

function VariableNode(node_parameters::NodeParameters, counter::Union{Nothing, Counter}=nothing)
    if !(isnothing(counter))
        counter.count += 1
        name = isnothing(node_parameters.name) ? "var_$(counter.count)" : node_parameters.name
    else
        name = isnothing(node_parameters.name) ? "var_1" : node_parameters.name
    end
    return VariableNode(node_parameters.size, node_parameters.eltype, name)
end

function ConstantNode(node_parameters::NodeParameters, counter::Union{Nothing, Counter}=nothing)
    if !(isnothing(counter))
        counter.count += 1
        name = isnothing(node_parameters.name) ? "const_$(counter.count)" : node_parameters.name
    else
        name = isnothing(node_parameters.name) ? "const_1" : node_parameters.name
    end
    return ConstantNode(node_parameters.size, node_parameters.eltype, name)
end

function OperationalNode(node_parameters::NodeParameters, operand::String, left_operand::Node, 
                         right_operand::Union{Nothing, Node}=nothing, counter::Union{Nothing, Counter}=nothing)
    if !(isnothing(counter))
        counter.count += 1
        name = isnothing(node_parameters.name) ? "$(operand)_$(counter.count)" : node_parameters.name
    else
        name = isnothing(node_parameters.name) ? "$(operand)_1" : node_parameters.name
    end
    return OperationalNode(node_parameters.size, node_parameters.eltype, name, operand, left_operand, right_operand)
end
