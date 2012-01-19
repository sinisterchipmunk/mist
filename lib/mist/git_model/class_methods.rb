module Mist::GitModel::ClassMethods
  def self.extended(base) #:nodoc:
    base.class_attribute :default_attributes
    base.default_attributes ||= HashWithIndifferentAccess.new
  end
  
  # this is necessary because without it default_attributes will be
  # inherited and shared across all subclasses of base, which we
  # don't exactly want.
  def inherited(subclass) #:nodoc:
    if subclass.default_attributes
      subclass.default_attributes = subclass.default_attributes.dup
    else
      subclass.default_attributes = HashWithIndifferentAccess.new
    end
  end
  
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
    if name =~ /GitModel/
      raise
    end
    name.underscore.pluralize
  end
  
  # Returns meta data for this model.
  def [](type)
    @meta ||= {}
    @meta[type] ||= if File.file?(meta_file_path(type))
      YAML.load(File.read(meta_file_path(type))) || {}
    else
      {}
    end.with_indifferent_access
  end
  
  # Assigns, saves and commits meta data for this model.
  def save_meta_data(type)
    FileUtils.mkdir_p File.dirname(meta_file_path(type))
    File.open(meta_file_path(type), 'w') { |f| f.print self[type].to_yaml }
    if Mist.commit_meta_data
      Mist.repository.add meta_file_path(type)
      Mist.repository.commit '%s meta changes to %s' % [type, table_name]
    end

    # we must force meta to be reloaded because otherwise it could get out of sync with filesystem
    @meta = nil
  end
  
  def meta_file_path(type)
    Mist.repository_location.join('.meta', table_name, type.to_s)
  end
  
  def all
    # it's dangerous to rely on Dir[] because we have no guarantee of the
    # returned order. Git will be more reliable.
    files = Mist::GitFileSystemHistory.new(Mist.repository).find(nil, /^#{Regexp::escape table_name}\/?/)
    files.collect! { |path| load Mist.repository_location.join(path) }
  end
  
  def load(path, attributes = {})
    # id is always the filename, ensure id isn't changed by yaml
    attributes = attributes.with_indifferent_access.reverse_merge(YAML.load(File.read(path)))
    attributes['id'] = File.basename(path)
    new(attributes).tap do |instance|
      instance.changed_attributes.clear
    end
  end
  
  def record_path(id)
    Mist.repository_location.join(table_name, id.to_s)
  end
  
  def find(id, new_attributes = {})
    if path = exist?(id)
      load path, new_attributes
    else
      nil
    end
  end
  
  # If the id exists, its file path is returned. Otherwise, nil.
  def exist?(id)
    path = record_path(id)
    File.exist?(path) ? path : nil
  end
  
  def last(count = nil)
    files = Mist::GitFileSystemHistory.new(Mist.repository).find(count || 1, /^#{Regexp::escape table_name}\/?/)
    files.collect! { |path| load Mist.repository_location.join(path) }
    count.nil? ? files.first : files
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

