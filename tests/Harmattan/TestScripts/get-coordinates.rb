#!/usr/bin/ruby
# Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
# All rights reserved.
# Contact: Nokia Corporation (directui@nokia.com)
#
# This file is part of applauncherd.
#
# If you have questions regarding the use of this file, please contact
# Nokia at directui@nokia.com.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License version 2.1 as published by the Free Software Foundation
# and appearing in the file LICENSE.LGPL included in the packaging
# of this file.
#
#  * Description: Performance Test for applauncherd 
#   
#  * Objectives: test the startup time for applications
#    

require 'tdriver'
require 'date'
require 'optparse'

include TDriverVerify

options = {}
 
optparse = OptionParser.new do|opts|
   # Set a banner, displayed at the top
   # of the help screen.
   opts.banner = "Usage: get-coordinates.rb [options] "
 
   options[:application] = nil
   opts.on( '-a', '--application APP', 'Application name in application grid' ) do|app|
     options[:application] = app
   end

   options[:grid] = false
   opts.on( '-g', '--grid_only', 'Only make application grid visible, not find any coordinates ' ) do
     options[:grid] = true
   end

   # This displays the help screen, all programs are
   # assumed to have this option.
   opts.on( '-h', '--help', 'Display this screen' ) do
     puts opts
     exit 0
   end

end
 
optparse.parse!
 

if options[:application] == nil && !(options[:grid])
  puts "Application name not defined!" 
  exit 1
end



pos = 0
appName=options[:application]
sut = TDriver.sut(:Id=> 'sut_qt_maemo')    
appOnTop = sut.application()	

# Stop the MProgressIndicator
system("initctl stop xsession/mprogressindicator")

while appOnTop.attribute('objectName') != 'meegotouchhome'
      fullName = appOnTop.attribute('FullName')

#      puts "Now killing #{fullName} from the top"
      system "pkill #{fullName}"
      appOnTop = sut.application()
end

# Application grid should be now visible
if options[:grid] 
  exit 0;
end

@meegoHome = sut.application(:name => 'meegotouchhome')


sleep(2)
if @meegoHome.test_object_exists?("LauncherButton", :text => appName)
  icon = @meegoHome.LauncherButton(:name => "LauncherButton", :text => appName)
  while icon.attribute('visibleOnScreen') == 'false' || @meegoHome.LauncherButton(:name => "LauncherButton", :text => appName).attribute('y').to_i > 400
    @meegoHome.Launcher.MPannableViewport( :name => 'SwipePage' ).MWidget( :name => 'glass' ).gesture(:Up, 1, 300)
    sleep(0.2)
    icon.refresh
  end
  xpos = @meegoHome.LauncherButton(:name => "LauncherButton", :text => appName).attribute('x')
  ypos = @meegoHome.LauncherButton(:name => "LauncherButton", :text => appName).attribute('y')
  @pos = "#{xpos}x#{ypos}"
  
  print @pos
  exit 0
else
  #icon does not
  #raise error and exit
  raise "Application not found in Application grid"
  exit 1
end

