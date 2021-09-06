for op = (:+, :-, :*, :/)
        eval(quote
                Base.$op(left_node::Union{VariableNode, ConstantNode}, 
                         right_node::Union{VariableNode, ConstantNode}, 
                         name::Union{Nothing,String}=nothing,
                         counter::Union{Nothing, Counter}=nothing) = 
                         create_opnode(Symbol($op), left_node, right_node, name, counter)
        end)
end

for op = (:+, :-, :*, :/, :÷, :^)
        eval(quote
                Base.broadcast(::typeof($op), left_node::Union{VariableNode, ConstantNode}, 
                         right_node::Union{VariableNode, ConstantNode}, 
                         name::Union{Nothing,String}=nothing,
                         counter::Union{Nothing, Counter}=nothing) = 
                         create_opnode(Symbol("." * string($op)), left_node, right_node, name, counter)
        end)
end
