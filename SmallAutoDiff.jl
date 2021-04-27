module SmallAutoDiff

include("dualnumber.jl")
export DualNumber

include("dualnumber_math.jl")

include("forward.jl")
export derivative, differentiate, check_derivative

end
