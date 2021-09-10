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

function dot_product_grad(prev_adjoint, node::Node)
    return [prev_adjoint * transpose(eval(node.right_operand.val)), 
            transpose(eval(node.left_operand.val)) * prev_adjoint]
end

function transpose_grad(prev_adjoint, node::Node)
    return [transpose(prev_adjoint), nothing]
end

function maximum_grad(prev_adjoint, node::Node; dims::Union{Nothing, Int}=nothing)
    max_val = eval(node.val)
    maxs_in_node_idx = ifelse.(eval(node.left_operand.val) .== max_val, 1, 0)
    grad_denom = sum(maxs_in_node_idx, dims=dims)
    grad = maxs_in_node_idx ./ grad_denom
    return [prev_adjoint * grad, nothing]
end

function sum_grad(prev_adjoint, node::Node)
    return [prev_adjoint * ones(node.left_operand.size), nothing]
end

function exp_grad(prev_adjoint, node::Node)
    return [prev_adjoint * eval(node.val), nothing]
end

function log_grad(prev_adjoint, node::Node)
    return [prev_adjoint / eval(node.left_operand.val), nothing]
end

function sin_grad(prev_adjoint, node::Node)
    return [prev_adjoint * cos.(eval(node.left_operand.val)), nothing]
end

function cos_grad(prev_adjoint, node::Node)
    return [-prev_adjoint * sin.(eval(node.left_operand.val)), nothing]
end

function unbroadcast_adjoint(adjoint, node::Node)
    size_adjoint = size(adjoint)
    node_size = node.size
    if size_adjoint != node_size
        dim_diff = abs(length(size_adjoint) - length(node_size))
        if dim_diff > 0
            summation_diffs = Tuple(1:dim_diff)
            summation_diff_adjoint = sum(adjoint, dims=summation_diffs)
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
