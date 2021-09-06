abstract type Node end

mutable struct NodeParameters
    name::Union{Nothing, String}
end

NodeParameters() = NodeParameters(nothing)

mutable struct Counter{T}
    node_type::T
    count::Int
end

Counter(node_type::Union{Node, Type{<:Node}}) = Counter(node_type, 0)

mutable struct VariableNode <: Node
    name::String
    val::Union{Symbol,Expr}
    size::Union{Int, NTuple{N, Int}} where {N}
    eltype::Type
end

function VariableNode(name::Union{Nothing, String}, val::Union{Symbol,Expr}, 
                      counter::Union{Nothing, Counter}=nothing)
    if isnothing(counter)
        var_name = isnothing(name) ? "var_1" : name
    else
        counter.count += 1
        var_name = isnothing(name) ? "var_$(counter.count)" : name
    end
    
    evaled_val = eval(val)
    val_type = typeof(evaled_val)
    @assert val_type <: Union{Real, Array}
    if val_type <: Array
        return VariableNode(var_name, val, size(evaled_val), eltype(evaled_val))
    else
        return VariableNode(var_name, val, 1, eltype(evaled_val))
    end
end

VariableNode(node_parameters::NodeParameters, val::Union{Symbol,Expr}, 
             counter::Union{Nothing, Counter}=nothing) = 
             VariableNode(node_parameters.name, val, counter)

mutable struct ConstantNode <: Node
    name::String
    val::Union{Symbol,Expr}
    size::Union{Int, NTuple{N, Int}} where {N}
    eltype::Type
end

function ConstantNode(name::Union{Nothing, String}, val::Union{Symbol,Expr}, 
                      counter::Union{Nothing, Counter}=nothing)
    if isnothing(counter)
        var_name = isnothing(name) ? "const_1" : name
    else
        counter.count += 1
        var_name = isnothing(name) ? "const_$(counter.count)" : name
    end

    evaled_val = eval(val)
    val_type = typeof(evaled_val)
    @assert val_type <: Union{Real, Array}
    if val_type <: Array
        return ConstantNode(var_name, val, size(evaled_val), eltype(evaled_val))
    else
        return ConstantNode(var_name, val, 1, eltype(evaled_val))
    end
end

ConstantNode(node_parameters::NodeParameters, val::Union{Symbol,Expr}, 
             counter::Union{Nothing, Counter}=nothing) = 
             ConstantNode(node_parameters.name, val, counter)

mutable struct OperationalNode <: Node
    name::String
    result::Union{Symbol,Expr}
    operand::String
    left_operand::Union{VariableNode, ConstantNode}
    right_operand::Union{Nothing, VariableNode, ConstantNode}
    size::Union{Int, NTuple{N, Int}} where {N}
    eltype::Type
end

function OperationalNode(name::Union{Nothing, String}, 
                         result::Union{Symbol,Expr}, operand::String, 
                         left_operand::Union{VariableNode, ConstantNode}, 
                         right_operand::Union{Nothing, VariableNode, ConstantNode}=nothing,
                         counter::Union{Nothing, Counter}=nothing)
    if isnothing(counter)
        var_name = isnothing(name) ? "$(operand)_1" : name
    else
        counter.count += 1
        var_name = isnothing(name) ? "$(operand)_$(counter.count)" : name
    end
    
    evaled_result = eval(result)
    result_type = typeof(evaled_result)
    @assert result_type <: Union{Real, Array}
    if result_type <: Array
        return OperationalNode(var_name, result, operand, left_operand, right_operand, size(evaled_result), eltype(evaled_result))
    else
        return OperationalNode(var_name, result, operand, left_operand, right_operand, 1, eltype(evaled_result))
    end
end

OperationalNode(node_parameters::NodeParameters, result::Union{Symbol,Expr}, operand::String,
                left_operand::Union{VariableNode, ConstantNode}, 
                right_operand::Union{Nothing, VariableNode, ConstantNode}=nothing, 
                counter::Union{Nothing, Counter}=nothing) = 
                OperationalNode(node_parameters.name, result, operand, left_operand, right_operand, counter)

function create_opnode(method::Symbol, left_node::Union{VariableNode, ConstantNode}, 
                       right_node::Union{Nothing, VariableNode, ConstantNode}=nothing, 
                       name::Union{Nothing,String}=nothing, 
                       counter::Union{Nothing, Counter}=nothing)
    if isnothing(right_node)
        result = Expr(:call, method, left_node.val)
    else
        result = Expr(:call, method, left_node.val, right_node.val)
    end
    return OperationalNode(name, result, String(method), left_node, right_node, counter)
end
