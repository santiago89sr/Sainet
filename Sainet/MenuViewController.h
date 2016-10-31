//
//  MenuViewController.h
//  Sainet
//
//  Created by Santiago Rodriguez on 30/10/16.
//  Copyright © 2016 Santiago Rodriguez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
#import <sqlite3.h>

@interface MenuViewController : UIViewController{
    
    NSArray *menu;
    
}

@property (strong, nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *sainetDB;

- (IBAction)botonCerrarSesion:(id)sender;


@end
