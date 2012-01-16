class Mist::CodeExampleParser
  attr_reader :examples, :content
  
  class Example < String
    attr_accessor :start_offset
    attr_accessor :whitespace_skipped
    attr_writer :filename
    FILENAME_REGEXP = /\A[\s\t\n]*file: (.*?)[\n\r]+/
    
    def initialize(start_offset)
      @whitespace_skipped = 0
      @start_offset = start_offset
      super()
    end
    
    def explicit_filename
      @explicit_filename ||= if self =~ FILENAME_REGEXP
        # omit filename from self
        match = $~
        @whitespace_skipped += match.offset(0)[1] - match.offset(0)[0]
        sub! match[0], ''
        match[1]
      else
        nil
      end
    end
    
    def filename
      @filename || explicit_filename
    end
    
    def offset
      start_offset...(start_offset+length+whitespace_skipped)
    end
  end
  
  def initialize(content)
    @content = content.to_s.dup
    @examples = parse
  end
  
  def parse
    in_example = false
    offset = 0
    
    [].tap do |examples|
      while match = /^    ([^\n]+(\n|\z))/m.match(content, offset)
        in_example = examples.last && match.offset(0)[0] == offset && offset > 0
        offset = match.offset(0)[1]

        examples << Example.new(match.offset(0)[0]) unless in_example
        line = match[1]
        examples.last.whitespace_skipped += 4
        examples.last.concat match[1]
      end
      
      # detect multiple examples separated only by white space
      # -- they are part of the same example
      pass = proc do
        call_again = false
        examples.length.times do |index|
          current = examples[index]
          next if index == 0 or current.explicit_filename
          
          previous = examples[index-1]
          min = previous.offset.max
          max = current.offset.min
          
          if content[(min+1)...max] =~ /\A[\s\t\n]*\z/
            previous.whitespace_skipped += current.whitespace_skipped
            previous.concat $~[0] + current
            examples.delete current
            call_again = true
            break
          end
        end

        pass.call if call_again
      end
      pass.call
      
      # Last pass: assign default filenames as needed
      examples.each_with_index { |example, index| example.filename ||= "Example #{index+1}" }
    end
  end
end
