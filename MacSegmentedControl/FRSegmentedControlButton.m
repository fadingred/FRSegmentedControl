//
//  FRSegmentedControlButton.m
//  MacSegmentedControl
//
//  Created by FRBenedict on 6/13/13.
//  Copyright (c) 2013 Benedict Fritz. All rights reserved.
//

#import "FRSegmentedControlButton.h"

enum FRBezierType {
	kStrokeType,
	kFillType
};
typedef enum FRBezierType FRBezierType;

@interface FRSegmentedControlButton ()
- (NSBezierPath *)bezierPathForButtonBorder;
- (NSBezierPath *)bezierPathForButtonFill;

@property (nonatomic, readonly) BOOL isLeftCell;
@property (nonatomic, readonly) BOOL isTopCell;
@property (nonatomic, readonly) BOOL isRightCell;
@property (nonatomic, readonly) BOOL isBottomCell;

// need to offset all strokes by 0.5 so we get pixel perfect drawing
@property (nonatomic, readonly) CGFloat minStrokeX;
@property (nonatomic, readonly) CGFloat maxStrokeX;
@property (nonatomic, readonly) CGFloat minStrokeY;
@property (nonatomic, readonly) CGFloat maxStrokeY;

@property (nonatomic, readonly) CGFloat minFillX;
@property (nonatomic, readonly) CGFloat maxFillX;
@property (nonatomic, readonly) CGFloat minFillY;
@property (nonatomic, readonly) CGFloat maxFillY;

- (NSBezierPath *)shadowBezierPath;
- (NSBezierPath *)topEtchBezierPath;
- (NSBezierPath *)bottomEtchBezierPath;

// need to split up all bezier path and append bezier path methods because NSBezierPath doesn't handle appending
// as well as UIBezierPath in that the move commands of the non-append methods totally mess up appending. i.e. if
// you attempt to append bezier paths that are separate it won't work. at least that's what i found in my
// experimentation.
- (NSBezierPath *)leftSideBezierPathForType:(FRBezierType)type;
- (void)appendLeftPathToBezierPath:(NSBezierPath *)bezierPath bezierType:(FRBezierType)type;
- (NSBezierPath *)topSideBezierPathForType:(FRBezierType)type;
- (void)appendTopPathToBezierPath:(NSBezierPath *)bezierPath bezierType:(FRBezierType)type;
- (NSBezierPath *)rightSideBezierPathForType:(FRBezierType)type;
- (void)appendRightPathToBezierPath:(NSBezierPath *)bezierPath bezierType:(FRBezierType)type;
- (NSBezierPath *)bottomSideBezierPathForType:(FRBezierType)type;
- (void)appendBottomPathToBezierPath:(NSBezierPath *)bezierPath bezierType:(FRBezierType)type;
@end

@implementation FRSegmentedControlButton

- (void)setFrame:(NSRect)frame {
	frame = NSIntegralRect(frame);
	_frame = frame;
}

- (void)draw {
	NSBezierPath *fillPath = [self bezierPathForButtonFill];
	NSColor *fillStartColor = nil;
	NSColor *fillEndColor = nil;
	if (self.state == NSOffState) {
		fillStartColor = [NSColor colorWithCalibratedRed:0.80 green:0.80 blue:0.80 alpha:1.00];
		fillEndColor = [NSColor colorWithCalibratedRed:0.93 green:0.93 blue:0.93 alpha:1.00];
	}
	else {
		fillStartColor = [NSColor colorWithCalibratedRed:0.54 green:0.54 blue:0.54 alpha:1.00];
		fillEndColor = [NSColor colorWithCalibratedRed:0.65 green:0.65 blue:0.65 alpha:1.00];
	}
	NSGradient *fillGradient = [[NSGradient alloc] initWithStartingColor:fillStartColor endingColor:fillEndColor];
	[fillGradient drawInBezierPath:fillPath angle:90.0];

	if (self.state == NSOnState) {
		NSGradient *shadowGradient =
			[[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:0.6 green:0.6 blue:0.6 alpha:1.00]
										  endingColor:[NSColor colorWithCalibratedRed:0.5 green:0.5 blue:0.5 alpha:1.00]];
		[shadowGradient drawInBezierPath:[self shadowBezierPath] angle:90.0];
	}

	// we handle drawing borders by only drawing the top and left borders. handle special cases for bottom row
	// and right row.
	[[NSColor colorWithCalibratedRed:0.75 green:0.75 blue:0.75 alpha:1.00] setStroke];
	[[self leftSideBezierPathForType:kStrokeType] stroke];
	[[self topSideBezierPathForType:kStrokeType] stroke];
	if (self.isRightCell) { [[self rightSideBezierPathForType:kStrokeType] stroke]; }
	if (self.isBottomCell) { [[self bottomSideBezierPathForType:kStrokeType] stroke]; }

	if (self.isTopCell && self.state == NSOffState) {
		[[NSColor whiteColor] setStroke];
		[[self topEtchBezierPath] stroke];
	}

	if (self.isBottomCell) {
		[[NSColor whiteColor] setStroke];
		[[self bottomEtchBezierPath] stroke];
	}

	NSSize size = [self.attributedTitle size];
	NSRect buttonFrame = self.frame;
	buttonFrame.origin.y -= (buttonFrame.size.height - size.height) / 2;
	[self.attributedTitle drawInRect:NSIntegralRect(buttonFrame)];
}

