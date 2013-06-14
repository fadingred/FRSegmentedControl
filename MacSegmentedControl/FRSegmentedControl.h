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

#import <Cocoa/Cocoa.h>

@class
FRSegmentedControlButton, FRSegmentedControl;
@protocol
FRSegmentedControlDelegate, FRSegmentedControlDataSource;

@interface FRSegmentedControl : NSControl
@property (weak, nonatomic) IBOutlet id<FRSegmentedControlDelegate> delegate;
@property (weak, nonatomic) IBOutlet id<FRSegmentedControlDataSource> dataSource;

/*!
 \brief		Whether or not the segmented control only allows a single
			selection at a time.
 \details	When this is set to YES, the segmented control will always have
			exactly one button selected. Upon changing selection the previously
			selected button will be deselected.
 */
@property (nonatomic) BOOL singleSelection;
/*!
 \brief		Returns the button at the provided column and row
 \details	Use this method to check the state of buttons in the
			segmented control.
 */
- (FRSegmentedControlButton *)buttonAtColumn:(NSUInteger)column row:(NSUInteger)row;
@end


@protocol FRSegmentedControlDelegate <NSObject>
/*!
 \brief		This call is made to the delegate after a button is selected.
 \details	Since this call is made after selection, all button states have
			been updated by the time this call is made.
 */
- (void)segmentedControl:(FRSegmentedControl *)control didSelectButton:(FRSegmentedControlButton *)button;
@end


@protocol FRSegmentedControlDataSource <NSObject>
/*!
 \brief		Ask the data source for the title of a button.
 \details	Use the button's column and row properties to determine
			position.
 */
- (NSString *)segmentedControl:(FRSegmentedControl *)control titleForButton:(FRSegmentedControlButton *)button;

/*!
 \brief		The number of columns in the segmented control.
 \details	The number of columns should not change.
 */
- (NSInteger)numberOfColumnsInSegmentedControl:(FRSegmentedControl *)control;

/*!
 \brief		The number of rows in the segmented control.
 \details	The number of columns should not change.
 */
- (NSInteger)numberOfRowsInSegmentedControl:(FRSegmentedControl *)control;
@end

