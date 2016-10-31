//
//  ViewPlaceViewController.m
//  Sainet
//
//  Created by Santiago Rodriguez on 31/10/16.
//  Copyright © 2016 Santiago Rodriguez. All rights reserved.
//

#import "ViewPlaceViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ViewPlaceViewController ()

@end

@implementation ViewPlaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _scrool.delegate = self;
    
    [self.imagen sd_setImageWithURL:[NSURL URLWithString:_imagenStr]
                   placeholderImage:[UIImage imageNamed:@"user"]];
    
}

-(void)setContentSizeForScrollView
{
    _scrool.contentSize = CGSizeMake(_imagen.frame.size.width, _imagen.frame.size.height);
    _scrool.minimumZoomScale = 1.0;
    _scrool.maximumZoomScale = 5.0;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imagen;
}

- (IBAction)botonVolver:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
@end
