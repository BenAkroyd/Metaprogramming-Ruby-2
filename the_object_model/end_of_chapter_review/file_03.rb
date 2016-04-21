module StringWackiness
  refine String do
    def reverse
      "SHENANIGANS"
    end
  end
end

class Weird
  using StringWackiness

  def initialize
    @string = "a simple string"
  end

  def string
    @string.reverse
  end

end
