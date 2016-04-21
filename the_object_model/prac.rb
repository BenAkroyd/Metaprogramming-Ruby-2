class MyClass
  def my_method
    "OG method"
  end

  def another_method
    my_method
  end
end

class MyClass
  def my_method
    "monkeypatched method"
  end
end

puts MyClass.new.another_method
