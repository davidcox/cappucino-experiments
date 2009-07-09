//
//  AppController.j
//  soma_cappuccino
//
//  Created by David Cox on 6/2/09.
//  Copyright Harvard University 2009. All rights reserved.
//

@import <Foundation/CPObject.j>

var ConfigToolbarItemIdentifier = "ConfigToolbarItemIdentifier",
    RecorderToolbarItemIdentifier = "RecorderToolbarItemIdentifier",
    StatusToolbarItemIdentifier = "StatusToolbarItemIdentifier";


@implementation AppController : CPObject
{
    CPWindow    theWindow; //this "outlet" is connected automatically by the Cib
    CPView      experimentBrowserView;
    CPView      configView;
    CPView      statusView;
    CPView      mainContentView;
    CPMenu      mainMenu;
    
    
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    // This is called when the application is done loading.
	
	// var cib = [[CPCib alloc] initWithContentsOfURL:[[CPBundle mainBundle] pathForResource:@"MainMenu.cib"]];
	// [cib instantiateCibWithExternalNameTable:[CPDictionary dictionaryWithObject:self forKey:CPCibOwner]];

     [CPMenu setMenuBarVisible:NO];         
}

- (void)awakeFromCib
{
    // This is called when the cib is done loading.
    // You can implement this method on any object instantiated from a Cib.
    // It's a useful hook for setting up current UI values, and other things. 
    
    
    
    // In this case, we want the window from Cib to become our full browser window
    [theWindow setFullBridge:YES];
    
    
    var toolbar = [[CPToolbar alloc] initWithIdentifier:"Soma Control"];
    [toolbar setDelegate:self];
    [toolbar setVisible:true];
    
    [theWindow setToolbar:toolbar];
        
    [self switchToStatus:self];
    
    [[theWindow contentView] setNeedsDisplay:YES];
    

}


//these two methods are the toolbar delegate methods, and tell the toolbar what it should display to the user
- (CPArray)toolbarAllowedItemIdentifiers:(CPToolbar)aToolbar
{
   return [self toolbarDefaultItemIdentifiers:aToolbar];
}

- (CPArray)toolbarDefaultItemIdentifiers:(CPToolbar)aToolbar
{
   return [StatusToolbarItemIdentifier, RecorderToolbarItemIdentifier, CPToolbarFlexibleSpaceItemIdentifier, ConfigToolbarItemIdentifier];
}

//this delegate method returns the actual toolbar item for the given identifier

- (CPToolbarItem)toolbar:(CPToolbar)aToolbar itemForItemIdentifier:(CPString)anItemIdentifier willBeInsertedIntoToolbar:(BOOL)aFlag
{
    var toolbarItem = [[CPToolbarItem alloc] initWithItemIdentifier:anItemIdentifier];

    if (anItemIdentifier == StatusToolbarItemIdentifier)
    {
        var image = [[CPImage alloc] initWithContentsOfFile:"Resources/dash.png" size:CPSizeMake(30,30)],
            highlighted = [[CPImage alloc] initWithContentsOfFile:"Resources/dash.png" size:CPSizeMake(30,30)];
            
        [toolbarItem setImage:image];
        [toolbarItem setAlternateImage:highlighted];
        
        [toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(switchToStatus:)];
        [toolbarItem setLabel:"Status"];

        [toolbarItem setMinSize:CGSizeMake(32, 32)];
        [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    } else if (anItemIdentifier == RecorderToolbarItemIdentifier){
            
        var image = [[CPImage alloc] initWithContentsOfFile:"Resources/drive.png" size:CPSizeMake(30,30)],
            highlighted = [[CPImage alloc] initWithContentsOfFile:"Resources/drive.png" size:CPSizeMake(30,30)];
            
        [toolbarItem setImage:image];
        [toolbarItem setAlternateImage:highlighted];

        [toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(switchToRecorder:)];
        [toolbarItem setLabel:"Recorder"];
        
        [toolbarItem setMinSize:CGSizeMake(32, 32)];
        [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    } else if (anItemIdentifier == ConfigToolbarItemIdentifier){
            
        var image = [[CPImage alloc] initWithContentsOfFile:"Resources/settings.png" size:CPSizeMake(30,30)],
            highlighted = [[CPImage alloc] initWithContentsOfFile:"Resources/settings.png" size:CPSizeMake(30,30)];
            
        [toolbarItem setImage:image];
        [toolbarItem setAlternateImage:highlighted];

        [toolbarItem setTarget:self];
        [toolbarItem setAction:@selector(switchToConfig:)];
        [toolbarItem setLabel:"Configuration"];
        
        [toolbarItem setMinSize:CGSizeMake(32, 32)];
        [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    }

    
    return toolbarItem;
}

- (void)switchContentToView: (CPView) new_view{
    old_frame = [mainContentView frame];
    [[theWindow contentView] replaceSubview:mainContentView with:new_view];
    mainContentView = new_view;
    [mainContentView setFrame:old_frame];
    [mainContentView setNeedsDisplay:YES];
}

- (void) switchToConfig: (id)sender {
    [self switchContentToView:configView];
}

- (void) switchToStatus: (id)sender {
    [self switchContentToView:statusView];
}

- (void) switchToRecorder: (id)sender {
    [self switchContentToView:experimentBrowserView];
}

@end
