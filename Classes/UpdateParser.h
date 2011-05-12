//
//  UpdateParser.h
//  Enterprise Updater
//
//  Created by John Szumski on 3/9/11.
//  Copyright 2011 CapTech Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kRootTag @"updater"
#define kCurrentVersionTag @"currentVersion"
#define kDownloadURLTag @"downloadURL"

@protocol UpdateParserDelegate

@required
-(void)updateCheckSucceededWithCurrentVersion:(NSString*)currentVersion downloadURL:(NSString*)url;
-(void)updateCheckFailedWithError:(NSError*)error;

@end


@interface UpdateParser : NSObject <NSXMLParserDelegate> {
	NSMutableData*				urlData;
	id<UpdateParserDelegate>	delegate;
	
	NSString*					currentVersion;
	NSString*					downloadURL;
	
	NSMutableString*			currentElementValue;
	BOOL						flagCurrentVersion;
	BOOL						flagDownloadURL;
}

-(void)parseUpdateURL:(NSString *)url delegate:(id<UpdateParserDelegate>)delegate;

@end