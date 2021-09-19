function gradient(node::Node, 
                  initial_const::Union{Real,AbstractArray{<:Real}},
                  counters::Union{Nothing,Dict{String, <:AbstractCounter}}=nothing)
    adjoint = Dict{String, Node}()
    grad = Dict{String, Node}()
    queue = NodesQueue()

    constant_counter = isnothing(counters) ? nothing : 
                       haskey(counters, "ConstantNode") ? counters["ConstantNode"] : 
                       nothing

    adjoint[node.name] = ConstantNode(nothing, initial_const, constant_counter)
    push!(queue, node)

    while length(queue) > 0
        current_node = popfirst!(queue)

        if isa(current_node, ConstantNode)
            continue
        elseif isa(current_node, VariableNode)
            grad[current_node.name] = adjoint[current_node.name]
            continue
        else
            current_adjoint = adjoint[current_node.name]
            current_operator_name = current_node.operator_name

            operator_grad = getfield(Main, Symbol(current_operator_name * "_grad"))
            next_adjoint = operator_grad(current_adjoint, current_node)

            left_adjoint_val = haskey(adjoint, current_node.left_operand.name) ? 
                               :($(adjoint[current_node.left_operand.name]) + $(next_adjoint[1])) :
                               :($(next_adjoint[1]))
            left_adjoint = ConstantNode(nothing, left_adjoint_val, constant_counter)
            adjoint[current_node.left_operand.name] = unbroadcast_adjoint(left_adjoint, current_node.left_operand)

            if current_node.left_operand ∉ queue
                push!(queue, current_node.left_operand)
            end

            if !isnothing(current_node.right_operand)
                right_adjoint_val = haskey(adjoint, current_node.right_operand.name) ? 
                                    :($(adjoint[current_node.right_operand.name]) + $(next_adjoint[2])) :
                                    :($(next_adjoint[2]))
                right_adjoint = ConstantNode(nothing, right_adjoint_val, constant_counter)
                adjoint[current_node.right_operand.name] = unbroadcast_adjoint(right_adjoint, current_node.right_operand)

                if current_node.right_operand ∉ queue
                    push!(queue, current_node.right_operand)
                end
            end
        end
    end
    return grad
end

function check_gradient(func::Function, args::NTuple{N,<:Real}, suspect::Union{Real, AbstractArray{<:Real}}; 
                        abs_tol::Real=0, rel_tol::Real=atol>0 ? 0 : √eps()) where {N}
    h = 1e-8
    shifted_args = args .+ h
    approx_grad = (func(shifted_args...) .- func(args...)) ./ h
    return norm(approx_grad - suspect) <= max(abs_tol, rel_tol * max(norm(approx_grad), norm(suspect)))
end
