module Mist::GitModel::ClassMethods
  def timestamps
    attribute :created_at, :default => proc { Time.now }
    attribute :updated_at, :default => proc { Time.now }
    before_save { |record| record.updated_at = Time.now }
  end
  
  def attribute(name, options = {})
    name = name.to_sym
    default_attributes[name] = options[:default]
    define_attribute_methods [name.to_s]
    add_attribute_default(name, options)
    add_attribute_getter(name)
    add_attribute_setter(name)
  end
  
  def default_attributes
    @default_attributes ||= {}.with_indifferent_access
  end
  
  def add_attribute_getter(name)
    define_method(name) do                                # def id
      attributes[name]                                    #   attributes[:id]
    end                                                   # end
  end
  
  def add_attribute_setter(name)
    define_method(:"#{name}=") do |value|                 # def id=(value)
      unless value == attributes[name]                    #   unless value == attributes[:id]
        attributes[name] = value                          #     attributes[:id] = value
      end                                                 # end
    end
  end
  
  def add_attribute_default(name, options)
    define_method(:"default_#{name}") do                  # def default_id
      if options[:default].kind_of?(Proc)                 #   if options[:default].kind_of?(Proc)
        options[:default].call                            #     options[:default].call
      else                                                #   else
        options[:default]                                 #     options[:default]
      end                                                 #   end
    end                                                   # end
  end
  
  def table_name
    name.underscore.pluralize
  end
  
  def all
    Dir[Mist.repository_location.join(table_name, '*')].collect do |dir|
      load dir
    end
  end
  
  def load(path)
    new(YAML.load(File.read(path))).tap do |instance|
      instance.changed_attributes.clear
    end
  end
  
  def record_path(id)
    Mist.repository_location.join(table_name, id)
  end
  
  def find(id)
    if File.file?(path = record_path(id))
      load path
    else
      nil
    end
  end
  
  def last
    all.last
  end
  
  def create!(attributes = {})
    new(attributes).tap do |record|
      record.save!
    end
  end
  
  def count
    Dir[Mist.repository_location.join(table_name, '*')].length
  end
end

