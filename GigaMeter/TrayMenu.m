//
//  TrayMenu.m
//  test
//
//  Created by Karl Varga on 4/04/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TrayMenu.h"

@implementation TrayMenu

- (void) configureApplication:(id)sender {
	[[NSWorkspace sharedWorkspace] launchApplication:@"GigaMeter Configuration"];
}

- (void) actionQuit:(id)sender {
	[NSApp terminate:sender];
}

- (NSMenu *) createMenu {
	NSZone *menuZone = [NSMenu menuZone];
	NSMenu *menu = [[NSMenu allocWithZone:menuZone] init];
	NSMenuItem *menuItem;

	menuItem = [menu addItemWithTitle:@"In 5.35 GB, Off 4.34 GB, 4 days left"
							   action:NULL
						keyEquivalent:@""];
	[menuItem setEnabled:(BOOL)FALSE];
	
	menuItem = [menu addItemWithTitle:@"Updated 3 days ago"
							   action:NULL
						keyEquivalent:@""];
	[menuItem setEnabled:(BOOL)FALSE];
	
	// Add Separator
	[menu addItem:[NSMenuItem separatorItem]];
	
	// Configure application
	menuItem = [menu addItemWithTitle:@"Configure"
							   action:@selector(configureApplication:)
						keyEquivalent:@","];
	[menuItem setToolTip:@"Configure Options"];
	[menuItem setTarget:self];
	
	// Add Quit Action
	menuItem = [menu addItemWithTitle:@"Quit"
							   action:@selector(actionQuit:)
						keyEquivalent:@"q"];
	[menuItem setToolTip:@"Quit GigaMeter"];
	[menuItem setTarget:self];
	
	return menu;
}

- (void) applicationDidFinishLaunching:(NSNotification *)notification {
	NSMenu *menu = [self createMenu];
	
	_statusItem = [[[NSStatusBar systemStatusBar]
					statusItemWithLength:NSVariableStatusItemLength] retain];
	[_statusItem setMenu:menu];
	[_statusItem setHighlightMode:YES];
	[_statusItem setToolTip:@"GigaMeter Monitor"];
	//[_statusItem setImage:[NSImage imageNamed:@"flowerSmall.gif"]];
	[_statusItem setTitle:@"5.36 GB / 4.45 GB / 4 days"];
	[menu release];
}

@end
