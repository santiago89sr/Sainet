//
//  NewPlaceViewController.h
//  Sainet
//
//  Created by Santiago Rodriguez on 30/10/16.
//  Copyright © 2016 Santiago Rodriguez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <sqlite3.h>
#import "Reachability.h"
#import "MBProgressHUD.h"

@interface NewPlaceViewController : UIViewController<UITextFieldDelegate,UIGestureRecognizerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,CLLocationManagerDelegate>{
    
    CLLocationManager *locationManager;
    MBProgressHUD * HUD;
    
}

@property (strong, nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *sainetDB;

@property (weak, nonatomic) IBOutlet UIButton *botonMenu;
@property (weak, nonatomic) IBOutlet UITextField *nombreLugar;
@property (weak, nonatomic) IBOutlet UIImageView *image;

@property (nonatomic,retain) NSString *latitud;
@property (nonatomic,retain) NSString *longitud;

@property (strong,nonatomic) NSString *token;

@property (nonatomic,retain) NSString *idUsuario;

- (IBAction)botonGuardarLugar:(id)sender;

@end