- (NSDictionary *)titleAttributes {
	NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[paragraphStyle setAlignment:NSCenterTextAlignment];
	
	NSFont *titleFont = [NSFont systemFontOfSize:11];
	
	NSColor *titleColor = nil;
	NSShadow *titleShadow = [[NSShadow alloc] init];
	if (self.state == NSOnState) {
		titleColor = [NSColor whiteColor];
		titleShadow.shadowColor = [NSColor colorWithCalibratedRed:0.25 green:0.25 blue:0.25 alpha:1.00];
	}
	else {
		titleColor = [NSColor colorWithCalibratedRed:0.29 green:0.29 blue:0.29 alpha:1.00];
		titleShadow.shadowColor = [NSColor whiteColor];
	}
	titleShadow.shadowOffset = NSMakeSize(0.0, -1.0);
	
	return @{ NSParagraphStyleAttributeName : paragraphStyle,
		   NSFontAttributeName : titleFont,
		   NSForegroundColorAttributeName : titleColor,
		   NSShadowAttributeName : titleShadow };
}

- (NSBezierPath *)bezierPathForButtonBorder {
	NSBezierPath *borderPath = [self leftSideBezierPathForType:kStrokeType];
	[self appendTopPathToBezierPath:borderPath bezierType:kStrokeType];
	[self appendRightPathToBezierPath:borderPath bezierType:kStrokeType];
	[self appendBottomPathToBezierPath:borderPath bezierType:kStrokeType];
	return borderPath;
}

- (NSBezierPath *)bezierPathForButtonFill {
	NSBezierPath *fillPath = [self leftSideBezierPathForType:kFillType];
	[self appendTopPathToBezierPath:fillPath bezierType:kFillType];
	[self appendRightPathToBezierPath:fillPath bezierType:kFillType];
	[self appendBottomPathToBezierPath:fillPath bezierType:kFillType];
	return fillPath;
}

- (NSBezierPath *)shadowBezierPath {
	CGFloat shadowHeight = 5.0;
	
	NSBezierPath *shadowPath = [NSBezierPath bezierPath];
	NSPoint startPoint;
	if (self.isTopCell && self.isLeftCell) {
		startPoint = NSMakePoint(self.minFillX+self.cornerRadius, self.maxFillY);
		[shadowPath moveToPoint:startPoint];
		[shadowPath lineToPoint:NSMakePoint(self.maxFillX, self.maxFillY)];
	}
	else if (self.isTopCell && self.isRightCell) {
		startPoint = NSMakePoint(self.minFillX, self.maxFillY);
		[shadowPath moveToPoint:startPoint];
		[shadowPath lineToPoint:NSMakePoint(self.maxFillX-self.cornerRadius, self.maxFillY)];
	}
	else {
		startPoint = NSMakePoint(self.minFillX, self.maxFillY);
		[shadowPath moveToPoint:startPoint];
		[shadowPath lineToPoint:NSMakePoint(self.maxFillX, self.maxFillY)];
	}
	
	[shadowPath lineToPoint:NSMakePoint(self.maxFillX, self.maxFillY-shadowHeight)];
	if (self.isTopCell && self.isLeftCell) { [shadowPath lineToPoint:NSMakePoint(self.minFillX, startPoint.y - shadowHeight)]; }
	else { [shadowPath lineToPoint:NSMakePoint(startPoint.x, startPoint.y - shadowHeight)]; }
	[shadowPath lineToPoint:startPoint];
	
	return shadowPath;
}


