class Mist::Configuration::Author
  attr_accessor :name, :email
  
  def initialize
    @name = "John Doe"
    @email = "john@example.com"
  end
end
