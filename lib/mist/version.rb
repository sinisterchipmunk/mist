module Mist
  module Version
    MAJOR, MINOR, PATCH = 0, 6, 3
    STRING = [MAJOR, MINOR, PATCH].join('.')
  end
  
  VERSION = Version::STRING
end
