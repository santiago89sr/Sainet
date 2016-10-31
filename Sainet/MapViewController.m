//
//  MapViewController.m
//  Sainet
//
//  Created by Santiago Rodriguez on 29/10/16.
//  Copyright © 2016 Santiago Rodriguez. All rights reserved.
//

#import "MapViewController.h"
#import "Lugar.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ListTableViewCell.h"
#import "SWRevealViewController.h"
#import "ViewPlaceViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.botonMenu addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    
    objetosLugares = [[NSMutableArray alloc]init];
    
    _viewLista.hidden = YES;
    _viewMapa.hidden = NO;
    
    [self cargarLugares];
    
}

-(NSInteger) numberOfSectionsTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [objetosLugares count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListTableViewCell" forIndexPath:indexPath];
    
    Lugar *lugar = [objetosLugares objectAtIndex:indexPath.row];
    
    if (!cell)
        cell = [[ListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ListTableViewCell"];
    
    cell.nombre.text = lugar.nombre;
    cell.latitud.text = lugar.latitud;
    cell.longitud.text = lugar.longitud;
    [cell.imagen sd_setImageWithURL:[NSURL URLWithString:lugar.imagen]
                   placeholderImage:[UIImage imageNamed:@"user"]];
    
    return cell;
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.tablaLugares deselectRowAtIndexPath:indexPath animated:YES];
    
    Lugar * lugar = [objetosLugares objectAtIndex:indexPath.row];
    
    ViewPlaceViewController * viewPlace = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewPlaceViewController"];
    
    viewPlace.imagenStr = lugar.imagen;
    
    [self.navigationController pushViewController:viewPlace animated:YES];
    
}



-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 85;
}


-(void)cargarLugares{
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    
    NSString * internet = [self stringFromStatus:status];
    
    
    if ([internet isEqualToString:@"1"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self activarIndicador];
        });
        
        [self traerUsuarioBD];
        
        NSString *urlString = [NSString stringWithFormat:@"http://108.179.199.76/~pruebadesarrollo/node?type=place&author=%@",_idUsuario];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"GET"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        [sessionConfiguration setHTTPAdditionalHeaders:@{@"Authorization":@"Basic cmVzdF9hcGk6MTIzNDU2Nzg5"}];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
        
        [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            //NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            //NSLog(@"requestReply: %@", requestReply);
            
            NSMutableDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            
            if( error )
            {
                NSLog(@"%@", [error localizedDescription]);
            }else{
                
                NSArray * lugares = [responseDict objectForKey:@"list"];
                
                for(NSDictionary *lug in lugares){
                    
                    Lugar *lugar = [[Lugar alloc]init];
                    
                    [lugar setNombre:[lug objectForKey:@"title"]];
                    NSDictionary *fieldsLocation = [lug objectForKey:@"field_geofield"];
                    [lugar setLatitud:[fieldsLocation objectForKey:@"lat"]];
                    [lugar setLongitud:[fieldsLocation objectForKey:@"lon"]];
                    [lugar setImagen:[lug objectForKey:@"url"]];
                    
                    [objetosLugares addObject:lugar];
                    
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tablaLugares reloadData];
                    [self agregarPins];
                });
                
                
                
            }
            
            
        }] resume];

        
    }else{
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sin conexión" message:@"Sin conexión a internet no se puede registrar" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    
    
    
}

-(void) agregarPins{
    
    for (int i=0; i<[objetosLugares count]; i++) {
        
        Lugar *lugar = [objetosLugares objectAtIndex:i];
        
        MKPointAnnotation *myAnnotation = [[MKPointAnnotation alloc] init];
        myAnnotation.coordinate = CLLocationCoordinate2DMake([lugar.latitud doubleValue],[lugar.longitud doubleValue]);
        myAnnotation.title = lugar.nombre;
        
        NSLog(@"url imagen: %@", lugar.imagen);
        
        [self.mapView addAnnotation:myAnnotation];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mapView showAnnotations:_mapView.annotations animated:YES];
        [self desactivarIndicador];
    });
    
    
    
}

- (IBAction)btnVista:(id)sender {
    
    if([sender isOn]){
        NSLog(@"Switch is ON");
        _viewLista.hidden = YES;
        _viewMapa.hidden = NO;
    } else{
        NSLog(@"Switch is OFF");
        _viewLista.hidden = NO;
        _viewMapa.hidden = YES;
    }
    
}

-(void)crearDB{
    
    //--------------------BD---------------------------------
    
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = dirPaths[0];
    
    // Build the path to the database file
    _databasePath = [[NSString alloc]
                     initWithString: [docsDir stringByAppendingPathComponent:
                                      @"sainetDB.sqlite"]];
    
    NSLog(@"ruta %@",_databasePath);
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: _databasePath ] == NO)
    {
        const char *dbpath = [_databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &_sainetDB) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt =
            "CREATE TABLE IF NOT EXISTS usuario (id INTEGER PRIMARY KEY AUTOINCREMENT, idUsuario TEXT,nombre TEXT,correo TEXT)";
            
            
            if (sqlite3_exec(_sainetDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create table");
            }
            
            sqlite3_close(_sainetDB);
        } else {
            NSLog(@"Failed to open/create database");
        }
    }
    
}


- (void) traerUsuarioBD{
    
    [self crearDB];
    
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt    *statement;
    
    if (sqlite3_open(dbpath, &_sainetDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM usuario"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_sainetDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
               
                _idUsuario = [[NSString alloc]
                              initWithUTF8String:
                              (const char *) sqlite3_column_text(
                                                                 statement, 1)];
                NSLog(@"info de la bd local: %@",_idUsuario);
                
                
                NSLog( @"Match found");
            } else {
                NSLog( @"Match not found");
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(_sainetDB);
    }
}

- (NSString *)stringFromStatus:(NetworkStatus) status {
    
    NSString *string;
    switch(status) {
        case NotReachable:
            //Sin conexion.
            string = @"0";
            break;
        case ReachableViaWiFi:
            // Conexion WIFI
            string = @"1";
            break;
        case ReachableViaWWAN:
            // Conexion 3g o 4g
            string = @"1";
            break;
        default:
            string = @"0";
            break;
    }
    return string;
}



-(void)activarIndicador{
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.detailsLabelText = @"Cargando...";
    [self.view addSubview:HUD];
    [HUD show:YES];
    
}
-(void)desactivarIndicador{
    [HUD hide:YES];
}

@end
