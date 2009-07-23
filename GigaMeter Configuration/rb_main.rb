#
# rb_main.rb
# unwired
#
# Created by Karl Varga on 28/03/09.
# Copyright __MyCompanyName__ 2009. All rights reserved.
#

# Loading the Cocoa framework. If you need to load more frameworks, you can
# do that here too.
framework 'Cocoa'
#framework 'Security'

#require 'osx/cocoa'
#OSX.require_framework 'Security'
#OSX.load_bridge_support_file(NSBundle.mainBundle.pathForResource_ofType("Security", "bridgesupport"))

# Load the bridge support file for keychain password encoding
#print NSBundle.mainBundle.bundlePath
#load_bridge_support_file(NSBundle.mainBundle.pathForResource_ofType("Security", "bridgesupport"))
#NSBundle.mainBundle.pathForResource_ofType()
# Loading all the Ruby project files.
dir_path = NSBundle.mainBundle.resourcePath.fileSystemRepresentation
Dir.entries(dir_path).each do |path|
  if path != File.basename(__FILE__) and path[-3..-1] == '.rb'
    require(path)
  end
end

# Starting the Cocoa main loop.
NSApplicationMain(0, nil)
