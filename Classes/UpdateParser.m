//
//  UpdateParser.m
//  Enterprise Updater
//
//  Created by John Szumski on 3/9/11.
//  Copyright 2011 CapTech Consulting. All rights reserved.
//

#import "UpdateParser.h"


@implementation UpdateParser

- (void)parseUpdateURL:(NSString *)url delegate:(id)del {
	urlData = [[NSMutableData data] retain];
	delegate = del;
	
	[NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] delegate:self];
}


#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (!currentElementValue) {
		currentElementValue = [[NSMutableString alloc] initWithString:string];
	} else {
		[currentElementValue appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:kCurrentVersionTag]) {
		flagCurrentVersion = YES;
	
	} else if ([elementName isEqualToString:kDownloadURLTag]) {
		flagDownloadURL = YES;
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqualToString:kCurrentVersionTag]) {
		flagCurrentVersion = NO;
		
		// save the current version
		if (currentElementValue != nil) {
			currentVersion = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		}
		
	} else if ([elementName isEqualToString:kDownloadURLTag]) {
		flagDownloadURL = NO;
		
		// save the download URL
		if (currentElementValue != nil) {
			downloadURL = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		}
	
	} else if ([elementName isEqualToString:kRootTag]) {
		// we're at the end of the document, so call the delegate saying we finished
		[delegate updateCheckSucceededWithCurrentVersion:currentVersion downloadURL:downloadURL];
	}
	
	currentElementValue = nil;
}


#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {  
    [urlData setLength:0];  
}  
  
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {  
    [urlData appendData:data];  
}

- (void)connection:(NSURLConnection *)theConnection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge*)challenge {
	// if you need HTTP Auth, fill in your credentials here

	if ([challenge previousFailureCount] == 0) {
		[[challenge sender] useCredential:[NSURLCredential credentialWithUser:@"demo" password:@"captech01" 
				persistence:NSURLCredentialPersistenceNone] forAuthenticationChallenge:challenge];
				
	} else {
		[[challenge sender] cancelAuthenticationChallenge:challenge]; 
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSXMLParser *parser = [[[NSXMLParser alloc] initWithData:urlData] autorelease];
	parser.delegate = self;
	[parser parse];
}
  
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {  
	[delegate updateCheckFailedWithError:error];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[currentElementValue release];
	[downloadURL release];
    [super dealloc];
}

@end