class  FiveBestRappersAlive
  attr_writer :one, :two, :three, :four, :five

  def initialize
    @one   = "Dylon"
    @two   = "Dylon"
    @three = "Dylon"
    @four  = "Dylon"
    @five  = "Dylon"
  end

  def wipe
     self.instance_variables.each do |var|
       var = var.to_s.gsub(/@/, "") + "="
       self.send( var, "" )
     end
  end

  def self.create_da_rappers
  end
end
