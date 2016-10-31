//
//  MenuViewController.m
//  Sainet
//
//  Created by Santiago Rodriguez on 30/10/16.
//  Copyright © 2016 Santiago Rodriguez. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    menu = [[NSArray alloc]initWithObjects:@"crear",@"lugares",@"cerrar", nil];
    
}

-(NSInteger) numberOfSectionsTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [menu count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *cellIdentifier = [menu objectAtIndex:indexPath.row];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    return cell;
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue isKindOfClass:[SWRevealViewControllerSegue class]]){
        
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue*)segue;
        swSegue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController*svc,UIViewController* dvc){
            
            UINavigationController * navController = (UINavigationController*)self.revealViewController.frontViewController;
            
            [navController setViewControllers:@[dvc] animated:NO];
            
            [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];
            
            
        };
    }
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
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

-(void)cerrarSesion{
    
    [self crearDB];
    
    sqlite3_stmt    *statement;
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_sainetDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:@"DELETE FROM usuario"];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(_sainetDB, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog( @"Se borro info");
            [self performSegueWithIdentifier:@"cerrarSesion" sender:self];
        } else {
            NSLog( @"Fallo borrar info bd");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_sainetDB);
    }
    
    
    
}

- (IBAction)botonCerrarSesion:(id)sender {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Cerrar Sesión"
                                      message:@"¿Está seguro de cerrar su sesión?"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"Salir"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 [self cerrarSesion];
                                 
                             }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Cancelar"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
        
        [alert addAction:ok];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        
    });

    
}
@end
