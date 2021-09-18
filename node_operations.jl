using LinearAlgebra

for op = (:+, :-, :*, :/, :÷, :^, :sum, :exp, :log, :sin, :cos, :transpose)
        if op in Set([:sum, :exp, :log, :sin, :cos, :transpose])
                eval(quote
                Base.$op(left_node::Node, 
                         counter::Union{Nothing, AbstractCounter}=nothing,
                         name::Union{Nothing,String}=nothing) = 
                         create_opnode(Symbol($op), left_node, counter, name)
                end)
        else
                eval(quote
                Base.$op(left_node::Node, right_node::Node, 
                         counter::Union{Nothing, AbstractCounter}=nothing,
                         name::Union{Nothing,String}=nothing) = 
                         create_opnode(Symbol($op), left_node, right_node, counter, name)
                end)
        end
end

Base.:maximum(left_node::Node, 
              counter::Union{Nothing, AbstractCounter}=nothing,
              name::Union{Nothing,String}=nothing;
              dims::Union{Nothing, Int}=nothing) = 
              create_opnode(:maximum, left_node, counter, name, dims=dims)

LinearAlgebra.:⋅(left_node::Node, right_node::Node, 
                 counter::Union{Nothing, AbstractCounter}=nothing,
                 name::Union{Nothing,String}=nothing) = 
                 create_opnode(:⋅, left_node, right_node, counter, name)

for op = (:+, :-, :*, :/, :÷, :^, :exp, :log, :sin, :cos)
        if op in Set([:exp, :log, :sin, :cos])
                eval(quote
                Broadcast.broadcasted(::typeof($op), left_node::Node, 
                                      counter::Union{Nothing, AbstractCounter}=nothing,
                                      name::Union{Nothing,String}=nothing) = 
                                      create_opnode(Symbol($op), left_node, counter, name, broadcast_method=true)
                end)
        else
                eval(quote
                Broadcast.broadcasted(::typeof($op), left_node::Node, right_node::Node, 
                                      counter::Union{Nothing, AbstractCounter}=nothing, 
                                      name::Union{Nothing,String}=nothing) = 
                                      create_opnode(Symbol($op), left_node, right_node, counter, name, broadcast_method=true)
                end)
        end
end
