//
//  PseudoBindingDispatcher.j
//  soma_cappuccino
//
//  Created by David Cox on 6/4/09.
//  Copyright Harvard University 2009. All rights reserved.
//

@import <Foundation/CPObject.j>

// An object that clumsily binds together server side ajax "properties"
// with fields and buttons

@implementation
AjaxPropertyDispatcher : CPObject
{
  
  CPMutableDictionary property_field_table;  // property (string) -> array[ field (control), .. ]
  
  CPMutableDictionary trigger_table;    // trigger (control) -> [field, property (string)]
  
  var heartbeat_interval;
  CPString base_url;
  CPTimer timer;
}


- (id) initWithBaseURL:(CPString)url heartbeatInterval:(id)interval {
  property_field_table = [[CPMutableDictionary alloc] init];
  trigger_table = [[CPMutableDictionary alloc] init];
  heartbeat_interval = interval;
  base_url = url;
  return self;
}


- (void)start {
  timer = [CPTimer scheduledTimerWithTimeInterval:heartbeat_interval target:self selector:@selector(updateProperties) userInfo:Nil repeats:YES];
  [timer fire];
}

- (void)stop {
  [timer invalidate];
}


- (void)trigger:(id)sender {

  var property_field_pair = [trigger_table valueForKey:sender];
  
  var property = [property_field_pair objectAtIndex:0];
  var field = [property_field_pair objectAtIndex:1];
  
  var value = [field stringValue];
  [self setValue:value forAjaxProperty:property];
}

- (void)associateProperty:(CPString)property withField:(CPControl)field trigger:(CPControl) trig {
  if(trig != Nil){
    [trig setTarget:self];
    [trig setAction:@selector(trigger:)];
    
    var propfield = [[CPArray alloc] initWithCapacity:2];
    [propfield addObject:property];
    [propfield addObject:field];
    [trigger_property_table setValue:propfield forKey:trig];
  }
  
  var fields = [property_field_table objectForKey:property];
  if(fields == Nil){
    fields = [[CPMutableArray alloc] init];
  }
  
  [fields addObject:field];
  [property_field_table setValue:fields forKey:property]; // is this needed?
  
}


- (void)updateProperties {
  //debugger;
  var key_enumerator = [property_field_table keyEnumerator];
  var prop = Nil;
  while(prop = [key_enumerator nextObject]){
    var value = [self valueForAjaxProperty:prop];
    var fields = [property_field_table valueForKey:prop];
    var field_enumerator = [fields objectEnumerator];
    var field = Nil;
    while(field = [field_enumerator nextObject]){
      if([[field stringValue] compare:value]){
        [field setStringValue:value];
        [field setNeedsDisplay:YES];
      }
    }
  }
}


- (void)valueForAjaxProperty:(CPString) property
{
  //debugger;
  var url = [CPURLRequest requestWithURL:(base_url + "/config/property/" + property)];
  var callback = @"jsoncallback";
  var connection = [CPJSONPConnection sendRequest:url  callback:callback  delegate:self];
}

- (void)setValue:(CPString)value forAjaxProperty:(CPString) property
{
  //debugger;
  var url = [CPURLRequest requestWithURL:(base_url + "/config/property/" + property + "=" + value)];
  var callback = @"jsoncallback";
  var connection = [CPJSONPConnection sendRequest:url  callback:callback  delegate:self];
}

-(void)connection:(id)connection didFailWithError:(id)error{
  alert(@"An error occurred");
}

-(void)connection:(CPURLConnection)connection didReceiveData:(id)data{
  var property = data.property;
  var value = data.value;
  
  var fields = [property_field_table valueForKey:property];
  var field_enumerator = [fields objectEnumerator];
  var field = Nil; 
  while(field = [field_enumerator nextObject]){
    [field setStringValue:value];
  }
}


@end
