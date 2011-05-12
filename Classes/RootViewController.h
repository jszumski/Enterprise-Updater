//
//  RootViewController.h
//  Enterprise Updater
//
//  Created by John Szumski on 3/9/11.
//  Copyright 2011 CapTech Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpdateParser.h"

@interface RootViewController : UITableViewController <UITextFieldDelegate, UpdateParserDelegate> {
	UITextField				*updateURLField;
	UIActivityIndicatorView	*spinner;
	NSString				*updateURL;
	UpdateParser			*parser;
	NSString				*downloadURL;
}

@end