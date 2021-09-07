using LinearAlgebra

for op = (:+, :-, :*, :/, :maximum)
        if op == (:maximum)
                eval(quote
                Base.$op(left_node::Union{VariableNode, ConstantNode}, 
                        name::Union{Nothing,String}=nothing,
                        counter::Union{Nothing, Counter}=nothing) = 
                        create_opnode(Symbol($op), left_node, name, counter)
                end)
        else
                eval(quote
                Base.$op(left_node::Union{VariableNode, ConstantNode}, 
                        right_node::Union{VariableNode, ConstantNode}, 
                        name::Union{Nothing,String}=nothing,
                        counter::Union{Nothing, Counter}=nothing) = 
                        create_opnode(Symbol($op), left_node, right_node, name, counter)
                end)
        end
end

LinearAlgebra.:⋅(left_node::Union{VariableNode, ConstantNode}, 
                  right_node::Union{VariableNode, ConstantNode}, 
                  name::Union{Nothing,String}=nothing,
                  counter::Union{Nothing, Counter}=nothing) = 
                  create_opnode(:⋅, left_node, right_node, name, counter)

for op = (:+, :-, :*, :/, :÷, :^)
        eval(quote
        Broadcast.broadcasted(::typeof($op), left_node::Union{VariableNode, ConstantNode}, 
                                right_node::Union{VariableNode, ConstantNode}, 
                                name::Union{Nothing,String}=nothing,
                                counter::Union{Nothing, Counter}=nothing) = 
                                create_opnode(Symbol("." * string($op)), left_node, right_node, name, counter)
        end)
end
