module StringWackiness
  refine String do
    def reverse
      "SHENANIGANS"
    end
  end
end

using StringWackiness

puts "alpha beta delta epsilon".reverse
