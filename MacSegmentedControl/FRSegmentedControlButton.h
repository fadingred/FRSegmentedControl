//
//  FRSegmentedControlButton.h
//  MacSegmentedControl
//
//  Created by FRBenedict on 6/13/13.
//  Copyright (c) 2013 Benedict Fritz. All rights reserved.
//

enum {
	FRTopEdge	 = 1 << 0,
	FRRightEdge	 = 1 << 1,
	FRBottomEdge = 1 << 2,
	FRLeftEdge	 = 1 << 3,
};
typedef NSUInteger FRExposedEdges;

@interface FRSegmentedControlButton : NSButtonCell
/*!
 \brief		Property that shows which edges of the button are exposed.
 \details	For example, in a single-row segmented control, the left-most button
			will evaluate to true for FRTopEdge, FRBottomEdge, and FRLeftEdge.
 */
@property (nonatomic) FRExposedEdges exposedEdges;

/*!
 \brief		The column of the segmented control where this button appears.
 \details
 */
@property (nonatomic) NSUInteger column;

/*!
 \brief		The row of the segmented control where this button appears.
 \details
 */
@property (nonatomic) NSUInteger row;

/*!
 \brief		The frame of the button within the FRSegmentedControl.
 \details	This value is set in FRSegmentedControl and shouldn't be modified.
 */
@property (nonatomic) NSRect frame;

/*!
 \brief		The corner radius of the corner buttons in the segmented control.
 \details	Determines how rounded the edges are.
 */
@property (nonatomic) CGFloat cornerRadius;

/*!
 \brief		Attributes for the title on the button.
 \details	This is the dictionary of attributes applied to the attributed string
			title of the button.
 */
@property (strong, nonatomic, readonly) NSDictionary *titleAttributes;

/*!
 \brief		Draw the button.
 \details	Draws the button within the its frame property.
 */
- (void)draw;
@end