#pragma mark -
#pragma mark etch paths
// ----------------------------------------------------------------------------------------------------
// etch paths
// ----------------------------------------------------------------------------------------------------

- (NSBezierPath *)topEtchBezierPath {
	NSBezierPath *topEtchPath = [NSBezierPath bezierPath];
	
	CGFloat topEtchY = self.maxStrokeY-1.0;
	// use the minFillX since we only want to cover the fill portion with the etch
	if (self.isLeftCell) {
		[topEtchPath moveToPoint:NSMakePoint(self.minFillX+self.cornerRadius, topEtchY)];
	}
	else {
		[topEtchPath moveToPoint:NSMakePoint(self.minFillX, topEtchY)];
	}
	
	if (self.isRightCell) {
		[topEtchPath lineToPoint:NSMakePoint(self.maxFillX-self.cornerRadius, topEtchY)];
	}
	else {
		[topEtchPath lineToPoint:NSMakePoint(self.maxFillX, topEtchY)];
	}
	
	return topEtchPath;
}

- (NSBezierPath *)bottomEtchBezierPath {
	NSBezierPath *bottomEtchPath = [NSBezierPath bezierPath];
	
	if (self.isBottomCell) {
		CGFloat bottomEtchY = self.minStrokeY-1.0;
		if (self.isLeftCell) { [bottomEtchPath moveToPoint:NSMakePoint(self.minStrokeX+self.cornerRadius, bottomEtchY)]; }
		else { [bottomEtchPath moveToPoint:NSMakePoint(self.minStrokeX, bottomEtchY)]; }
		
		if (self.isRightCell) { [bottomEtchPath lineToPoint:NSMakePoint(self.maxStrokeX-self.cornerRadius, bottomEtchY)]; }
		else { [bottomEtchPath lineToPoint:NSMakePoint(self.maxStrokeX, bottomEtchY)]; }
	}
	
	return bottomEtchPath;
}


#pragma mark -
#pragma mark left
// ----------------------------------------------------------------------------------------------------
// left
// ----------------------------------------------------------------------------------------------------

- (NSBezierPath *)leftSideBezierPathForType:(FRBezierType)type {
	CGFloat minX = type == kStrokeType ? self.minStrokeX : self.minFillX;
	CGFloat minY = type == kStrokeType ? self.minStrokeY : self.minFillY;
	
	NSBezierPath *leftPath = [NSBezierPath bezierPath];
	if (self.isLeftCell) {
		if (self.isBottomCell && self.isTopCell) { [leftPath moveToPoint:NSMakePoint(minX+self.cornerRadius, minY)]; }
		else if (self.isBottomCell) { [leftPath moveToPoint:NSMakePoint(minX+self.cornerRadius, minY)]; }
		else if (self.isTopCell) { [leftPath moveToPoint:NSMakePoint(minX, minY)]; }
		else { [leftPath moveToPoint:NSMakePoint(minX, minY)]; }
	}
	else {
		[leftPath moveToPoint:NSMakePoint(minX, minY)];
	}
	[self appendLeftPathToBezierPath:leftPath bezierType:type];
	
	return leftPath;
}

- (void)appendLeftPathToBezierPath:(NSBezierPath *)bezierPath bezierType:(FRBezierType)type {
	CGFloat minX = type == kStrokeType ? self.minStrokeX : self.minFillX;
	CGFloat minY = type == kStrokeType ? self.minStrokeY : self.minFillY;
	CGFloat maxY = type == kStrokeType ? self.maxStrokeY : self.maxFillY;
	
	if (self.isLeftCell) {
		if (self.isBottomCell && self.isTopCell) {
			[bezierPath appendBezierPathWithArcFromPoint:NSMakePoint(minX, minY)
												 toPoint:NSMakePoint(minX, minY+self.cornerRadius)
												  radius:self.cornerRadius];
			[bezierPath lineToPoint:NSMakePoint(minX, maxY-self.cornerRadius)];
			[bezierPath appendBezierPathWithArcFromPoint:NSMakePoint(minX, maxY)
												 toPoint:NSMakePoint(minX+self.cornerRadius, maxY)
												  radius:self.cornerRadius];
		}
		else if (self.isBottomCell) {
			[bezierPath appendBezierPathWithArcFromPoint:NSMakePoint(minX, minY)
												 toPoint:NSMakePoint(minX, minY+self.cornerRadius)
												  radius:self.cornerRadius];
			[bezierPath lineToPoint:NSMakePoint(minX, maxY)];
		}
		else if (self.isTopCell) {
			[bezierPath lineToPoint:NSMakePoint(minX, maxY-self.cornerRadius)];
			[bezierPath appendBezierPathWithArcFromPoint:NSMakePoint(minX, maxY)
												 toPoint:NSMakePoint(minX+self.cornerRadius, maxY)
												  radius:self.cornerRadius];
		}
		else {
			[bezierPath lineToPoint:NSMakePoint(minX, maxY)];
		}
	}
	else {
		[bezierPath lineToPoint:NSMakePoint(minX, maxY)];
	}
}


