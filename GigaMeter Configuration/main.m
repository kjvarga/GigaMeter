//
//  main.m
//  unwired
//
//  Created by Karl Varga on 28/03/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <MacRuby/MacRuby.h>
#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import <Security/Security.h>

int main(int argc, char *argv[])
{
	return macruby_main("rb_main.rb", argc, argv);
}
