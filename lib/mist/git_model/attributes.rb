class Mist::GitModel::Attributes < HashWithIndifferentAccess
  def initialize(model)
    @model = model
    super()
  end
  
  def []=(key, value)
    @model.send(:"#{key}_will_change!") unless value == self[key]
    super
  end
end
