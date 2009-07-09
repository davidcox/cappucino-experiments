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
  
  CPMutableDictionary property_callback_table;
  
  CPMutableDictionary static_property_table;
  
  CPMutableDictionary property_autoupdate_table;
  
  var heartbeat_interval;
  CPString base_url;
  CPTimer timer;
}


- (id) initWithBaseURL:(CPString)url heartbeatInterval:(id)interval {
  property_field_table = [[CPMutableDictionary alloc] init];
  trigger_table = [[CPMutableDictionary alloc] init];
  property_callback_table = [[CPMutableDictionary alloc] init];
  heartbeat_interval = interval;
  static_property_table = [[CPMutableDictionary alloc] init];
  property_autoupdate_table = [[CPMutableDictionary alloc] init];
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


- (void)restart {
  [self stop];
  [self start];
}

- (void) setValue: (id)val forStaticProperty: (CPString)prop {

  [static_property_table setValue:val forKey:prop];
}

- (id) valueForStaticProperty:(CPString) prop {
  return [static_property_table valueForKey:prop];
}

- (void)trigger:(id)sender {

  var property_field_pair = [trigger_table valueForKey:sender];
  
  var property = [property_field_pair objectAtIndex:0];
  var field = [property_field_pair objectAtIndex:1];
  
  var value = [field stringValue];
  [self setValue:value forAjaxProperty:property];
}

- (void)associateProperty:(CPString)property withField:(CPControl)field trigger:(CPControl) trig {
  [self associateProperty:property withField:field trigger:trig  updateAutomatically:YES];
}

- (void)associateProperty:(CPString)property withField:(CPControl)field trigger:(CPControl) trig  updateAutomatically:(BOOL)auto{
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
  
  [property_autoupdate_table setValue:auto forKey:property];
}

-(void)registerCallback:(SEL)selector onTarget:(id)target forProperty:(CPString)prop {
  [self registerCallback:selector onTarget:target forProperty:prop updateAutomatically:NO];
}

-(void)registerCallback:(SEL)selector onTarget:(id)target forProperty:(CPString)prop updateAutomatically:(BOOL)auto{
  
  var callback_list = [property_callback_table valueForKey:prop];
  
  if(callback_list == Nil){
    callback_list = [[CPMutableArray alloc] init];
  }
  
  [property_autoupdate_table setValue:auto forKey:prop];
  
  var callback_info = new Object;
  callback_info.selector = selector;
  callback_info.target = target;
  
  
  [callback_list addObject:callback_info];
  [property_callback_table setValue:callback_list forKey:prop];
}


- (void)updateProperties {
  
  // Run through the property/field table
  var key_enumerator = [property_field_table keyEnumerator];
  var prop = Nil;
  while(prop = [key_enumerator nextObject]){
    var auto_update = [property_autoupdate_table valueForKey:prop];
    if(auto_update){
      [self requestValueForAjaxProperty:prop];
    }
  }
  
  // run through the property/callback table
  key_enumerator = [property_callback_table keyEnumerator];
  prop = Nil;
  while(prop = [key_enumerator nextObject]){
    var auto_update = [property_autoupdate_table valueForKey:auto_update];
    if(auto_update){
      [self requestValueForAjaxProperty:prop];
    }
  }
}


- (void)requestValueForAjaxProperty:(CPString)property {

  [self requestValueForAjaxProperty:property withArguments:Nil];
}


- (void)requestValueForAjaxProperty:(CPString)property withArguments:(id)args
{
  
  var url_string = base_url + "/" + property;
  
  var key_enumerator = [static_property_table keyEnumerator];
  var key;
  var first = YES;
  while(key = [key_enumerator nextObject]){
    if(first){
      url_string += "?";
      first = NO;
    } else {
      url_string += "&";
    }
    url_string += key + "=" + [static_property_table valueForKey:key];
  }
  
  if(args != Nil){
    
    key_enumerator = [args keyEnumerator];
    while(key = [key_enumerator nextObject]){
      
      if(first){
        url_string += "?";
        first = NO;
      } else {
        url_string += "&";
      }
      url_string += (key + "=" + [args valueForKey:key]);
    }
  }

  var url = [CPURLRequest requestWithURL:url_string];
  
  var callback = @"jsoncallback";
  var connection = [CPJSONPConnection sendRequest:url  callback:callback  delegate:self];
}

- (void)setValue:(CPString)value forAjaxProperty:(CPString) property
{
  //debugger;
  var url = [CPURLRequest requestWithURL:(base_url + "/set_" + property + "?value=" + value)];
  var callback = @"jsoncallback";
  var connection = [CPJSONPConnection sendRequest:url  callback:callback  delegate:self];
}

-(void)connection:(id)connection didFailWithError:(id)error{
  //alert(@"An error occurred");
}

-(void)connection:(CPURLConnection)connection didReceiveData:(id)data{

  var property = data.property;
  var value = data.value;
  
  var fields = [property_field_table valueForKey:property];
  if(fields != Nil){
    var field_enumerator = [fields objectEnumerator];
    var field = Nil; 
    while(field = [field_enumerator nextObject]){
      [field setStringValue:value];
    }
  }

  var callbacks = [property_callback_table valueForKey:property];
  if(callbacks != Nil){
    //debugger;
    var callback;
    var callback_enumerator = [callbacks objectEnumerator];
    while(callback = [callback_enumerator nextObject]){
      selector = callback.selector;
      obj = callback.target;
      [obj performSelector:selector withObject:value];
    }
  }
}


@end
