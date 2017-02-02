//
//  ViewController.h
//  Led_Proj
//
//  Created by Simon Persson on 2017-01-19.
//  Copyright © 2017 Simon Persson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SystemConfiguration/CaptiveNetwork.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface ViewController : UIViewController <NSStreamDelegate, UIAlertViewDelegate> {
    IBOutlet UIImageView *smiley;
}

@property (nonatomic, retain) NSInputStream *inputStream;
@property (nonatomic, retain) NSOutputStream *outputStream;
@property (weak, nonatomic) IBOutlet UISegmentedControl *lightToggle;

- (IBAction)toggleLight:(id)sender;
- (IBAction)refreshConnection:(id)sender;
- (void)handleSwitchColor;

@end

