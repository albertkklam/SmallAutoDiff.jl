Base.:+(left_node::Union{VariableNode, ConstantNode}, 
        right_node::Union{VariableNode, ConstantNode}, 
        name::Union{Nothing,String}=nothing,
        counter::Union{Nothing, Counter}=nothing) = 
        create_opnode(:+, left_node, right_node, name, counter)

Base.:-(left_node::Union{VariableNode, ConstantNode}, 
        right_node::Union{VariableNode, ConstantNode}, 
        name::Union{Nothing,String}=nothing,
        counter::Union{Nothing, Counter}=nothing) = 
        create_opnode(:-, left_node, right_node, name, counter)