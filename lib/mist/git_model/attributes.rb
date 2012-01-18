class Mist::GitModel::Attributes < HashWithIndifferentAccess
  def initialize(model)
    @model = model
    super()
  end
  
  def []=(key, value)
    @model.send(:"#{key}_will_change!") unless !@model || value == self[key]
    super
  end
  
  # Yamlers using Psych will call this method, we just delegate it into
  # `HashWithIndifferentAccess`. If we don't, the yaml tag will be
  # "!ruby/object:Mist::GitModel::Attributes" so that when the record
  # is deserialized, this class will be instantiated, resulting in an
  # error. (This class should only be instantiated directly by
  # `Mist::GitModel`.)
  def to_yaml(*args)
    HashWithIndifferentAccess.new(self).to_yaml(*args)
  end
end
