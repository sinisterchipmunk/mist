class Mist::GitModel
  require_dependency 'mist/git_model/attributes'
  require_dependency 'mist/git_model/class_methods'
  
  extend ActiveModel::Callbacks
  extend ActiveModel::Naming
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  include ActiveModel::Dirty
  include ActiveModel::Conversion
  extend Mist::GitModel::ClassMethods
  
  define_model_callbacks :save, :create, :update, :initialize, :destroy

  delegate :table_name, :record_path, :default_attributes, :to => 'self.class'
  attribute :id, :default => proc { (count + 1).to_s }
  attribute :id_on_record
  
  validate do |record|
    unless record.id.blank?
      if record.id_changed? and self.class.find(record.id)
        record.errors.add :id, "has already been taken"
      end
    end
  end
  
  def initialize(attributes = {})
    run_callbacks :initialize do
      default_attributes!
      attributes.each do |key, value|
        self.send(:"#{key}=", value)
      end
    end
  end
  
  def class_name
    self.class.name
  end
  
  def ==(other)
    if other.kind_of?(self.class)
      attributes == other.attributes
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
    run_callbacks :destroy do
      Mist.repository.remove path, :recursive => true
      Mist.repository.commit "Destroyed #{class_name} #{inspect}"
      FileUtils.rm_rf path
    end
  end
  
  def update_attributes(attributes)
    attributes.each { |k,v| self.send(:"#{k}=", v) }
    save
  end
  
  def attributes
    @attributes ||= Mist::GitModel::Attributes.new(self)
  end
  
  def default_attributes!
    default_attributes.each do |key, value|
      if value.kind_of?(Proc)
        attributes[key] = value.call
      else
        attributes[key] = value
      end
    end
    
    changed_attributes.clear
  end
  
  def persisted?
    !changed? && !new_record?
  end
  
  def new_record?
    id_was.blank? || !File.file?(path_was)
  end
  
  def save
    return false unless valid?
    
    if new_record? || changed?
      create_or_update_callback = new_record? ? :create : :update
      run_callbacks create_or_update_callback do
        run_callbacks :save do
          FileUtils.mkdir_p File.dirname(path)
          Mist.repository.lib.mv path_was, path if !new_record? && id_changed?
          save_record_file
          commit
        end
      end
    end
    
    if !(files = Mist.repository.lib.diff_files).empty?
      # if false, there's nothing we can reliably do to sync up unless we
      # forcefully commit all changes, which the user may not want. However,
      # if true, then this record was probably renamed from id_on_record
      # to id. So, commit the deletion.
      old_path = record_path(id_on_record).to_s.sub(/^#{Regexp::escape Mist.repository_location.to_s}\/?/, '')
      if files.keys.include?(old_path) && files[old_path][:type] == 'D'
        save_record_file
        Mist.repository.lib.remove old_path
        Mist.repository.lib.add path
        Mist.repository.commit "Syncing to external filesystem changes"
      else
        Rails.logger.warn "Found uncommitted changes in git repo but didn't recognize them, so didn't commit them"
        # no need to show the diff in the log, as the Git library has done that for us
      end
    end
    
    @previously_changed = changes
    changed_attributes.clear
    true
  end
  
  def save_record_file
    self.id_on_record = id
    File.open(path, "w") { |f| f.print attributes.to_yaml }
  end
  
  def save!
    raise "Record not saved: #{errors.full_messages.join('; ')}" unless save
  end
  
  def inspect
    "#<#{self.class.name} #{attributes.collect { |a| a.join('=') }.join(' ')}>"
  end
end
