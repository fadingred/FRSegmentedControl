//
//  FRAppDelegate.h
//  MacSegmentedControl
//
//  Created by Benedict Fritz on 6/4/13.
//  Copyright (c) 2013 Benedict Fritz. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FRSegmentedControl.h"

@interface FRAppDelegate : NSObject <NSApplicationDelegate, FRSegmentedControlDelegate, FRSegmentedControlDataSource>

@property (assign) IBOutlet NSWindow *window;

@end
