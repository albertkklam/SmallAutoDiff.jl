function add_grad(prev_adjoint::ConstantNode, node::Node)
    return [eval(prev_adjoint.val), eval(prev_adjoint.val)]
end

function subtract_grad(prev_adjoint::ConstantNode, node::Node)
    return [eval(prev_adjoint.val), -eval(prev_adjoint.val)]
end

function multiply_grad(prev_adjoint::ConstantNode, node::Node)
    return [eval(prev_adjoint.val) * eval(node.right_operand.val), 
            eval(prev_adjoint.val) * eval(node.left_operand.val)]
end

function divide_grad(prev_adjoint::ConstantNode, node::Node)
    return [eval(prev_adjoint.val) / eval(node.right_operand.val), 
            -(eval(prev_adjoint.val) * (eval(node.left_operand.val) / (eval(node.right_operand.val) ^ 2)))]
end

function power_grad(prev_adjoint::ConstantNode, node::Node)
    return [eval(prev_adjoint.val) * eval(node.right_operand.val) * (eval(node.left_operand.val) ^ eval(node.right_operand.val)),
            eval(prev_adjoint.val) * log(eval(node.left_operand.val)) * eval(node.val)]
end

function dot_product_grad(prev_adjoint::ConstantNode, node::Node)
    return [eval(prev_adjoint.val) * transpose(eval(node.right_operand.val)), 
            transpose(eval(node.left_operand.val)) * eval(prev_adjoint.val)]
end

function transpose_grad(prev_adjoint::ConstantNode, node::Node)
    return [transpose(eval(prev_adjoint.val)), nothing]
end

function sum_grad(prev_adjoint::ConstantNode, node::Node)
    return [eval(prev_adjoint.val) * ones(node.left_operand.size), nothing]
end

function maximum_grad(prev_adjoint::ConstantNode, node::Node; dims::Union{Nothing, Int}=nothing)
    max_val = eval(node.val)
    maxs_in_node_idx = ifelse.(eval(node.left_operand.val) .== max_val, 1, 0)
    grad_denom = sum(maxs_in_node_idx, dims=dims)
    grad = maxs_in_node_idx ./ grad_denom
    return [eval(prev_adjoint.val) * grad, nothing]
end

function exp_grad(prev_adjoint::ConstantNode, node::Node)
    return [eval(prev_adjoint.val) * eval(node.val), nothing]
end

function log_grad(prev_adjoint::ConstantNode, node::Node)
    return [eval(prev_adjoint.val) / eval(node.left_operand.val), nothing]
end

function sin_grad(prev_adjoint::ConstantNode, node::Node)
    return [eval(prev_adjoint.val) * cos.(eval(node.left_operand.val)), nothing]
end

function cos_grad(prev_adjoint::ConstantNode, node::Node)
    return [-eval(prev_adjoint.val) * sin.(eval(node.left_operand.val)), nothing]
end

function unbroadcast_adjoint(adjoint::ConstantNode, node::Node)
    size_adjoint = adjoint.size
    node_size = node.size
    if size_adjoint != node_size
        dim_diff = abs(length(size_adjoint) - length(node_size))
        if dim_diff > 0
            summation_diffs = Tuple(1:dim_diff)
            summation_diff_adjoint = sum(eval(adjoint.val), dims=summation_diffs)
            originally_ones = [(size == 1) ? axis : nothing for (axis, size) in enumerate(node_size)]
            filtered_ones = Tuple(filter(x -> !isnothing(x), originally_ones))
            if length(filtered_ones) > 0
                unbroadcast_adjoint = sum(summation_diff_adjoint, dims=filtered_ones)
                return unbroadcast_adjoint
            else
                return summation_diff_adjoint
            end
        end
    else
        return adjoint
    end
end
