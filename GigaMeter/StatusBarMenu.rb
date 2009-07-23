#
#  StatusBarMenu.rb
#  GigaMeter
#
#  Created by Karl Varga on 16/05/09.
#  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
#

class StatusBarMenu < NSObject
  attr_accessor :summary, :lastUpdate, :statusBar, :menu
  attr_accessor :configure, :quit, :updateNow
  
  @@TITLE = 'GM'
  @@LOADING = 'Loading...'
  @@TOOLTIP = 'GigaMeter Usage Monitor'
  @@IMAGE = "flowerSmall.gif"

  def loginAndWaitThread
    print "in login and wait thread\n"
    print "sleeping for 5 seconds...\n"
    Kernel::sleep(10)
    print "done sleeping...\n"
  end
  
  def initialize(target)
    print "Initializing status bar...\n"
    menuZone = NSMenu.menuZone
    self.menu = NSMenu.allocWithZone(menuZone).init
    #self.menu.autoenablesItems = true
    
    self.summary = self.menu.addItemWithTitle_action_keyEquivalent_(@@LOADING, nil, '') 
    self.summary.enabled = false    
    self.menu.addItem NSMenuItem.separatorItem
    self.updateNow = self.menu.addItemWithTitle_action_keyEquivalent_('Update Now', 'actionUpdateNow', 'u')
    self.updateNow.enabled = true
    self.updateNow.target = target
    self.updateNow.toolTip = 'Update your Usage Data'
    self.menu.addItem NSMenuItem.separatorItem
    self.configure = self.menu.addItemWithTitle_action_keyEquivalent_('Configure', 'actionConfigure', ',')
    self.configure.enabled = true
    self.configure.target = target
    self.configure.toolTip = 'Configure GigaMeter'
    self.quit = self.menu.addItemWithTitle_action_keyEquivalent_('Quit', 'actionQuit', 'q')
    self.quit.enabled = true
    self.quit.target = target
    self.quit.toolTip = 'Quit GigaMeter'

    
    #self.summary = self.menu.addItemWithTitle_action_keyEquivalent_(@@LOADING, 'actionQuit', 'q')
    #self.summary.enabled = true
    #self.summary.target = target
    

    self.statusBar = NSStatusBar.systemStatusBar.statusItemWithLength(NSVariableStatusItemLength)    
    self.statusBar.menu = self.menu
    self.statusBar.highlightMode = true
    #self.statusBar.title = @@TITLE
    self.statusBar.toolTip = @@TOOLTIP
    self.statusBar.image = NSImage.imageNamed(@@IMAGE)
  end
    
  def update(data)
    return if !data.usageSummary || !data.lastUpdate
    if self.summary.title = @@LOADING
      self.summary.title = data.usageSummary
    end
    if !self.lastUpdate
      self.lastUpdate = self.menu.insertItemWithTitle_action_keyEquivalent_atIndex(data.lastUpdate, nil, '', 1) 
      self.lastUpdate.enabled = false
    else
      self.lastUpdate.title = data.lastUpdate
    end
      #self.statusBar
          #statusItem = NSStatusBar.systemStatusBar.statusItemWithLength(NSVariableStatusItemLength).retain
    #statusItem.menu = menu
    #statusItem.highLIghtmode = YES
    #statusItem.title = 'GM'
    #menu.release
    #menuItem = [menu addItemWithTitle:@"In 5.35 GB, Off 4.34 GB, 4 days left"
	#						   action:NULL
	#					keyEquivalent:@""];
	#[menuItem setEnabled:(BOOL)FALSE];

	#_statusItem = [[[NSStatusBar systemStatusBar]
	#				statusItemWithLength:NSVariableStatusItemLength] retain];
	#[_statusItem setMenu:menu];
	#[_statusItem setHighlightMode:YES];
	#[_statusItem setToolTip:@"GigaMeter Monitor"];
	#//[_statusItem setImage:[NSImage imageNamed:@"flowerSmall.gif"]];
	#[_statusItem setTitle:@"5.36 GB / 4.45 GB / 4 days"];
  end
end
