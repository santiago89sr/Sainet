//
//  ViewController.m
//  Sainet
//
//  Created by Santiago Rodriguez on 29/10/16.
//  Copyright © 2016 Santiago Rodriguez. All rights reserved.
//

#import "ViewController.h"
#import "LogInViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _correo.delegate = self;
    _correo2.delegate = self;
    _pass.delegate = self;
    _pass2.delegate = self;
    
    
    [self requestToken];
}
//qIymIypq59dbOwgzC_ppSbHgoid1wUdK4NtqQTv9KHQ

//TOKEN VIEJO ---- H5HUS9NmuwQ62iYQsvvQ67rS4D3arGKMKls3c0kWoPU

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    return YES;
}

-(void)requestToken{
    
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
        
        
    }] resume];
    
    
    
}

-(void)manualSignUp{
    
    if(_correo.text.length>0 && _correo2.text.length>0 && _pass.text.length>0 && _pass2.text.length>0){
        
        if([_correo.text isEqualToString:_correo2.text]){
            
            if([_pass.text isEqualToString:_pass2.text]){
                
                dispatch_async(dispatch_get_main_queue(),^{
                    [self activarIndicador];
                });
                
                NSDictionary *post = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      _correo.text, @"name",
                                      _pass.text, @"pass",
                                      _correo.text, @"mail",
                                      _correo.text, @"init",
                                      @"authenticated user", @"roles",
                                      @"1", @"status",
                                      nil];
                
                
                
                NSError *error;
                NSData *postData = [NSJSONSerialization dataWithJSONObject:post options:0 error:&error];
                NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                [request setURL:[NSURL URLWithString:@"http://108.179.199.76/~pruebadesarrollo/user"]];
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
                        
                        _nombre = _correo.text;
                        _email = _correo.text;
                        _uid = idNew;
                        
                        [self crearDB];
                        [self guardarDataLocal];
                        
                        dispatch_async(dispatch_get_main_queue(),^{
                            [self desactivarIndicador];
                        });
                        
                        [self performSegueWithIdentifier:@"home" sender:self];
                        
                    }
                    
                    
                    
                }] resume];
                
                
                
            }else{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Las contraseñas no son iguales." preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                    [alertController addAction:ok];
                    
                    [self presentViewController:alertController animated:YES completion:nil];
                    
                });
                
            }
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Los correos no son iguales." preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:ok];
                
                [self presentViewController:alertController animated:YES completion:nil];
                
            });
            
        }

        
    }else{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Hay campos vacios." preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
        });
        
    }
    
    
    
    
}


- (IBAction)botonRegistro:(id)sender {
    
    
    
    [self manualSignUp];
    
}

- (IBAction)botonIniciarSesion:(id)sender {
    
    LogInViewController * logIn = [self.storyboard instantiateViewControllerWithIdentifier:@"LogInViewController"];
    
    [self.navigationController pushViewController:logIn animated:YES];
    
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

                 _nombre = [result objectForKey:@"first_name"];
                 _apellido = [result objectForKey:@"last_name"];
                 _email = [result objectForKey:@"email"];
                 _fbId = [result objectForKey:@"id"];
//                 NSString *imageUsuarioURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", idFB];
                 
                 [self registroFB];
                 
                 
                 
                 
                 
             }else{
                 NSLog(@"error: %@",error);
             }
         }];
    }
    
}

-(void)registroFB{
    
    NSDictionary *dataFB = [[NSDictionary alloc]initWithObjectsAndKeys:
                            _fbId,@"identifier",
                            _email,@"username",
                            _email,@"displayName",
                            _nombre,@"firstName",
                            _apellido,@"lastName",
                            @"",@"gender",
                            @"es",@"language",
                            @"descripcion",@"description",
                            _email,@"email",
                            _email,@"emailVerified",
                            @"BOG-CO",@"region",
                            @"bogota",@"city",
                            @"colombia",@"country",
                            @"",@"birthDay",
                            @"",@"birthMonth",
                            @"",@"birthYear",
                            @"123456789",@"token",
                            nil];
    
    NSDictionary *post = [[NSDictionary alloc] initWithObjectsAndKeys:
                          _nombre, @"name",
                          @"", @"pass",
                          _email, @"mail",
                          _email, @"init",
                          @"authenticated user", @"roles",
                          @"1", @"status",
                          dataFB,@"data",
                          nil];
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:post options:0 error:&error];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://108.179.199.76/~pruebadesarrollo/user"]];
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
            
            _uid = idNew;
            
            [self crearDB];
            [self guardarDataLocal];
            
            dispatch_async(dispatch_get_main_queue(),^{
                [self desactivarIndicador];
            });
            
            [self performSegueWithIdentifier:@"home" sender:self];
            
        }
        
        
        
    }] resume];
    
                
    
    

    
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
        
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO usuario (idUsuario,nombre, correo) VALUES (\"%@\",\"%@\",\"%@\")",_uid ,_nombre,_email];
        
        
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
