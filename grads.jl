function add_grad(prev_adjoint, node::Node)
    return [prev_adjoint, prev_adjoint]
end

function subtract_grad(prev_adjoint, node::Node)
    return [prev_adjoint, -prev_adjoint]
end

function multiply_grad(prev_adjoint, node::Node)
    return [prev_adjoint * eval(node.right_operand.val), 
            prev_adjoint * eval(node.left_operand.val)]
end

function divide_grad(prev_adjoint, node::Node)
    return [prev_adjoint / eval(node.right_operand.val), 
            -(prev_adjoint * (eval(node.left_operand.val) / (eval(node.right_operand.val) ^ 2)))]
end

function power_grad(prev_adjoint, node::Node)
    return [prev_adjoint * eval(node.right_operand.val) * (eval(node.left_operand.val) ^ eval(node.right_operand.val)),
            prev_adjoint * log(eval(node.left_operand.val)) * eval(node.val)]
end

function sum_grad(prev_adjoint, node::Node)
    return [prev_adjoint * ones(node.left_operand.size), nothing]
end

function maximum_grad(prev_adjoint, node::Node; dims::Union{Nothing, Int}=nothing)
    max_val = eval(node.val)
    maxs_in_node_idx = ifelse.(eval(node.left_operand.val) .== max_val, 1, 0)
    grad_denom = sum(maxs_in_node_idx, dims=dims)
    grad = maxs_in_node_idx ./ grad_denom
    return [prev_adjoint * grad, nothing]
end

function exp_grad(prev_adjoint, node::Node)
    return [prev_adjoint * eval(node.val), nothing]
end

function log_grad(prev_adjoint, node::Node)
    return [prev_adjoint / eval(node.left_operand.val), nothing]
end
