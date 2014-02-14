//
//  MotionSensingViewController.h
//  WIRC_SDK
//
//  Created by Alex Stone on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WiRC.h"
//@class WiRCExampleViewController;
@class MotionProcessor;
@class VehicleController;

@interface MotionSensingViewController : UIViewController<WiRCDelegate>

{
    NSTimer* updateTimer;
    
    float leftTrackPitchSpeed;
    float leftTrackRollSpeed;
    float leftTrackYawSpeed;
    
    float rightTrackPitchSpeed;
    float rightTrackRollSpeed;
    float rightTrackYawSpeed;
    
    float previousCh1Value;
    float previousCh2Value;
    int motionDirection;
}
@property(nonatomic,strong)MotionProcessor* motionProcessor;
@property(nonatomic,strong)VehicleController* vehicleController;

//@property(nonatomic,strong)WiRCExampleViewController* wircController;

@property ( weak, nonatomic) IBOutlet UISlider *xSlider;
@property ( weak, nonatomic) IBOutlet UISlider *ySlider;
@property ( weak, nonatomic) IBOutlet UISlider *zSlider;
@property (weak, nonatomic) IBOutlet UILabel *demoLabel;
@property (weak, nonatomic) IBOutlet UISwitch *connectionSwitch;

@property (weak, nonatomic) IBOutlet UISlider *pan;
@property (weak, nonatomic) IBOutlet UISlider *tilt;
- (IBAction)handlePan:(id)sender;



- (IBAction)handleTilt:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *cameraFeed;
@property (weak, nonatomic) IBOutlet UILabel *channel1Label;
@property (weak, nonatomic) IBOutlet UILabel *channel2Label;
@property (weak, nonatomic) IBOutlet UISlider *bladeTiltSlider;
- (IBAction)handleBladeTilt:(id)sender;
@end
