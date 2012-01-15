class Mist::GitModel
  autoload :ClassMethods, 'mist/git_model/class_methods'
  
  extend ActiveModel::Naming
  extend ActiveModel::Callbacks
  include ActiveModel::Validations
  include ActiveModel::Dirty
  include ActiveModel::Conversion
  extend Mist::GitModel::ClassMethods
  
  delegate :table_name, :record_path, :default_attributes, :to => 'self.class'
  define_model_callbacks :save, :create, :update
  attribute :id, :default => proc { (count + 1).to_s }
  
  def initialize(attributes = {})
    default_attributes!
    attributes.each do |key, value|
      self.send(:"#{key}=", value)
    end
  end
  
  def ==(other)
    if other.kind_of?(self.class)
      id == other.id && content == other.content && title == other.title
    else
      id == other
    end
  end
  
  def commit_message
    if new_record?
      "Post created"
    else
      "Post updated"
    end
  end
  
  def commit(commit_message = self.commit_message)
    Mist.repository.add path
    Mist.repository.commit commit_message
  end

  def path
    record_path id
  end
  
  def path_was
    record_path id_was
  end
  
  def destroy
    return if new_record?
    Mist.repository.remove path, :recursive => true
    Mist.repository.commit "Destroyed post #{title.inspect}"
    FileUtils.rm_rf path
  end
  
  def update_attributes(attributes)
    attributes.each { |k,v| self.send(:"#{k}=", v) }
    save
  end
  
  def attributes
    @attributes ||= {}.with_indifferent_access.tap { |attrs|
      this = self
      (class << attrs; self; end).class_eval do
        alias_method :__assign, :[]=
        define_method :[]= do |key, value|
          unless @changing
            @changing = true
            begin
              this.send :"#{key}_will_change!" unless value == attrs[key]
            ensure
              @changing = false
            end
          end
          __assign key, value
        end
      end
    }
  end
  
  def default_attributes!
    default_attributes.each do |key, value|
      if value.kind_of?(Proc)
        attributes[key] = value.call
      else
        attributes[key] = value
      end
    end
  end
  
  def persisted?
    !changed? && !new_record?
  end
  
  def new_record?
    id_was.blank? || !File.file?(path_was)
  end
  
  def save
    return false unless valid?
    
    if changed?
      create_or_update_callback = new_record? ? :create : :update
      run_callbacks create_or_update_callback do
        run_callbacks :save do
          FileUtils.mkdir_p File.dirname(path)
          Mist.repository.lib.mv path_was, path if !new_record? && id_changed?
          File.open(path, "w") { |f| f.print attributes.to_yaml }
          commit
        end
      end
      
      @previously_changed = changes
      @changed_attributes.clear
    end
    
    true
  end
  
  def save!
    raise "Record not saved: #{errors.full_messages.join('; ')}" unless save
  end
  
end
