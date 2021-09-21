module SmallAutoDiff

include("dualnumbers/dualnumber.jl")
export DualNumber

include("dualnumbers/dualnumber_math.jl")

include("forward.jl")
export derivative, differentiate, check_derivative

include("structures.jl")
export Node, NodeParameters, AbstractCounter, Counter, DictCounter
export VariableNode, ConstantNode, OperationalNode, create_opnode
export NodesQueue, push!, popfirst!, ∈, length

include("node_operations.jl")

include("grads.jl")
export add_grad, subtract_grad, multiply_grad, divide_grad, power_grad, dot_product_grad
export transpose_grad, maximum_grad, sum_grad, exp_grad, log_grad, sin_grad, cos_grad, unbroadcast_adjoint

include("reverse.jl")
export gradient, compute_approximate_gradient, check_gradient

end
