using LinearAlgebra

for op = (:+, :-, :*, :/, :÷, :^, :exp, :log, :sin, :cos)
        if op ∈ Set([:exp, :log, :sin, :cos])
                eval(quote
                Base.$op(left_node::Node, 
                         name::Union{Nothing,String}=nothing,
                         counter::Union{Nothing, Counter}=nothing) = 
                         create_opnode(Symbol($op), left_node, name, counter)
                end)
        else
                eval(quote
                Base.$op(left_node::Node, right_node::Node, 
                         name::Union{Nothing,String}=nothing,
                         counter::Union{Nothing, Counter}=nothing) = 
                         create_opnode(Symbol($op), left_node, right_node, name, counter)
                end)
        end
end

Base.:maximum(left_node::Node, 
              name::Union{Nothing,String}=nothing,
              counter::Union{Nothing, Counter}=nothing;
              dims::Union{Nothing, Int}=nothing) = 
              create_opnode(:maximum, left_node, name, counter, dims=dims)

LinearAlgebra.:⋅(left_node::Node, right_node::Node, 
                 name::Union{Nothing,String}=nothing,
                 counter::Union{Nothing, Counter}=nothing) = 
                 create_opnode(:⋅, left_node, right_node, name, counter)

for op = (:+, :-, :*, :/, :÷, :^, :exp, :log, :sin, :cos)
        if op ∈ Set([:exp, :log, :sin, :cos])
                eval(quote
                Broadcast.broadcasted(::typeof($op), left_node::Node, 
                                      name::Union{Nothing,String}=nothing,
                                      counter::Union{Nothing, Counter}=nothing) = 
                                      create_opnode(Symbol($op), left_node, name, counter, broadcast_method=true)
                end)
        else
                eval(quote
                Broadcast.broadcasted(::typeof($op), left_node::Node, right_node::Node, 
                                      name::Union{Nothing,String}=nothing, 
                                      counter::Union{Nothing, Counter}=nothing) = 
                                      create_opnode(Symbol($op), left_node, right_node, name, counter, broadcast_method=true)
                end)
        end
end
