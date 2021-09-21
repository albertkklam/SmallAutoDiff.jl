function derivative(fx::Function, wrt_var_idx::Int, args::Union{<:Real, Array{<:Real}})
    @assert length(args) >= wrt_var_idx
    dual_args = [idx == wrt_var_idx ? DualNumber(arg, 1) : DualNumber(arg, 0) for (idx, arg) in enumerate(args)]
    return fx(dual_args...).dual
end

function derivative(fx::Function, args::Union{<:Real, Array{<:Real}})
    derivatives = [derivative(fx, idx, args) for idx in 1:length(args)]
    return derivatives
end

differentiate(fx::Function, wrt_var_idx::Int) = ((args::Union{<:Real, Array{<:Real}}) -> derivative(fx, wrt_var_idx, args))

function check_derivative(fx::Function, wrt_var_idx::Int, args::Union{<:Real, Array{<:Real}}, suspect::Real; 
                          h::Real=1e-7, rel_err::Real=1e-5, abs_err::Real=1e-8)
    shifted_args = isa(args, Real) ? copy(convert(Float64, args)) : copy(convert(Array{Float64},args))
    if isa(shifted_args, Array{Float64})
        shifted_args[wrt_var_idx] += h
    else
        @assert wrt_var_idx == 1
        shifted_args += h
    end
    numerical_derivative = (fx(shifted_args...) - fx(args...)) / h
    err_threshold = abs_err + (abs(numerical_derivative) * rel_err)
    return abs(suspect - numerical_derivative) <= err_threshold
end
