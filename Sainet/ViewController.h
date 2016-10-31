//
//  ViewController.h
//  Sainet
//
//  Created by Santiago Rodriguez on 29/10/16.
//  Copyright © 2016 Santiago Rodriguez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "MBProgressHUD.h"
#import <sqlite3.h>

@interface ViewController : UIViewController<UITextFieldDelegate>{
    
    MBProgressHUD * HUD;
    
}

@property (strong,nonatomic) NSString *token;

@property (strong, nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *sainetDB;

//FB data
@property (nonatomic,retain) NSString *nombre;
@property (nonatomic,retain) NSString *apellido;
@property (nonatomic,retain) NSString *fbId;
@property (nonatomic,retain) NSString *email;

@property (weak, nonatomic) IBOutlet UITextField *correo;
@property (weak, nonatomic) IBOutlet UITextField *correo2;
@property (weak, nonatomic) IBOutlet UITextField *pass;
@property (weak, nonatomic) IBOutlet UITextField *pass2;

//Usuario
@property (nonatomic,retain) NSString *uid;


- (IBAction)botonRegistro:(id)sender;
- (IBAction)botonIniciarSesion:(id)sender;
- (IBAction)botonFB:(id)sender;


@end

