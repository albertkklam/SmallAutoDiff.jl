# Example 1
x = VariableNode("x", 0.5)
y = VariableNode("y", 4)
z = VariableNode("z", -2.3)

c_1 = ConstantNode("c_1", 3)
c_2 = ConstantNode("c_2", 2)
c_3 = ConstantNode("c_3", 3)

f = sin(x ^ (y + z)) - c_1 * log((x ^ c_2) * (y ^ c_3))

println("This should print ≈-8.0148166: ", eval(f.val))

# Example 2
function small_func(x_val::Real, y_val::Real, z_val::Real; 
                    counters::Union{Nothing,Dict{String, AbstractCounter}}=nothing)
    constant_counter = isnothing(counters) ? nothing : 
                    haskey(counters, "ConstantNode") ? counters["ConstantNode"] :
                    nothing
    operational_counter = isnothing(counters) ? nothing : 
                        haskey(counters, "OperationalNode") ? counters["OperationalNode"] :
                        nothing

    x = VariableNode("x", x_val)
    y = VariableNode("y", y_val)
    z = VariableNode("z", z_val)

    c_1 = ConstantNode(nothing, 3, constant_counter)
    c_2 = ConstantNode(nothing, 2, constant_counter)
    c_3 = ConstantNode(nothing, 3, constant_counter)

    if isnothing(operational_counter)
        return  sin(x ^ (y + z)) - ((c_1 * z) * log((x ^ c_2) * (y ^ c_3)))
    else
        with_counter(op, counter) = (args...) -> op(args..., counter)
        let + = with_counter(+, operational_counter), - = with_counter(-, operational_counter), * = with_counter(*, operational_counter), ^ = with_counter(^, operational_counter)
                return  sin(x ^ (y + z)) - ((c_1 * z) * log((x ^ c_2) * (y ^ c_3)))
        end
    end
end

constant_counter = Counter(ConstantNode)
operational_counter = DictCounter(OperationalNode)
counters = Dict(["ConstantNode" => constant_counter, "OperationalNode" => operational_counter])
args = [0.5, 4, -2.3]
f = small_func(args..., counters=counters)
initial_const = 1
g = gradient(f, initial_const, counters)

suspect = eval.([g["x"].val, g["y"].val, g["z"].val])

println("The gradient function gives: ", suspect)
println("The approximate gradient should be: ", compute_approximate_gradient(small_func, args, suspect))
println("Is the gradient approximately correct? (this should print true): ", check_gradient(small_func, args, suspect))
