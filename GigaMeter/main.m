//
//  main.m
//  GigaMeter
//
//  Created by Karl Varga on 11/05/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <MacRuby/MacRuby.h>

int main(int argc, char *argv[])
{
    return macruby_main("rb_main.rb", argc, argv);
}

/*#import <Cocoa/Cocoa.h>
#import "TrayMenu.h"

int main(int argc, char *argv[])
{
  //return NSApplicationMain(argc,  (const char **) argv);
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  [NSApplication sharedApplication];
	
  TrayMenu *menu = [[TrayMenu alloc] init];
  //Controller.setTrayMenu(menu)
  
  [NSApp setDelegate:menu];
  [NSApp run];
	
  [pool release];
  return EXIT_SUCCESS;
}*/
