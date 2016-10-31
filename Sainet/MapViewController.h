//
//  MapViewController.h
//  Sainet
//
//  Created by Santiago Rodriguez on 29/10/16.
//  Copyright © 2016 Santiago Rodriguez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <sqlite3.h>
#import "Reachability.h"
#import "MBProgressHUD.h"

@interface MapViewController : UIViewController<MKMapViewDelegate>{
    
    NSMutableArray *objetosLugares;
    MBProgressHUD * HUD;
    
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tablaLugares;
@property (weak, nonatomic) IBOutlet UIView *viewLista;
@property (weak, nonatomic) IBOutlet UIView *viewMapa;
@property (weak, nonatomic) IBOutlet UIButton *botonMenu;

@property (strong, nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *sainetDB;

@property (nonatomic,retain) NSString *idUsuario;


- (IBAction)btnVista:(id)sender;


@end
