#
#  Controller.rb
#  unwired
#
#  Created by Karl Varga on 29/03/09.
#  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
#

require 'osx/cocoa'

class Controller
  attr_accessor :login, :password, :updateEvery
  attr_accessor :user, :menu
  attr_accessor :actionQuit, :actionConfigure, :actionUpdateNow
  
  @@dateFormat = "%a, %b %1d, %1I.%M %p"
  @@appName = "GigaMeter"
  @@appDataFile = nil
  @@usage = ""

  def actionQuit(sender)
    puts "action quit called\n"
    NSApp.terminate(sender)
  end

  def actionConfigure(sender)
    puts "action configure called\n"
    #NSWorkspace.sharedWorkspace.launchApplication "GigaMeter Configuration"
  end

  def actionUpdateNow(sender)
    puts "action update called\n"
    doLogin
    saveDataToDisk
    self.menu.update(self.user)
  end
    
  def awakeFromNib
    print "Application name: #{@@appName}\n"
    print "Application data file: #{pathForDataFile}\n"
    loadDataFromDisk

    # Initialize instance variables
    self.login = self.user.loginInput || ""
    self.password =  self.user.passwordInput || ""
    self.updateEvery = self.user.updateEvery
    
    self.menu = StatusBarMenu.new(self)
    #print NSThread.isMultiThreaded()
    #thread = Thread.new(self.menu) { |menu|
    #  menu.loginAndWaitThread
    #}
    #thread.join
    #myThread = NSThread.alloc.initWithTarget_selector_object_(self, :loginAndWaitThread, nil) 
    #myThread.start
          #self.menu.performSelectorInBackground_withObject_(:loginAndWaitThread, nil)
    # Start the login-wait cycle
    #NSThread.detachNewThreadSelector_toTarget_withObject_(:loginAndWaitThread, menu, nil)
    #doLogin
    #saveDataToDisk
    self.menu.update(self.user)
  end
  
  def loginAndWaitThread
    print "in login and wait thread\n"
  end
  
  # Prepare application for termination.  Save user data.
  def applicationWillTerminate(notification)
    print "Application terminating...\n"
    saveDataToDisk
  end
  
  # Attempt to login to the ISP.
  def doLogin
  
    # Save the password
    username = self.login
    password = self.password
    
    print "Login ", self.login, " password ", self.password, "\n"
    print "Update every ", self.updateEvery, "\n"
    puts "Attempting login..."
    #print Usage.getUsageData(login, password, pathForDataFile)
    #return
    
    proc = NSTask.new
    #proc.setArguments([@loginInput.stringValue, @passwordInput.stringValue])
    #proc.setCurrentDirectoryPath("~/Applications/#{@@appName}/")
    #proc.setCurrentDirectoryPath(pathForDataFile)
    print "Directory path: ", proc.currentDirectoryPath, "\n"
    reader = NSPipe.new
    proc.standardOutput = reader
    proc.setLaunchPath("/Applications/#{@@appName}/usage.rb")
    #proc.setLaunchPath('usage.rb')
    print "Launch path: ", proc.launchPath, "\n"
    proc.launch
    proc.waitUntilExit
    status = proc.terminationStatus
    usage = readPipeToString(reader).strip
    print "Returned ", usage, " (with status ", status, ")\n"
    self.user.usageSummary = usage
    
    info = usage.split('|').map { |x| x.strip }
    print info
    self.user.inPeakUsage, self.user.offPeakUsage, self.user.daysLeft = info
    
    # Set the lastUpdate date to now
    date = NSCalendarDate.calendarDate
    date.calendarFormat = @@dateFormat
    self.user.lastUpdate = date.description
  end

  # The result of reading from the pipe is a set of hex fragments
  # separated by spaces.  Each fragment represents 4 ASCII characters
  # encoded in hex tuples.
  def readPipeToString(pipe)
    resultstr = ""
    hexstring = pipe.fileHandleForReading.readDataToEndOfFile.description
    hexstring.gsub! /^<|>$/, ''
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
    #[:inPeakUsage, :offPeakUsage, :inPeakAllowance,
    #   :offPeakAllowance, :daysLeft, :lastUpdate].each do |attr|
    # self.user.send(attr, self.instance_variable_get("@"+attr.to_s))
    #end

    print "Saving user data to disk: #{self.user.getData.inspect}\n"
    NSKeyedArchiver.archiveRootObject_toFile_(self.user.getData, pathForDataFile)
  end
end
