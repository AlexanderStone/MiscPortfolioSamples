//
//  MotionSensingViewController.m
//  WIRC_SDK
//
//  Created by Alex Stone on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MotionSensingViewController.h"
#import "MotionProcessor.h"
#import "WiRCExampleViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreMotion/CoreMotion.h>
#import "VehicleController.h"

enum MotionDirectionEnum {
    kMotionForward,
    kMotionBackward,
    kMotionStopped
    };

@interface MotionSensingViewController ()

@end

@implementation MotionSensingViewController
@synthesize channel2Label;
@synthesize bladeTiltSlider;
@synthesize cameraFeed;
@synthesize channel1Label;
//@synthesize wircController;
@synthesize xSlider;
@synthesize ySlider;
@synthesize zSlider;
@synthesize demoLabel;
@synthesize motionProcessor;
@synthesize connectionSwitch;
@synthesize pan;
@synthesize tilt;
@synthesize vehicleController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#define kThreshold 0.15
#define speedMax 250
-(void)updateMotionControl:(id)sender
{
//      CMQuaternion quaternion = self.motionProcessor.motionManager.deviceMotion.attitude.quaternion;
//    
//    self.xSlider.value = quaternion.x;
//    self.ySlider.value = quaternion.y;
//    self.zSlider.value = quaternion.z;

    CMAttitude* attitude = self.motionProcessor.motionManager.deviceMotion.attitude;
    self.xSlider.value= attitude.roll;//sideways left right motion  
    self.ySlider.value= attitude.yaw;//clockwise rotation from portrait orientation
    self.zSlider.value =-attitude.pitch;//up/down
    
    
    if(self.connectionSwitch.on)
    {
//        [self.connectionSwitch setOn:YES animated:YES];
        
        //left/right while maintaining the direction of movement

        
        //forward /backwards
        if(fabsf(self.zSlider.value)>kThreshold)
        {
            if(self.zSlider.value>kThreshold)
            {
                //tilting the device forward
                leftTrackPitchSpeed = self.zSlider.value*speedMax;
                rightTrackPitchSpeed = leftTrackPitchSpeed;
                motionDirection = kMotionForward;
                
            }else if (self.zSlider.value<-kThreshold) {
                //moving backwards
                leftTrackPitchSpeed = self.zSlider.value*speedMax;
                rightTrackPitchSpeed = leftTrackPitchSpeed;
                 motionDirection = kMotionBackward;
                
            }
        }else {
            leftTrackPitchSpeed = 0;
            rightTrackPitchSpeed = 0;
            motionDirection = kMotionStopped;
        }
        
        
        if(self.xSlider.value>kThreshold)
        {
#warning account for the directin of movement - reverse for backwards
            //tilting the device to the right moves the tracked platform to the right by applying more power to the left thread
            
            if(motionDirection == kMotionForward)
            {
            leftTrackRollSpeed = self.xSlider.value*speedMax;
           
            }else {
                leftTrackRollSpeed = -self.xSlider.value*speedMax;
                
            }
            rightTrackRollSpeed = -leftTrackRollSpeed;
            
        }else if(self.xSlider.value< -kThreshold) {
            
            
            
            if(motionDirection == kMotionForward)
            {
                rightTrackRollSpeed = -self.xSlider.value*speedMax;
                
            }else {
                rightTrackRollSpeed = self.xSlider.value*speedMax;
                
            }
        
            leftTrackRollSpeed = -rightTrackRollSpeed;
        }else {
            leftTrackRollSpeed = 0;
            rightTrackRollSpeed = 0;
        }
        
        if(fabsf(self.ySlider.value)>kThreshold)
        {//rotation in place
            
            
        }
        
        float temp = 1525+leftTrackPitchSpeed+leftTrackRollSpeed+leftTrackYawSpeed;
        
        if(previousCh1Value>1600&& temp<1500)
        {
            //from forward to reverse, shift to neutral, otherwise all negative signals will be interpreted as breaking
//            temp = 1525;
        }
        [self.vehicleController.wirc setChannel:1 withValue:temp];
        previousCh1Value = temp;
        
        
        
        temp = 1525+rightTrackPitchSpeed+rightTrackRollSpeed+rightTrackYawSpeed;
        if(previousCh1Value>1600&& temp<1500)
        {
            //from forward to reverse, shift to neutral, otherwise all negative signals will be interpreted as breaking
//            temp = 1525;
        }
        [self.vehicleController.wirc setChannel:2 withValue:temp];
        previousCh2Value = temp;

        self.channel1Label.text = [NSString stringWithFormat:@"%.0f",previousCh1Value];
          self.channel2Label.text = [NSString stringWithFormat:@"%.0f",previousCh2Value];

    }else {
//         [self.connectionSwitch setOn:NO animated:YES];
    }
    
       self.demoLabel.text = [NSString stringWithFormat:@"x %.2f,y %.2f,z %.2f,",self.xSlider.value,self.ySlider.value,self.zSlider.value];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    self.ySlider.transform = CGAffineTransformMakeRotation(-M_PI/4.0);
    self.zSlider.transform = CGAffineTransformMakeRotation(M_PI/2.0);
    
    self.tilt.transform=CGAffineTransformMakeRotation(M_PI/2.0);
     self.bladeTiltSlider.transform=CGAffineTransformMakeRotation(M_PI/2.0);
    self.motionProcessor = [[MotionProcessor alloc] init];
    [self.motionProcessor start];
    
    self.vehicleController = [VehicleController sharedInstance];
    self.vehicleController.delegate = self;
    
//    self.vehicleController.wircController = [[WiRCExampleViewController alloc] initWithNibName:@"WiRCExampleViewController" bundle:nil];
//    self.vehicleController.wircController.delegate = self;
//    [self.view addSubview:self.vehicleController.wircController.view];
//    [self.vehicleController.wircController.view removeFromSuperview];
//    
//    
//    [self.motionProcessor start];
    
    
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(updateMotionControl:)  userInfo:nil repeats:YES    ];
    
    
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setXSlider:nil];
    [self setYSlider:nil];
    
    [self setZSlider:nil];
    [self setDemoLabel:nil];
    [self setConnectionSwitch:nil];
    [self setPan:nil];
    [self setTilt:nil];
    [self setCameraFeed:nil];
    [self setChannel1Label:nil];
    [self setChannel2Label:nil];
    [self setBladeTiltSlider:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)handlePan:(id)sender {
    
    
    [self.vehicleController.wirc setChannel:kPanChannel withValue:pan.value];
   }

- (IBAction)handleBladeTilt:(id)sender {
    NSLog(@"blade tilt: %.0f",bladeTiltSlider.value);
    [self.vehicleController.wirc setChannel:kBladeTiltChannel withValue:bladeTiltSlider.value];

}

- (IBAction)handleTilt:(id)sender {
    [self.vehicleController.wirc setChannel:kTiltChannel withValue:tilt.value];

}

-(void)updateScreenWithImage:(UIImage*)image
{
    self.cameraFeed.image = image;
}
-(void)didReceivedCameraFrameNum:(uint32_t)frameNum withImage:(UIImage *)image
{
    [self performSelectorOnMainThread:@selector(updateScreenWithImage:) withObject:image waitUntilDone:NO];
}
@end