#pragma mark -
#pragma mark top
// ----------------------------------------------------------------------------------------------------
// top
// ----------------------------------------------------------------------------------------------------

- (NSBezierPath *)topSideBezierPathForType:(FRBezierType)type {
	CGFloat minX = type == kStrokeType ? self.minStrokeX : self.minFillX;
	CGFloat maxY = type == kStrokeType ? self.maxStrokeY : self.maxFillY;
	
	NSBezierPath *topPath = [NSBezierPath bezierPath];
	if (self.isTopCell && self.isLeftCell) { [topPath moveToPoint:NSMakePoint(minX+self.cornerRadius, maxY)]; }
	else if (self.isTopCell && self.isRightCell) { [topPath moveToPoint:NSMakePoint(minX, maxY)]; }
	else { [topPath moveToPoint:NSMakePoint(minX, maxY)]; }
	[self appendTopPathToBezierPath:topPath bezierType:type];
	
	return topPath;
}

- (void)appendTopPathToBezierPath:(NSBezierPath *)bezierPath bezierType:(FRBezierType)type {
	CGFloat maxX = type == kStrokeType ? self.maxStrokeX : self.maxFillX;
	CGFloat maxY = type == kStrokeType ? self.maxStrokeY : self.maxFillY;
	
	if (self.isTopCell && self.isLeftCell) { [bezierPath lineToPoint:NSMakePoint(maxX, maxY)]; }
	else if (self.isTopCell && self.isRightCell) { [bezierPath lineToPoint:NSMakePoint(maxX-self.cornerRadius, maxY)]; }
	else { [bezierPath lineToPoint:NSMakePoint(maxX, maxY)]; }
}


#pragma mark -
#pragma mark right
// ----------------------------------------------------------------------------------------------------
// right
// ----------------------------------------------------------------------------------------------------

- (NSBezierPath *)rightSideBezierPathForType:(FRBezierType)type{
	CGFloat maxX = type == kStrokeType ? self.maxStrokeX : self.maxFillX;
	CGFloat maxY = type == kStrokeType ? self.maxStrokeY : self.maxFillY;
	
	NSBezierPath *rightPath = [NSBezierPath bezierPath];
	if (self.isRightCell) {
		if (self.isTopCell && self.isBottomCell) { [rightPath moveToPoint:NSMakePoint(maxX-self.cornerRadius, maxY)]; }
		else if (self.isTopCell) { [rightPath moveToPoint:NSMakePoint(maxX-self.cornerRadius, maxY)]; }
		else if (self.isBottomCell) { [rightPath moveToPoint:NSMakePoint(maxX, maxY)]; }
		else { [rightPath moveToPoint:NSMakePoint(maxX, maxY)]; }
	}
	[self appendRightPathToBezierPath:rightPath bezierType:type];
	return rightPath;
}

