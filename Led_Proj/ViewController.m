//
//  ViewController.m
//  Led_Proj
//
//  Created by Simon Persson on 2017-01-19.
//  Copyright © 2017 Simon Persson. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (IBAction)toggleLight:(id)sender {
    long tag = _lightToggle.tag;
    
    NSString *response  = [NSString stringWithFormat:@"P%ld%@", tag , _lightToggle.selectedSegmentIndex?@"L" : @"H"];
    NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
    [_outputStream write:[data bytes] maxLength:[data length]];
}

- (void)initNetworkCommunication {
    //Checks which network the user is connected to.
    CFArrayRef myArray = CNCopySupportedInterfaces();
    CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
    NSLog(@"Connected at: %@", myDict);
    NSDictionary *myDictionary = (__bridge_transfer NSDictionary*)myDict;
    NSString *BSSID = [myDictionary objectForKey:@"BSSID"];
    NSLog(@"BSSID is: %@", BSSID);
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"193.11.184.163", 7777, &readStream, &writeStream);
    _inputStream = (NSInputStream *)CFBridgingRelease(readStream);
    _outputStream = (NSOutputStream *)CFBridgingRelease(writeStream);
    
    [_inputStream setDelegate:self];
    [_outputStream setDelegate:self];
    
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [_inputStream open];
    [_outputStream open];
    
    //Handling wrong/correct BSSID.
    if (![BSSID isEqualToString:@"8:1f:f3:b3:4d:ac"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't connect..." message:@"Make sure you're connected to the correct network (eduroam)." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
        
        NSLog(@"Error in connection.");
        _lightToggle.userInteractionEnabled = NO;
        [[_lightToggle.subviews objectAtIndex:0] setTintColor:[UIColor lightGrayColor]];
        _lightToggle.selectedSegmentIndex = 0;
        smiley.image = [UIImage imageNamed:@"Sad.png"];
    }
    else {
        NSLog(@"Connection successful.");
        _lightToggle.userInteractionEnabled = YES;
        [[_lightToggle.subviews objectAtIndex:0] setTintColor:UIColorFromRGB(0x43A52D)];
        smiley.image = [UIImage imageNamed:@"Happy.png"];
    }
}

/*- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0){
        //Handle click here.
        }
    }
*/
 
- (IBAction)refreshConnection:(id)sender {
    [self initNetworkCommunication];
}

- (void)handleSwitchColor {
    for (int i=0; i<[_lightToggle.subviews count]; i++)
    {
        if ([[_lightToggle.subviews objectAtIndex:i]isSelected] )
        {
            [[_lightToggle.subviews objectAtIndex:i] setTintColor:UIColorFromRGB(0xFF0000)];
        }else{
            [[_lightToggle.subviews objectAtIndex:i] setTintColor:UIColorFromRGB(0x43A52D)];
        }
    }
}

- (void)applicationEnteredForeground:(NSNotification *)notification {
    [self initNetworkCommunication];
}

- (void)viewDidLoad {
    _lightToggle.selectedSegmentIndex = 0;
    [self handleSwitchColor];
    [self initNetworkCommunication];
    
    [[UISegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Aero Matics Light" size:14.0], NSFontAttributeName, nil] forState:UIControlStateNormal];
        
    //Used so that when you minimize the app it inits the network again.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationEnteredForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
