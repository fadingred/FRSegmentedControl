//
// Copyright (c) 2013 FadingRed LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
// documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
// Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "FRSegmentedControl.h"
#import "FRSegmentedControlButton.h"

@interface FRSegmentedControl ()
@property (strong, nonatomic) NSMutableArray *segmentedButtons;
@property (nonatomic, readonly) NSUInteger numColumns;
@property (nonatomic, readonly) NSUInteger numRows;
@property (nonatomic, readonly) CGFloat cornerRadius;
- (void)setupButtonsIfNeeded;
@end

@implementation FRSegmentedControl

- (void)viewWillDraw {
	[super viewWillDraw];
	[self setupButtonsIfNeeded];
	for (FRSegmentedControlButton *button in self.segmentedButtons) {
		if ([self.dataSource respondsToSelector:@selector(segmentedControl:titleForButton:)]) {
			NSString *title = [self.dataSource segmentedControl:self titleForButton:button];
			button.attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:button.titleAttributes];
		}
	}
}

- (void)setFrame:(NSRect)frameRect {
	frameRect = NSIntegralRect(frameRect);
	[super setFrame:frameRect];
}

- (void)setupButtonsIfNeeded {
	if (self.segmentedButtons.count == 0) {
		self.segmentedButtons = [[NSMutableArray alloc] init];
		NSRect buttonFrame = NSMakeRect(0, 0, self.frame.size.width/self.numColumns, self.frame.size.height/self.numRows);
		for (NSUInteger j = 0; j < self.numRows; j++) {
			for (NSUInteger i = 0; i < self.numColumns; i++) {
				FRSegmentedControlButton *button = [[FRSegmentedControlButton alloc] init];
				button.target = self;
				button.action = @selector(selectButton:);
				button.column = i;
				button.row = j;
				button.frame = buttonFrame;
				button.cornerRadius = 5.0;

				[self.segmentedButtons addObject:button];
				buttonFrame.origin.x += buttonFrame.size.width;
			}
			buttonFrame.origin.x = 0;
			buttonFrame.origin.y += buttonFrame.size.height;
		}

		for (NSUInteger i = 0; i < self.segmentedButtons.count; i++) {
			FRSegmentedControlButton *button = [self.segmentedButtons objectAtIndex:i];

			// pull out numColumns into variable so we can do a divide-by-zero check and avoid a build warning.
			NSUInteger columns = self.numColumns;
			if (i >= self.segmentedButtons.count - columns) { button.exposedEdges |= FRTopEdge; }
			if (i < columns) { button.exposedEdges |= FRBottomEdge; }
			if (columns > 0) {
				if (i % columns == 0) { button.exposedEdges |= FRLeftEdge; }
				if (i % columns == self.numColumns-1) { button.exposedEdges |= FRRightEdge; }
			}
		}
	}
}

- (FRSegmentedControlButton *)buttonAtColumn:(NSUInteger)column row:(NSUInteger)row {
	NSUInteger buttonIndex = column + row*self.numColumns;
	return [self.segmentedButtons objectAtIndex:buttonIndex];
}

- (void)drawRect:(NSRect)dirtyRect {
	for (FRSegmentedControlButton *button in self.segmentedButtons) { [button draw]; }
}


#pragma mark -
#pragma mark actions
// ----------------------------------------------------------------------------------------------------
// actions
// ----------------------------------------------------------------------------------------------------

- (void)selectButton:(id)sender {
	FRSegmentedControlButton *button = (FRSegmentedControlButton *)sender;

	if (self.singleSelection) {
		for (FRSegmentedControlButton *b in self.segmentedButtons) { b.state = NSOffState; }
		button.state = NSOnState;
	}
	else {
		if (button.state == NSOnState) { button.state = NSOffState; }
		else if (button.state == NSOffState) { button.state = NSOnState; }
	}

	[self setNeedsDisplay];

	if ([self.delegate respondsToSelector:@selector(segmentedControl:didSelectButton:)]) {
		[self.delegate segmentedControl:self didSelectButton:button];
	}
}

- (void)mouseDown:(NSEvent *)event {
	// this mouseDown method is needed since button cells are not truly in the view.
	[super mouseDown:event];

	// track mouse until up
	for (; event.type != NSLeftMouseUp;
		 event = [self.window nextEventMatchingMask:NSLeftMouseDraggedMask | NSLeftMouseUpMask]) {
		NSPoint location = [self convertPoint:[event locationInWindow] fromView:nil];
		for (FRSegmentedControlButton *button in self.segmentedButtons) {
			[button setHighlighted:NSPointInRect(location, button.frame)];
		}
		[self setNeedsDisplay:TRUE];
	}

	if (event.type == NSLeftMouseUp) {
		NSPoint location = [self convertPoint:[event locationInWindow] fromView:nil];
		for (FRSegmentedControlButton *button in self.segmentedButtons) {
			if (NSPointInRect(location, button.frame)) {
				[NSApp sendAction:button.action to:button.target from:button];
				break;
			}
		}
	}
}


#pragma mark -
#pragma mark properties
// ----------------------------------------------------------------------------------------------------
// properties
// ----------------------------------------------------------------------------------------------------

- (NSUInteger)numColumns {
	NSUInteger columnCount = 0;
	if ([self.dataSource respondsToSelector:@selector(numberOfColumnsInSegmentedControl:)]) {
		columnCount = [self.dataSource numberOfColumnsInSegmentedControl:self];
	}
	return columnCount;
}

- (NSUInteger)numRows {
	NSUInteger rowCount = 0;
	if ([self.dataSource respondsToSelector:@selector(numberOfRowsInSegmentedControl:)]) {
		rowCount = [self.dataSource numberOfRowsInSegmentedControl:self];
	}
	return rowCount;
}

- (CGFloat)cornerRadius {
	return 5.0f;
}


@end

