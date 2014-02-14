//
//  QRGenerator.h
//  glamourAR
//
//  Created by Alexander Stone on 4/11/12.
//  Copyright (c) 2012 Singularity Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
@class QRGenerator;

@protocol QRGeneratorDelegate <NSObject>

-(void)qRGenerator:(QRGenerator*)generator didLoadImage:(UIImage*)image;

@end

@interface QRGenerator : NSObject<RKRequestQueueDelegate, RKRequestDelegate>

@property(nonatomic,strong)id<QRGeneratorDelegate> delegate;
-(void)askForQR;

@end
