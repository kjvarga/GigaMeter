#
#  Controller.rb
#  unwired
#
#  Created by Karl Varga on 29/03/09.
#  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'

class Controller
  attr_writer :loginInput
  attr_writer :passwordInput
  attr_writer :updateEvery
  attr_writer :window
  attr_writer :menuBarCheckbox
  
  attr_accessor :user
  
  @@appName = "GigaMeter"
  @@appDataFile = nil
  @@usage = ""
  @@updateEveryOptions = [
    ['30 minutes', 30],
    ['hour', 60], 
    ['2 hours', 2*60],
    ['6 hours', 6*60],
    ['12 hours', 12*60],
    ['day', 24*60],
    ['2 days', 2*24*60],
    ['week', 7*24*60]
  ]
  
  def awakeFromNib
    print "Application name: #{@@appName}\n"
    print "Application data file: #{pathForDataFile}\n"
    loadDataFromDisk

    # Load the bridgesupport file for keychain access
    #print "Bundle path: #{NSBundle.mainBundle.bundlePath}\n"
    #print "Path for bridgesupport file: #{NSBundle.mainBundle.pathForResource_ofType('Security', 'bridgesupport')}\n"
    #load_bridge_support_file(NSBundle.mainBundle.pathForResource_ofType("Security", "bridgesupport"))
    #load_bridge_support_file(NSBundle.mainBundle.pathForResource("Security", ofType:"bridgesupport"))
    #load_bridge_support_file("/Users/karl/projects/gigameter/GigaMeter Configuration/English.lproj/Security.bridgesupport")
    #load_bridge_support_file "Security.bridgesupport"
    #[[EMKeychainProxy sharedProxy] addGenericKeychainItemForService:@"GigaMeter" withUsername:@"Joe" password:@"SuperSecure!"]
    #proxy = EMKeychainProxy.new
    #print proxy
    #exit
    
    # Get the password from the keychain
    #password	= GMKeyChain.alloc.init.get_password('johnnn')
    #print "Got #{@password} for 'johnnn'\n"
    #password = getPasswordFromKeychain('GigaMeter', 'johnnn')
    #exit
    #password = self.user.loginInput.empty? ? '' : getPasswordFromKeychain(@@appName, self.user.loginInput)[0]
    
    # Initialize UI elements
    @loginInput.stringValue = self.user.loginInput || ""
    @passwordInput.stringValue = self.user.passwordInput || ""
    @menuBarCheckbox.state = self.user.menuBarCheckbox ? NSOnState : NSOffState
    
    # Initialize the 'Update every' options
    @updateEvery.removeAllItems
    @updateEvery.addItemsWithTitles(@@updateEveryOptions.collect { |i| i[0] })
    selectedIndex = Controller.getOptionIndex(self.user.updateEvery, by_value=true)
    selectedIndex = Controller.getOptionIndex("hour") if selectedIndex.nil?
    @updateEvery.selectItemAtIndex(selectedIndex)
  end
  
  # Prepare application for termination.  Save user data.
  def applicationWillTerminate(notification)
    print "Application terminating...\n"

    username = @loginInput.stringValue    
    password = @passwordInput.stringValue

    savePasswordInKeychain(@@appName, username, password)
    saveDataToDisk
  end
  
  def savePasswordInKeychain(service, username, password)
    error = SecKeychainAddGenericPassword(
        nil, service.length, service, username.length, username,
        password.length, password, nil)
    print "Saved password '#{password}' to keychain.  Result was: #{error}\n"
    
    # Error if entry already exists, so update the current entry
    if error == ErrSecDuplicateItem
      
      # Get a reference to it so that we can update it
      (password, item) = getPasswordFromKeychain(service, username)
      
      updatePasswordInKeychain(password, item)
    end
  end
  
  def updatePasswordInKeychain(password, item)
    print "Updated password in keychain '#{password}'.\n"
    SecKeychainItemModifyContent(item, nil, password.length, password)
  end
  
  # @return a tuple containing the password and a reference to
  #       the item in the keychain
  def getPasswordFromKeychain(service, username)
    #pl, pd, i = '', '', Pointer.new_with_type('@')
    #pl = Pointer.new_with_type('@')
    #pd = Pointer.new_with_type('@')
    pl, pd = nil, nil
    i = Pointer.new_with_type('@')
    #print i, i.class
    print "Retrieving password from keychain for username '#{username}'...\n"
    
    print SecKeychainFindGenericPassword(
        nil, service.length, service, username.length, username, nil, nil, nil)
    #status, *data = SecKeychainFindGenericPassword(
    #    nil, service.length, service, username.length, username)
    #print i[0]
    print "Got status #{status} and data #{data} ", pl, pd, i, "\n"
    if status == ErrSecItemNotFound or data.empty?
      print "Password not found!\n"
      return [nil, nil]
    end

    # Extract the data (password length, password data, item reference)
    password_length = data.shift 
    password_data = data.shift
    item = data.shift #SecKeychainItemRef
    
    password = password_data.bytestr(password_length)
    print "Got password '#{password}'.\n"
    return [password, item]
  end
  
  # Cache and return the application name
  #def appName
  #   @@appName ||= NSBundle.mainBundle.localizedInfoDictionary.objectForKey("CFBundleDisplayName") \
  #     || NSBundle.mainBundle.localizedInfoDictionary.objectForKey("CFBundleName") \
  #     || NSProcessInfo.processInfo.processName
  #end
    
  # This doesn't appear to be called.
  def applicationDidFinishLaunching
    #@window.makeKeyAndOrderFront(self)
    #@window.makeKeyWindow()
    #menu = NSMenu.new
    #item = NSMenuItem.new
    #item.title = "Hello World!"
    #menu.title = "Karl's Menu"
    #menu.display
    #print "Added menu with item"
  end
  
  # Attempt to login to the ISP.
  def doLogin(sender)
  
    # Save the password
    username = @loginInput.stringValue    
    password = @passwordInput.stringValue
    savePasswordInKeychain(@@appName, username, password)
    saveDataToDisk
    return 
    
    print "Login ", @loginInput.stringValue, " password ", @passwordInput.stringValue, "\n"
    print "Update every ", @updateEvery.titleOfSelectedItem, " = ", Controller.getOptionValue(@updateEvery.titleOfSelectedItem), "\n"
    puts "Attempting login..."
    proc = NSTask.new
    #proc.setArguments([@loginInput.stringValue, @passwordInput.stringValue])
    proc.setCurrentDirectoryPath('/Users/karl/projects/unwired')
    print "Directory path: ", proc.currentDirectoryPath, "\n"
    reader = NSPipe.new
    proc.standardOutput = reader
    proc.setLaunchPath('/Users/karl/projects/gigameter/usage.rb')
    print "Launch path: ", proc.launchPath, "\n"
    proc.launch
    proc.waitUntilExit
    status = proc.terminationStatus
    @@usage = readPipeToString(reader)
    print "Returned ", @@usage, " (with status ", status, ")\n"
  end
  
  def showInMenuCheckboxClicked(sender)
    print @menuBarCheckbox.state == NSOffState
    if @@menuBarCheckbox.state == NSOffState
      # Stop the application
      #NSWorkspace.sharedWorkspace.launchApplication "GigaMeter"
    else
      # Start it
      #NSWorkspace.sharedWorkspace.launchApplication_showIcon_autolaunch_("GigaMeter", false, true) 
    end
  end
  
  # Return the value of the item with the given title in the "update
  # every" options list.
  def self.getOptionValue(title)
    mins = @@updateEveryOptions.find { |i| i[0] == title }
    mins[1]
  end
  
  # Return the index of the item with the given title in the "update
  # every" options list.
  def self.getOptionIndex(title, by_value=false)
    index = by_value ? 1 : 0
    item = @@updateEveryOptions.find { |i| i[index] == title }
    @@updateEveryOptions.index(item)
  end

  # The result of reading from the pipe is a set of hex fragments
  # separated by spaces.  Each fragment represents 4 ASCII characters
  # encoded in hex tuples.
  def readPipeToString(pipe)
    resultstr = ""
    hexstring = pipe.fileHandleForReading.readDataToEndOfFile.description
    print 'result:\''+hexstring.to_s+'\'\n'
    hexstring.split.each do |fragment|
      resultstr.concat(hex2string(fragment))
    end
    resultstr
  end
  
  # Treat each character tuple in *str* as a hexadecimal value,
  # then convert to ASCII
  def hex2string(str)
    i = 0; res = ""
    while i < str.length do
      res.concat(str.slice(i,2).hex.chr)
      i+=2
    end
    res
  end
  
  # Return the path to the file used to store application data.
  # Creates the application folder if it does not exist.
  def pathForDataFile
    return @@appDataFile if @@appDataFile
    fileManager = NSFileManager.defaultManager
    folder = "~/Library/Application Support/#{@@appName}/"
    folder = folder.stringByExpandingTildeInPath()
    if !fileManager.fileExistsAtPath(folder)
      print "(Init) Creating directory #{folder}\n"
      fileManager.createDirectoryAtPath_attributes_(folder, nil)
    end
    fileName = "#{@@appName}.appdata"
    @@appDataFile = folder.stringByAppendingPathComponent(fileName)
  end
  
  # Load application data from disk
  def loadDataFromDisk
    begin
      data = NSKeyedUnarchiver.unarchiveObjectWithFile(pathForDataFile)
      print "(Init) Loaded user data from disk: #{data.inspect}\n"
    rescue
      print "(Init) Corrupt data store!  Unarchiving failed! #{$!}\n"
    end
    self.user = ApplicationData.new(data)
  end
  
  # Save application data to disk
  def saveDataToDisk
    # Save the values of each input
    [:loginInput, :passwordInput].each do |attr|
      self.user.send(attr, self.instance_variable_get("@"+attr.to_s).stringValue)
    end
    self.user.updateEvery = Controller.getOptionValue(@updateEvery.titleOfSelectedItem)
    self.user.menuBarCheckbox = @menuBarCheckbox.state == NSOnState
    
    print "Saving user data to disk: #{self.user.getData.inspect}\n"
    NSKeyedArchiver.archiveRootObject_toFile_(self.user.getData, pathForDataFile)
  end
end
