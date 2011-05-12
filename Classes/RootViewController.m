//
//  RootViewController.m
//  Enterprise Updater
//
//  Created by John Szumski on 3/9/11.
//  Copyright 2011 CapTech Consulting. All rights reserved.
//

#import "RootViewController.h"

@implementation RootViewController


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.title = @"Enterprise Updater";
    
	updateURL = @"http://johnszumski.com/demo/v1.1.html";
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return @"Web Service Endpoint";
			
		case 1:
			return @"Update Test";
			
		default: 
			return @"";
	}
}

- (NSString*) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	switch (section) {
        case 0:
            return @"Change this URL to mimic different responses from the web service.";
            
		case 1: 
			return [@"Current version: " stringByAppendingString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
			
		default:
			return @"";
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *value1CellID = @"urlCell";
	static NSString *defaultCellID = @"buttonCell";
    
    UITableViewCell *cell;
    
	// endpoint cell
	if (indexPath.section == 0) {
		cell = [tableView dequeueReusableCellWithIdentifier:value1CellID];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:value1CellID] autorelease];
		}
	
		cell.textLabel.text = @"URL";
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		// URL input field
		updateURLField = [[UITextField alloc] initWithFrame:CGRectMake(0, cell.frame.size.height, 235, cell.frame.size.height-14)];
		updateURLField.backgroundColor = [UIColor clearColor];
		updateURLField.font = [UIFont systemFontOfSize:14.0];
		updateURLField.returnKeyType = UIReturnKeyDone;
		updateURLField.keyboardType = UIKeyboardTypeURL;
		updateURLField.autocorrectionType = UITextAutocorrectionTypeNo;
		updateURLField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		updateURLField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		updateURLField.delegate = self;
		updateURLField.text = updateURL;
		cell.accessoryView = updateURLField;
	
	// update button cell
	} else if (indexPath.section == 1) {
		cell = [tableView dequeueReusableCellWithIdentifier:defaultCellID];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:defaultCellID] autorelease];
		}
		
		cell.textLabel.text = @"Check for Updates";
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		
		// spinner
		spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		spinner.frame = CGRectMake(cell.frame.size.width-50, 12, spinner.frame.size.width, spinner.frame.size.height);
		[cell.contentView addSubview:spinner];
	}
	
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.section == 1) {
		if (parser == nil) {
			parser = [[UpdateParser alloc] init];
		}
		
		[spinner startAnimating];
		[parser parseUpdateURL:updateURL delegate:self];
	}
}


#pragma mark -
#pragma mark Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	updateURL = textField.text;
}


#pragma mark -
#pragma mark Update parser delegate

- (void)updateCheckSucceededWithCurrentVersion:(NSString *)currentVersion downloadURL:(NSString *)url {
	[spinner stopAnimating];
	
	[downloadURL release];
	downloadURL = [url retain];
	
	// figure out the local and update versions
	NSString *localVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	NSArray *partsLocal = [localVersion componentsSeparatedByString:@"."];
	NSArray *partsUpdate = [currentVersion componentsSeparatedByString:@"."];
	
	int updateMajorVersion = [(NSString*) [partsUpdate objectAtIndex:0] intValue];
	int updateMinorVersion = [(NSString*) [partsUpdate objectAtIndex:1] intValue];
	int localMajorVersion = [(NSString*) [partsLocal objectAtIndex:0] intValue];
	int localMinorVersion = [(NSString*) [partsLocal objectAtIndex:1] intValue];
	
	
	// show an alert message with the update results
	UIAlertView *updateResultsAlert;
	NSString *updateMessage;
	
	if (updateMajorVersion > localMajorVersion || (updateMajorVersion == localMajorVersion && updateMinorVersion > localMinorVersion)) {
		// a new version is available
		updateMessage = [NSString stringWithFormat:@"Version %@ is available (you have version %@).  Do you want to update?",currentVersion,localVersion];
		updateResultsAlert = [[UIAlertView alloc] initWithTitle:@"Update Available" 
				message:updateMessage delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Update", nil];
	
	} else {
		// no updates
		updateMessage = [NSString stringWithFormat:@"Version %@ is the most current version.",currentVersion];
		updateResultsAlert = [[UIAlertView alloc] initWithTitle:@"No Updates Available" 
				message:updateMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	}
	
	[updateResultsAlert show];
	[updateResultsAlert release];
}

-(void)updateCheckFailedWithError:(NSError*)error {
	[spinner stopAnimating];

	UIAlertView *errorMsg = [[UIAlertView alloc] initWithTitle:@"Error" 
			message:[@"Connection failed: " stringByAppendingString:[error description]] 
			delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	
	[errorMsg show];
	[errorMsg release];
}


#pragma mark -
#pragma mark Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex { 
	if (buttonIndex != [alertView cancelButtonIndex]) {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:downloadURL]];
	}
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

- (void)dealloc {
	[updateURLField release];
	[spinner release];
	[updateURL release];
	[parser release];
	[downloadURL release];
    [super dealloc];
}

@end