x_val = 0.5
y_val = 4
z_val = -2.3

constant_1 = 3
constant_2 = 2
constant_3 = 3

variable_counter = Counter(VariableNode)
constant_counter = Counter(ConstantNode)

x = VariableNode("x", :x_val, variable_counter)
y = VariableNode("y", :y_val, variable_counter)
z = VariableNode("z", :z_val, variable_counter)

c_1 = ConstantNode("c_1", :constant_1, constant_counter)
c_2 = ConstantNode("c_2", :constant_2, constant_counter)
c_3 = ConstantNode("c_3", :constant_3, constant_counter)

f = sin(x ^ (y + z)) - c_1 * log((x ^ c_2) * (y ^ c_3))

println(eval(f.val))
