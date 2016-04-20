load 'https://github.com/matthewrudy/memoist.git'
class Universe
  extend Memoize

  def meaning_of_life
    sleep 1
    42
  end

  memoize :meaning_of_life

end
