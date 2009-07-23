#
#  ApplicationController.rb
#  GigaMeter Configuration
#
#  Created by Karl Varga on 18/04/09.
#  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'
#require 'yaml'
 
#include OSX
#OSX.require_framework 'Security'



class ApplicationController < OSX::NSObject

  #def awakeFromNib
  #OSX.load_bridge_support_file(NSBundle.mainBundle.pathForResource_ofType("Security", "bridgesupport"))
#OSX.ruby_thread_switcher_stop
    #@password	= GNKeychain.alloc.init.get_password('johnnn')
    #print "Got #{@password} for 'johnnn'\n"
  #end
end
