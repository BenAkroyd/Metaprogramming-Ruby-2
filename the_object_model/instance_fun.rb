class MyClass
  def my_method
    @v = 1
  end
end

obj = MyClass.new
puts obj.class
puts
puts obj.instance_variables
obj.my_method
puts
puts obj.instance_variables
puts
puts obj.methods
