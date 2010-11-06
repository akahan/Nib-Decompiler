//
//  NibDecompiler.h
//  Nib Decompiler
//
//  Created by Roman Yusufkhanov on 06.11.10.
//  Copyright (c) 2010 Yukka-S. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Automator/AMBundleAction.h>

@interface NibDecompiler : AMBundleAction 
{
}

- (id)runWithInput:(id)input fromAction:(AMAction *)anAction error:(NSDictionary **)errorInfo;

@end
