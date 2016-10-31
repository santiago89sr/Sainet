//
//  AppDelegate.h
//  Sainet
//
//  Created by Santiago Rodriguez on 29/10/16.
//  Copyright © 2016 Santiago Rodriguez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    
    NSInteger hayUsuario;
    
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *sainetDB;
@property (strong,nonatomic) NSString *token;

@end

