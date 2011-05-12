//
//  Enterprise_UpdaterAppDelegate.h
//  Enterprise Updater
//
//  Created by John Szumski on 3/9/11.
//  Copyright 2011 CapTech Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Enterprise_UpdaterAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow                *window;
    UINavigationController  *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow                 *window;
@property (nonatomic, retain) IBOutlet UINavigationController   *navigationController;

@end