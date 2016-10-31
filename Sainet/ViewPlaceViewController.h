//
//  ViewPlaceViewController.h
//  Sainet
//
//  Created by Santiago Rodriguez on 31/10/16.
//  Copyright © 2016 Santiago Rodriguez. All rights reserved.
//

#import "ViewController.h"

@interface ViewPlaceViewController : ViewController<UIScrollViewDelegate>

@property (nonatomic,strong) NSString *imagenStr;
@property (weak, nonatomic) IBOutlet UIImageView *imagen;
@property (weak, nonatomic) IBOutlet UIScrollView *scrool;

- (IBAction)botonVolver:(id)sender;

@end
