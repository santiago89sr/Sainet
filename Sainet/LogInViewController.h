//
//  LogInViewController.h
//  Sainet
//
//  Created by Santiago Rodriguez on 30/10/16.
//  Copyright © 2016 Santiago Rodriguez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "Reachability.h"
#import "MBProgressHUD.h"

@interface LogInViewController : UIViewController<UITextFieldDelegate>{
    
    MBProgressHUD * HUD;
    NSMutableArray *objetosUsuario;
    
}
    

@property (strong,nonatomic) NSString *token;
@property (weak, nonatomic) IBOutlet UITextField *correo;
@property (weak, nonatomic) IBOutlet UITextField *pass;
@property (strong, nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *sainetDB;

//Usuario
@property (nonatomic,retain) NSString *uid;
@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *email;



- (IBAction)botonVolver:(id)sender;
- (IBAction)botonIniciarSesion:(id)sender;
- (IBAction)botonFB:(id)sender;


@end
