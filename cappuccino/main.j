//
//  main.j
//  soma_cappuccino
//
//  Created by David Cox on 6/2/09.
//  Copyright Harvard University 2009. All rights reserved.
//

@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@import "AppController.j"
@import "StatusController.j"
@import "RecorderController.j"

CPLogRegister(CPLogPopup);

function main(args, namedArgs)
{
    CPApplicationMain(args, namedArgs);
}