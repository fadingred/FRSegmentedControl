//
//  FRAppDelegate.m
//  MacSegmentedControl
//
//  Created by Benedict Fritz on 6/4/13.
//  Copyright (c) 2013 Benedict Fritz. All rights reserved.
//

#import "FRAppDelegate.h"
#import "FRSegmentedControl.h"
#import "FRSegmentedControlButton.h"

@interface FRAppDelegate ()
@property (strong, nonatomic) IBOutlet FRSegmentedControl *weekSegmentedControl;
@property (strong, nonatomic) IBOutlet FRSegmentedControl *monthSegmentedControl;
@property (strong, nonatomic) NSArray *weekdays;
@end

@implementation FRAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	self.monthSegmentedControl.delegate = self;
	self.monthSegmentedControl.dataSource = self;
	[self.monthSegmentedControl setNeedsDisplay];

	self.weekSegmentedControl.delegate = self;
	self.weekSegmentedControl.dataSource = self;
	self.weekSegmentedControl.singleSelection = YES;
	[self.weekSegmentedControl setNeedsDisplay];
	self.weekdays = @[ @"Sun", @"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat" ];
}


- (NSInteger)numberOfColumnsInSegmentedControl:(FRSegmentedControl *)control {
	NSInteger numColumns = 0;
	if (control == self.weekSegmentedControl) { numColumns = 7; }
	else if (control == self.monthSegmentedControl) { numColumns = 4; }
	return numColumns;
}

- (NSInteger)numberOfRowsInSegmentedControl:(FRSegmentedControl *)control {
	NSInteger numRows = 0;
	if (control == self.weekSegmentedControl) { numRows = 1; }
	else if (control == self.monthSegmentedControl) { numRows = 3; }
	return numRows;
}


/*
 *	segmented control delegate
 */

- (NSString *)segmentedControl:(FRSegmentedControl *)control titleForButton:(FRSegmentedControlButton *)button {
	NSString *titleString = @"";
	if (control == self.weekSegmentedControl) {
		titleString = self.weekdays[button.column];
	}
	if (control == self.monthSegmentedControl) {
		if (button.row == 0) {
			if (button.column == 0) { titleString = @"Jan"; }
			if (button.column == 1) { titleString = @"Feb"; }
			if (button.column == 2) { titleString = @"Mar"; }
			if (button.column == 3) { titleString = @"Apr"; }
		}
		if (button.row == 1) {
			if (button.column == 0) { titleString = @"May"; }
			if (button.column == 1) { titleString = @"Jun"; }
			if (button.column == 2) { titleString = @"July"; }
			if (button.column == 3) { titleString = @"Aug"; }
		}
		if (button.row == 2) {
			if (button.column == 0) { titleString = @"Sep"; }
			if (button.column == 1) { titleString = @"Oct"; }
			if (button.column == 2) { titleString = @"Nov"; }
			if (button.column == 3) { titleString = @"Dec"; }
		}
	}
	return titleString;
}

- (void)segmentedControl:(FRSegmentedControl *)control didSelectButton:(FRSegmentedControlButton *)button {
	NSLog(@"Selected button with title %@ and state %li", button.title, button.state);
}

@end
