# Disable 'mutliline' support due to poor pasting performance
# see https://github.com/ruby/irb/issues/43
IRB.conf[:USE_MULTILINE] = false
IRB.conf[:USE_AUTOCOMPLETE] = false


module SourceLocation
  module Inspection
    def pretty_print(printer = nil)
      printer.text join(':')
    end
  end

  def source_location
    super.tap do |orig|
      orig.singleton_class.prepend Inspection
    end
  end
end

UnboundMethod.prepend SourceLocation
Method.prepend SourceLocation
