//
//  NewPlaceViewController.m
//  Sainet
//
//  Created by Santiago Rodriguez on 30/10/16.
//  Copyright © 2016 Santiago Rodriguez. All rights reserved.
//

#import "NewPlaceViewController.h"
#import "SWRevealViewController.h"

@interface NewPlaceViewController ()

@end

@implementation NewPlaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [locationManager requestWhenInUseAuthorization];
    
    [locationManager startUpdatingLocation];
    
    [self.botonMenu addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    
    self.image.layer.cornerRadius = 82.0;
    self.image.layer.masksToBounds = YES;
    
    self.image.userInteractionEnabled = YES;
    
    _nombreLugar.delegate = self;
    
    UITapGestureRecognizer *addImageProfile = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(fotoUsuario)];
    addImageProfile.delegate = self;
    [self.image addGestureRecognizer:addImageProfile];
    
    [self traerUsuarioBD];
    
    
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    return YES;
}

-(void)fotoUsuario{
    
    NSLog(@"tap!");
    
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"SELECCIONA" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancelar" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        //        [self dismissViewControllerAnimated:YES completion:^{
        //        }];
    }]];
    
    
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cámara" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:NULL];
        
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Biblioteca" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:NULL];
        
        
        
    }]];
    
    UIPopoverPresentationController *popController = [actionSheet popoverPresentationController];
    popController.sourceView = self.view;
    popController.sourceRect = self.self.image.frame;
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    
    if(info){
        
        UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
        self.image.image = chosenImage;
        
        [picker dismissViewControllerAnimated:YES completion:NULL];
        
    }
    
    
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Error al obtener su ubicación." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    });
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        _longitud = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        _latitud = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    }
}

- (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

-(void)requestToken{
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    
    NSString * internet = [self stringFromStatus:status];
    
    
    if ([internet isEqualToString:@"1"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self activarIndicador];
        });
        
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:@"http://108.179.199.76/~pruebadesarrollo/restws/session/token"]];
        [request setHTTPMethod:@"GET"];
        
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        [sessionConfiguration setHTTPAdditionalHeaders:@{@"Authorization":@"Basic cmVzdF9hcGk6MTIzNDU2Nzg5"}];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
        
        [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            NSLog(@"requestReply: %@", requestReply);
            _token = requestReply;
            
            if( error )
            {
                NSLog(@"%@", [error localizedDescription]);
            }
            
            [self savePlace];
            
            
        }] resume];

        
        
    }else{
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sin conexión" message:@"Sin conexión a internet no se puede registrar" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    
    
    
    
}

-(void)savePlace{
    
    if(_nombreLugar.text.length>0){
        
        NSString *base64 = [NSString stringWithFormat:@"data:image/png;base64,%@",[self encodeToBase64String:_image.image]];
        
        NSDictionary *post = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @"place", @"type",
                              _nombreLugar.text, @"title",
                              base64, @"field_image",
                              _idUsuario, @"uid",
                              _latitud, @"lat",
                              _longitud, @"lon",
                              nil];
        NSError *error;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:post options:0 error:&error];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:@"http://108.179.199.76/~pruebadesarrollo/node"]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setHTTPBody:postData];
        
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        [sessionConfiguration setHTTPAdditionalHeaders:@{@"Authorization":@"Basic cmVzdF9hcGk6MTIzNDU2Nzg5"}];
        [sessionConfiguration setHTTPAdditionalHeaders:@{@"x-CSRF-Token":_token}];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
        
        [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            NSLog(@"requestReply Registro: %@", requestReply);
            
            NSMutableDictionary *responseDict = [NSJSONSerialization
                                                 JSONObjectWithData:data
                                                 options:NSJSONReadingMutableContainers
                                                 error:&error];
            if( error )
            {
                NSLog(@"Este es el errror: %@", [error localizedDescription]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self desactivarIndicador];
                    
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:requestReply preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                    [alertController addAction:ok];
                    
                    [self presentViewController:alertController animated:YES completion:nil];
                    
                });
            }
            else {
                
                NSString *uri = [responseDict objectForKey:@"uri"];
                
                NSString *idNew = [responseDict objectForKey:@"id"];
                NSString *resource = [responseDict objectForKey:@"resource"];
                
                NSLog(@"datos devueltos: uri: %@ idNew: %@ resource: %@",uri,idNew,resource);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self desactivarIndicador];
                    
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"¡Lugar guardado!" message:@"Se ha guardado el lugar correctamente." preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                    [alertController addAction:ok];
                    
                    [self presentViewController:alertController animated:YES completion:nil];
                    
                });

                
            }
            
            
            
        }] resume];
        
        
        
    }else{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Hay campos vacios." preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
        });
        
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



- (IBAction)botonGuardarLugar:(id)sender {
    
    [self requestToken];
    
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
