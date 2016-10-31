//
//  LogInViewController.m
//  Sainet
//
//  Created by Santiago Rodriguez on 30/10/16.
//  Copyright © 2016 Santiago Rodriguez. All rights reserved.
//

#import "LogInViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "Usuario.h"

@interface LogInViewController ()

@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    objetosUsuario = [[NSMutableArray alloc]init];
    
    _correo.delegate = self;
    _pass.delegate = self;
    
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    return YES;
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
            
            [self manualLogIn];
            
        }] resume];
        
    }else{
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sin conexión" message:@"Sin conexión a internet no se puede registrar" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }

    
    
    
    
    
}

-(void)manualLogIn{
    
    if(_correo.text.length>0 && _pass.text.length>0){
        
        NSDictionary *post = [[NSDictionary alloc] initWithObjectsAndKeys:
                              _correo.text, @"username",
                              _pass.text, @"password",
                              nil];
        NSError *error;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:post options:0 error:&error];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:@"http://108.179.199.76/~pruebadesarrollo/app_login"]];
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
                
                NSString *message = [responseDict objectForKey:@"message"];
                
                if([message isEqualToString:@"User logged successfully"]){
                    NSDictionary *user = [responseDict objectForKey:@"user"];
                    
                    _uid = [user objectForKey:@"uid"];
                    _name = [user objectForKey:@"name"];
                    _email = [user objectForKey:@"mail"];
                    
                    NSLog(@"datos devueltos: uid: %@ name: %@ mail: %@",_uid,_name,_email);
                    
                    [self crearDB];
                    [self guardarDataLocal];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self desactivarIndicador];
                    });
                    
                    [self performSegueWithIdentifier:@"home" sender:self];
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self desactivarIndicador];
                        
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:message preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                        [alertController addAction:ok];
                        
                        [self presentViewController:alertController animated:YES completion:nil];
                        
                    });
                }
                
                
                
            }
            
            
            
        }] resume];
        
        
    }else{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self desactivarIndicador];
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Hay campos vacios." preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
        });
        
    }
    
    
    
    
}
//Crear o abrir BD.
-(void)crearDB{
    

    
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

-(void)guardarDataLocal{
    
    sqlite3_stmt *statement;
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_sainetDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO usuario (idUsuario,nombre, correo) VALUES (\"%@\",\"%@\",\"%@\")",_uid ,_name,_email];
        
        
        const char *insert_stmt = [insertSQL UTF8String];
        
        sqlite3_prepare_v2(_sainetDB, insert_stmt,-1, &statement, NULL);
        
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog( @"Data added");
        } else {
            NSLog(@"error %s",sqlite3_errmsg(_sainetDB));
            NSLog( @"Failed to add data");
            
        }
        sqlite3_finalize(statement);
        sqlite3_close(_sainetDB);
    }
    
    
}

- (IBAction)botonVolver:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)botonIniciarSesion:(id)sender {
    
    [self requestToken];
    
}

- (IBAction)botonFB:(id)sender {

    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    
    NSString * internet = [self stringFromStatus:status];
    
    
    if ([internet isEqualToString:@"1"]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self activarIndicador];
        });
        
        NSArray *permissions = @[@"public_profile",@"email",@"user_friends"];
        
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login
         logInWithReadPermissions: permissions
         fromViewController:self
         handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
             if (error) {
                 NSLog(@"Process error: %@",error);
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self desactivarIndicador];
                 });
             } else if (result.isCancelled) {
                 NSLog(@"Cancelled");
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self desactivarIndicador];
                 });
             } else {
                 NSLog(@"Logged in");
                 NSLog(@"User logged in through Facebook!");
                 [self userDataFB];
                 
             }
         }];
        
    }else{
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sin conexión" message:@"Sin conexión a internet no se puede registrar" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    
    //----------------------------------Codigo FB Final
    
}

-(void)userDataFB{
    
    
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"first_name,last_name,email,id,birthday"forKey:@"fields"];
    
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 
                 NSLog(@"fetched user:%@", result);
                 
                 _email = [result objectForKey:@"email"];
                 //                 NSString *imageUsuarioURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", idFB];
                 
                 [self inicioSesionFB];
                 
                 
             }else{
                 NSLog(@"error: %@",error);
             }
         }];
    }
    
}

-(void)inicioSesionFB{
    
    NSString *correoEncoded = [_email stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    

    
    NSString *urlString = [NSString stringWithFormat:@"http://108.179.199.76/~pruebadesarrollo/user?mail=%@",correoEncoded];
    
    NSLog(@"urlString final: %@",urlString);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setHTTPAdditionalHeaders:@{@"Authorization":@"Basic cmVzdF9hcGk6MTIzNDU2Nzg5"}];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSLog(@"requestReply: %@", requestReply);
        
        NSMutableDictionary *responseDict = [NSJSONSerialization
                                             JSONObjectWithData:data
                                             options:NSJSONReadingMutableContainers
                                             error:&error];
        
        if( error )
        {
            NSLog(@"%@", [error localizedDescription]);
        }
        else {
            
            NSArray *listCantidad = [responseDict objectForKey:@"list"];
            
            if(listCantidad>0){
                
                for (NSDictionary *usu in listCantidad) {
                    
                    Usuario * user = [[Usuario alloc]init];
                    
                    [user setUid:[usu objectForKey:@"uid"]];
                    [user setNombre:[usu objectForKey:@"name"]];
                    [user setEmail:[usu objectForKey:@"mail"]];
                    
                    _uid = [usu objectForKey:@"uid"];
                    _email = [usu objectForKey:@"mail"];
                    _name = [usu objectForKey:@"name"];
                    
                    [objetosUsuario addObject:user];
                    
                }
                
                NSLog(@"datos devueltos sesion facebook: uid: %@ email: %@ name: %@",_uid,_email,_name);
                
                [self crearDB];
                [self guardarDataLocal];
                
                dispatch_async(dispatch_get_main_queue(),^{
                    [self desactivarIndicador];
                });
                
                [self performSegueWithIdentifier:@"home" sender:self];
                
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self desactivarIndicador];
                    
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Este correo no se encuentra registrado." preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                    [alertController addAction:ok];
                    
                    [self presentViewController:alertController animated:YES completion:nil];
                    
                });
            }
            
            
            
        }
        
        
    }] resume];
    
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
