//
//  StatusController.j
//  soma_cappuccino
//
//  Created by David Cox on 6/4/09.
//  Copyright Harvard University 2009. All rights reserved.
//

@import <Foundation/CPObject.j>
@import <AjaxPropertyDispatcher.j>

@implementation StatusController : CPObject
{
  AjaxPropertyDispatcher property_dispatcher;
  
  CPTextField os_version_field;
  CPTextField uptime_field;
  
  CPTextField somanetwork_version_field;
  CPTextField somadspio_version_field;
  CPTextField recorder_version_field;
  
  CPTextField disk_free_space_field;
  
  CPView      status_banner_view;
}


- (void)awakeFromCib {

  [os_version_field setStringValue:@"pending..."];

  property_dispatcher = [[AjaxPropertyDispatcher alloc] initWithBaseURL:@"http://127.0.0.1:8000/config/property" heartbeatInterval:1000];
  
  // Bind together UI and backend properties
  [property_dispatcher associateProperty:"os_version" withField:os_version_field trigger:Nil];
  [property_dispatcher associateProperty:"uptime" withField:uptime_field trigger:Nil];
  [property_dispatcher associateProperty:"somanetwork_version" withField:somanetwork_version_field trigger:Nil];
  [property_dispatcher associateProperty:"somadspio_version" withField:somadspio_version_field trigger:Nil];
  [property_dispatcher associateProperty:"recorder_version" withField:recorder_version_field trigger:Nil];
  [property_dispatcher associateProperty:"disk_free_space" withField:disk_free_space_field trigger:Nil];
  
  [property_dispatcher start];
  
  [status_banner_view setBackgroundColor:[CPColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.75]];
  [status_banner_view setNeedsDisplay:YES];
}

- (void) updateProperties:(id)sender {
  [property_dispatcher updateProperties];
}


@end
