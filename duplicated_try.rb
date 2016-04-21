#---
# Excerpted from "Metaprogramming Ruby 2",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/ppmetr2 for more book information.
#---
# The boring, duplication-ridden version of Computer

class Computer

  def initialize(computer_id, data_source)
    @id = computer_id
    @data_source = data_source
    self.methods.each do |method|
      if @data_source.respond_to?("get_#{method}_info")
        self.send( "undef_method", method )
      end
    end
  end

  def method_missing(meth_name, *params, &block)
    super if !@data_source.respond_to?("get_#{meth_name}_info")
    info = @data_source.send("get_#{meth_name}_info", @id)
    price = @data_source.send("get_#{meth_name}_price", @id)
    result = "#{meth_name}: #{info} ($#{price})"
    return "* #{result}" if price >= 100
    result
  end

  def respond_to_missing?( method, include_private = false )
    @data_source.respond_to?("get_#{method}_info") || super
  end

  # ...
end

require_relative 'unit_test'
