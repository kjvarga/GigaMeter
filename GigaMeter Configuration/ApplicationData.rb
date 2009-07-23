#
#  ApplicationData.rb
#  GigaMeter Configuration
#
#  Created by Karl Varga on 13/04/09.
#  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
#

class ApplicationData
  attr_accessor :data
  
  # Access the data store dictionary directly
  def getData
    return self.data
  end
  
  # Initialize with an optional data dictionary.  Useful when data
  # has been loaded from disk.
  def initialize(data={})
    self.data = data || {}
  end
  
  def method_missing(sym, *args, &block)
      print "Called method missing #{sym.to_s} #{args}\n"
      # Strip the trailing = (and other non-word characters) from the
      # symbol so that assignments and attribute accesses yeild the same
      # lookup key
      key = sym.to_s.gsub(/[^\w]/, '')
      return self.data[key] if args.empty?
      self.data[key] = args[0] # Only accept simple assignments
  end
  
  def to_s
    self.data.inspect
  end
end
