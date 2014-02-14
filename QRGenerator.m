//
//  QRGenerator.m
//  glamourAR
//
//  Created by Alexander Stone on 4/11/12.
//  Copyright (c) 2012 Singularity Tech. All rights reserved.
//

#import "QRGenerator.h"

#define kGoogleChartWebsite @"https://chart.googleapis.com"

@implementation QRGenerator
@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        RKClient* client = [RKClient clientWithBaseURL:kGoogleChartWebsite];
        [RKClient setSharedClient:client];
        
        // Ask RestKit to spin the network activity indicator for us
        [RKRequestQueue sharedQueue].delegate = self;
        [RKRequestQueue sharedQueue].showsNetworkActivityIndicatorWhenBusy = YES;
    }
    return self;
}

-(void)askForQR
{
    
    NSString* url = @"chart?cht=qr&chl=http://www.luciddreamingapp.com&chld=h&chs=120x120";
    RKRequest* request = [[RKClient sharedClient] get:url queryParams:nil delegate:self];
    NSLog(@"request: %@",[request.URL absoluteString]);
    request.delegate = self; 
}
-(void)processResponse:(RKResponse*)response
{
    
    
//    NSLog(@"%@", response.body);
    NSLog(@"content type: %@",response.contentType);
    NSLog(@"request: %@",[response.request.URL absoluteString]);
    if([response.contentType isEqualToString:@"image/png"])
    {
        UIImage* image = [UIImage imageWithData:response.body];
        [self.delegate qRGenerator:self didLoadImage:image];
    }
    
    
    
    
}
#pragma mark -
#pragma mark RKRequestQueue delegate

-(void)requestQueue:(RKRequestQueue *)queue didLoadResponse:(RKResponse *)response
{
    [self processResponse:response];
}

- (void)requestQueue:(RKRequestQueue *)queue didSendRequest:(RKRequest *)request {
    NSLog(@"%@",[NSString stringWithFormat:@"RKRequestQueue %@ sharedQueue is current loading %d of %d requests", 
                 queue, [queue loadingCount], [queue count]]);
}

- (void)requestQueueDidBeginLoading:(RKRequestQueue *)queue {
    NSLog(@"%@",[NSString stringWithFormat:@"Queue %@ Began Loading...", queue]);
}

- (void)requestQueueDidFinishLoading:(RKRequestQueue *)queue {
    NSLog(@"%@", [NSString stringWithFormat:@"Queue %@ Finished Loading...", queue]);
}




@end
