function derivative(fx::Function, wrt_var_idx::Int, args::Union{<:Real, Array{<:Real}})
    @assert length(args) >= wrt_var_idx
    dual_args = []
    for (idx, arg) in enumerate(args)
        if idx == wrt_var_idx
            push!(dual_args, DualNumber(arg, 1))
        else
            push!(dual_args, DualNumber(arg, 0))
        end
    end
    return fx(dual_args...).dual
end

function derivative(fx::Function, args::Union{<:Real, Array{<:Real}})
    derivatives = []
    for (idx, _) in enumerate(args)
        push!(derivatives, derivative(fx, idx, args))
    end
    return derivatives
end

differentiate(fx::Function, wrt_var_idx::Int) = ((args::Union{<:Real, Array{<:Real}}) -> derivative(fx::Function, wrt_var_idx::Int, args::Union{<:Real, Array{<:Real}}))

function check_derivative(fx::Function, wrt_var_idx::Int, args::Union{<:Real, Array{<:Real}}, suspect::Real; 
                          h::Real=1e-7, rel_err::Real=1e-5, abs_err::Real=1e-8)
    shifted_args = args .+ h
    numerical_derivative = (fx(shifted_args...) - fx(args...)) / h
    err_threshold = abs_err + abs(numerical_derivative) * rel_err
    return abs(suspect - numerical_derivative) <= err_threshold
end