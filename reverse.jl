function gradient(node::Node, counters::Union{Nothing,Dict{String, Counter}}=nothing)
    adjoint = Dict{String, Node}()
    grad = Dict{String, Node}()
    queue = NodeQueue()

    constant_counter = isnothing(counters) ? nothing : counters["ConstantNode"]

    c1 = ones(node.size)
    adjoint[node.name] = ConstantNode(nothing, :c1, constant_counter)
    push!(queue, node)

    while length(queue) > 0
        current_node = popfirst!(queue)

        if isa(current_node, ConstantNode)
            continue
        end

        if isa(current_node, VariableNode)
            grad[current_node.name] = adjoint[current_node.name]
            continue
        end

        current_adjoint = adjoint[current_node.name]
        current_operator_name = current_node.operator_name

        operator_grad = getfield(SmallAutoDiff, Symbol(current_operator_name * "_grad"))
        next_adjoint = operator_grad(current_adjoint, current_node)

        left_adjoint_val = adjoint[current_node.left_operand.name] + next_adjoint[1]
        left_adjoint = ConstantNode(nothing, :left_adjoint_val, constant_counter)
        adjoint[current_node.left_operand.name] = unbroadcast_adjoint(left_adjoint, current_node.left_operand)

        if current_node.left_operand ∉ queue
            push!(queue, current_node.left_operand)
        end

        if !isnothing(current_node.right_operand)
            right_adjoint_val = adjoint[current_node.right_operand.name] + next_adjoint[2]
            right_adjoint = ConstantNode(nothing, :right_adjoint_val, constant_counter)
            adjoint[current_node.right_operand.name] = unbroadcast_adjoint(right_adjoint, current_node.right_operand)

            if current_node.right_operand ∉ queue
                push!(queue, current_node.right_operand)
            end
        end
    end
    return grad
end
