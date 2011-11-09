//
//  PaddedTextFieldCell.h
//  StatusItem
//
//  Created by Joshua Garnham on 17/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BGHUDAppKit/BGHUDTextFieldCell.h"

@interface PaddedTextFieldCell : BGHUDTextFieldCell {
	int leftMargin;
}

@property (nonatomic, assign) int leftMargin;

@end
