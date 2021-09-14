abstract type Node end

struct NodeParameters
    name::Union{Nothing, String}
end

NodeParameters() = NodeParameters(nothing)

struct Counter{T}
    node_type::T
    count::Int
end

Counter(node_type::Union{Node, Type{<:Node}}) = Counter(node_type, 0)

struct VariableNode <: Node
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
    @assert val_type <: Union{Real, AbstractArray}
    if val_type <: AbstractArray
        return VariableNode(var_name, val, size(evaled_val), eltype(evaled_val))
    else
        return VariableNode(var_name, val, 1, eltype(evaled_val))
    end
end

VariableNode(node_parameters::NodeParameters, val::Union{Symbol,Expr}, 
             counter::Union{Nothing, Counter}=nothing) = 
             VariableNode(node_parameters.name, val, counter)

struct ConstantNode <: Node
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
    @assert val_type <: Union{Real, AbstractArray}
    if val_type <: AbstractArray
        return ConstantNode(var_name, val, size(evaled_val), eltype(evaled_val))
    else
        return ConstantNode(var_name, val, 1, eltype(evaled_val))
    end
end

ConstantNode(node_parameters::NodeParameters, val::Union{Symbol,Expr}, 
             counter::Union{Nothing, Counter}=nothing) = 
             ConstantNode(node_parameters.name, val, counter)

struct OperationalNode <: Node
    name::String
    val::Union{Symbol,Expr}
    operator_name::String
    left_operand::Node
    right_operand::Union{Nothing, Node}
    size::Union{Int, NTuple{N, Int}} where {N}
    eltype::Type
end

function OperationalNode(name::Union{Nothing, String}, 
                         val::Union{Symbol,Expr}, operator_name::String, 
                         left_operand::Node, right_operand::Union{Nothing, Node}=nothing,
                         counter::Union{Nothing, Counter}=nothing)
    if isnothing(counter)
        var_name = isnothing(name) ? "$(operator_name)_1" : name
    else
        counter.count += 1
        var_name = isnothing(name) ? "$(operator_name)_$(counter.count)" : name
    end
    
    evaled_val = eval(val)
    val_type = typeof(evaled_val)
    @assert val_type <: Union{Real, AbstractArray}
    if val_type <: AbstractArray
        return OperationalNode(var_name, val, operator_name, left_operand, right_operand, size(evaled_val), eltype(evaled_val))
    else
        return OperationalNode(var_name, val, operator_name, left_operand, right_operand, 1, eltype(evaled_val))
    end
end

OperationalNode(node_parameters::NodeParameters, val::Union{Symbol,Expr}, operator_name::String,
                left_operand::Node, right_operand::Union{Nothing, Node}=nothing, 
                counter::Union{Nothing, Counter}=nothing) = 
                OperationalNode(node_parameters.name, val, operator_name, left_operand, right_operand, counter)

function create_opnode(method::Symbol, left_node::Node, 
                       right_node::Union{Nothing, Node}=nothing, 
                       name::Union{Nothing,String}=nothing, 
                       counter::Union{Nothing, Counter}=nothing;
                       broadcast_method::Bool=false, dims::Union{Nothing,Int}=nothing)
    if isnothing(right_node) & (method != (:maximum))
        val = broadcast_method ? Expr(:call, :broadcast, method, left_node.val) : Expr(:call, method, left_node.val)
    elseif method == (:maximum)
        val = isnothing(dims) ? Expr(:call, method, left_node.val) : Expr(:call, method, left_node.val, :($(Expr(:kw, :dims, dims))))
    else
        val = broadcast_method ? Expr(:call, :broadcast, method, left_node.val, right_node.val) : Expr(:call, method, left_node.val, right_node.val)
    end
    pretty_operator_name = prettify_operator_name(method, broadcast_method)
    return OperationalNode(name, val, pretty_operator_name, left_node, right_node, counter)
end

function prettify_operator_name(method::Symbol, broadcast_method::Bool)
    name_dict = Dict{Symbol, String}(
        (:+) => "add", (:-) => "subtract", (:*) => "multiply", (:/) => "divide",
        (:÷) => "integer_divide", (:^) => "power", (:⋅) => "dot_product", 
        (:sum) => "sum", (:maximum) => "maximum", (:exp) => "exp", (:log) => "log", 
        (:sin) => "sin", (:cos) => "cos", (:transpose) => "transpose"
        )
    pretty_operator_name = broadcast_method ? "broadcast_" * name_dict[method] : name_dict[method]
    return pretty_operator_name
end

struct NodesQueue
    nodes::Vector{Node}
    node_names::Vector{String}
end

NodesQueue() = NodesQueue(Vector{Node}(), Vector{String}())

function push!(nodes_queue::NodesQueue, node::Node)
    push!(nodes_queue.nodes, node)
    push!(nodes_queue.node_names, node.name)
end

function Base.:popfirst!(nodes_queue::NodesQueue)
    popfirst!(nodes_queue.nodes)
    popfirst!(nodes_queue.node_names)
end

function ∈(nodes_queue::NodesQueue, node::Node)
    return node.name ∈ nodes_queue.node_names
end

function length(nodes_queue::NodesQueue)
    return length(nodes_queue.nodes)
end
