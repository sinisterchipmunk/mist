class Mist::GitFileSystemHistory
  def initialize(path_or_repo)
    @files = ActiveSupport::OrderedHash.new
    @repo = path_or_repo.kind_of?(Git::Base) ? path_or_repo : Git.open(path_or_repo)
  end
  
  # Returns files in order of discovery. Since they are discovered
  # by traveling up the tree and backward in time, this is the
  # REVERSE of the order of their actual creation.
  def files
    @files.keys.select { |filename| @files[filename] > 0 }
  end
  
  def mark_file(path, mode)
    @files[path] ||= 0
    case mode
      when :created then @files[path] += 1
      when :deleted then @files[path] -= 1
    end
  end
  
  def mark_tree(tree, mode, path = /./)
    tree.full_tree.each do |entry|
      file = entry.split(/\t/)[1]
      next unless file[path]
      mark_file file, mode
    end
  end
  
  # Finds and returns `count` files, in the order of creation,
  # in descending order (most recent files first),
  # after accounting for deletion.
  #
  # If count is nil, all matches will be returned.
  def find(count, path = /./)
    begin
      commit = @repo.log(1).first
    rescue Git::GitExecuteError => err
      # empty repository, no commits = no matches
      return [] if err.message =~ /bad default revision 'HEAD'/
      raise err
    end
    
    while commit.parent
      commit.diff_parent.each do |diff|
        next if diff.type == 'modified' # only care about new or deleted files
        next unless diff.path[path]
        
        case diff.type                               # because parent is B, changes are reversed.
          when 'deleted' then mark_file diff.path, :created # file was created in this commit
          when 'new'     then mark_file diff.path, :deleted # file was deleted in this commit
        end
        
        return files if count and files.length == count
      end
      
      commit = commit.parent
    end
    
    # if we made it this far then commit is the initial commit
    # so at this stage, mark each file in the tree.
    mark_tree commit.gtree, :created, path
    
    count && files.length > count ? files[0...count] : files
  end
end
