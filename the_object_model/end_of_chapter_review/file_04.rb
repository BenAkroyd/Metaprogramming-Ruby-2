module Angel
  def smite
    "You have been smighted by the Archangel"
  end

  def mercy
    @forgiven = true
  end

end

class Seraphim
  prepend Angel
end
