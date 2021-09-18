x = VariableNode("x", 0.5)
y = VariableNode("y", 4)
z = VariableNode("z", -2.3)

c_1 = ConstantNode("c_1", 3)
c_2 = ConstantNode("c_2", 2)
c_3 = ConstantNode("c_3", 3)

f = sin(x ^ (y + z)) - c_1 * log((x ^ c_2) * (y ^ c_3))

println("This should print ≈-8.0148166: ", eval(f.val))
