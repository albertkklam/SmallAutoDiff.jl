module SmallAutoDiff

include("dualnumber.jl")
export DualNumber

include("dualnumber_math.jl")

include("forward.jl")
export derivative, differentiate, check_derivative

include("structures.jl")
export NodeParameters, Counter, VariableNode, ConstantNode, OperationalNode, create_opnode

include("node_operations.jl")

end
