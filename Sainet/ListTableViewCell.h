//
//  ListTableViewCell.h
//  Sainet
//
//  Created by Santiago Rodriguez on 29/10/16.
//  Copyright © 2016 Santiago Rodriguez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imagen;
@property (weak, nonatomic) IBOutlet UILabel *nombre;
@property (weak, nonatomic) IBOutlet UILabel *latitud;
@property (weak, nonatomic) IBOutlet UILabel *longitud;
@end