- (void)appendRightPathToBezierPath:(NSBezierPath *)bezierPath bezierType:(FRBezierType)type {
	CGFloat maxX = type == kStrokeType ? self.maxStrokeX : self.maxFillX;
	CGFloat minY = type == kStrokeType ? self.minStrokeY : self.minFillY;
	CGFloat maxY = type == kStrokeType ? self.maxStrokeY : self.maxFillY;
	
	if (self.isRightCell) {
		if (self.isTopCell && self.isBottomCell) {
			[bezierPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, maxY)
												 toPoint:NSMakePoint(maxX, maxY-self.cornerRadius)
												  radius:self.cornerRadius];
			[bezierPath lineToPoint:NSMakePoint(maxX, minY+self.cornerRadius)];
			[bezierPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, minY)
												 toPoint:NSMakePoint(maxX-self.cornerRadius, minY)
												  radius:self.cornerRadius];
		}
		else if (self.isTopCell) {
			[bezierPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, maxY)
												 toPoint:NSMakePoint(maxX, maxY-self.cornerRadius)
												  radius:self.cornerRadius];
			[bezierPath lineToPoint:NSMakePoint(maxX, minY)];
		}
		else if (self.isBottomCell) {
			[bezierPath lineToPoint:NSMakePoint(maxX, minY+self.cornerRadius)];
			[bezierPath appendBezierPathWithArcFromPoint:NSMakePoint(maxX, minY)
												 toPoint:NSMakePoint(maxX-self.cornerRadius, minY)
												  radius:self.cornerRadius];
		}
		else {
			[bezierPath lineToPoint:NSMakePoint(maxX, minY)];
		}
	}
	else {
		[bezierPath lineToPoint:NSMakePoint(maxX, minY)];
	}
}

#pragma mark -
#pragma mark bottom
// ----------------------------------------------------------------------------------------------------
// bottom
// ----------------------------------------------------------------------------------------------------

- (NSBezierPath *)bottomSideBezierPathForType:(FRBezierType)type {
	CGFloat maxX = type == kStrokeType ? self.maxStrokeX : self.maxFillX;
	CGFloat minY = type == kStrokeType ? self.minStrokeY : self.minFillY;
	
	NSBezierPath *bottomPath = [NSBezierPath bezierPath];
	if (self.isRightCell) { [bottomPath moveToPoint:NSMakePoint(maxX-self.cornerRadius, minY)]; }
	else if (self.isLeftCell) { [bottomPath moveToPoint:NSMakePoint(maxX, minY)]; }
	else { [bottomPath moveToPoint:NSMakePoint(maxX, minY)]; }
	[self appendBottomPathToBezierPath:bottomPath bezierType:type];
	
	return bottomPath;
}

- (void)appendBottomPathToBezierPath:(NSBezierPath *)bezierPath bezierType:(FRBezierType)type {
	CGFloat minX = type == kStrokeType ? self.minStrokeX : self.minFillX;
	CGFloat minY = type == kStrokeType ? self.minStrokeY : self.minFillY;
	
	if (self.isRightCell) { [bezierPath lineToPoint:NSMakePoint(minX, minY)]; }
	else if (self.isLeftCell) { [bezierPath lineToPoint:NSMakePoint(minX+self.cornerRadius, minY)]; }
	else { [bezierPath lineToPoint:NSMakePoint(minX, minY)]; }
}


#pragma mark -
#pragma mark convenience properties
// ----------------------------------------------------------------------------------------------------
// convenience properties
// ----------------------------------------------------------------------------------------------------

- (BOOL)isLeftCell { return self.exposedEdges & FRLeftEdge; }
- (BOOL)isTopCell { return self.exposedEdges & FRTopEdge; }
- (BOOL)isRightCell { return self.exposedEdges & FRRightEdge; }
- (BOOL)isBottomCell { return self.exposedEdges & FRBottomEdge; }

- (CGFloat)minStrokeX { return NSMinX(self.frame) + 0.5; }
- (CGFloat)maxStrokeX {
	CGFloat maxX = NSMaxX(self.frame) - 0.5;
	if (self.isRightCell) { maxX--; }
	return maxX;
}
- (CGFloat)minStrokeY {
	CGFloat minY = NSMinY(self.frame) + 0.5;
	// if we're on the bottom, scoot everything up so we can draw bottom etch
	if (self.isBottomCell) { minY++; }
	return minY;
}
- (CGFloat)maxStrokeY { return NSMaxY(self.frame) - 0.5; }


- (CGFloat)minFillX { return NSMinX(self.frame)+1.0; }
- (CGFloat)maxFillX {
	CGFloat maxX = NSMaxX(self.frame);
	if (self.isRightCell) { maxX--; }
	return maxX;
}
- (CGFloat)minFillY {
	CGFloat minY = NSMinY(self.frame);
	// if we're on the bottom, scoot everything up so we can draw bottom etch
	if (self.isBottomCell) { minY++; }
	return minY;
}
- (CGFloat)maxFillY { return NSMaxY(self.frame)-1.0; }


@end
