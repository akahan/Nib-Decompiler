//
//  NibDecompiler.m
//  Nib Decompiler
//
//  Created by Roman Yusufkhanov on 06.11.10.
//  Copyright (c) 2010 Yukka-S. All rights reserved.
//

#import "NibDecompiler.h"


@implementation NibDecompiler

- (id)runWithInput:(id)input fromAction:(AMAction *)anAction error:(NSDictionary **)errorInfo
{
  if([input isKindOfClass:[NSArray class]])
  {
    NSFileManager * manager = [NSFileManager defaultManager];
    NSBundle * bundle = [NSBundle bundleForClass:[self class]];
    
    for(id itemPath in input)
    {
      if([itemPath isKindOfClass:[NSString class]] && [[itemPath pathExtension] isEqualToString:@"nib"])
      {
        if(![[NSWorkspace sharedWorkspace] isFilePackageAtPath:itemPath])
        {
          NSString * keyedobjectsPathOld = [NSString stringWithFormat:@"%@/keyedobjects.nib", [itemPath stringByDeletingLastPathComponent]];
          NSString * keyedobjectsPathNew = [NSString stringWithFormat:@"%@/keyedobjects.nib", itemPath];
          [manager moveItemAtPath:itemPath toPath:keyedobjectsPathOld error:NULL];
          [manager createDirectoryAtPath:itemPath withIntermediateDirectories:YES attributes:nil error:NULL];
          [manager moveItemAtPath:keyedobjectsPathOld toPath:keyedobjectsPathNew error:NULL];
        }
        
        NSString * classesNibPathNew = [NSString stringWithFormat:@"%@/classes.nib", itemPath];
        NSString * infoNibPathNew = [NSString stringWithFormat:@"%@/info.nib", itemPath];
        NSString * classesNibPathOld = [bundle pathForResource:@"classes" ofType:@"nib"];
        NSString * infoNibPathOld = [bundle pathForResource:@"info" ofType:@"nib"];
        
        [manager copyItemAtPath:classesNibPathOld toPath:classesNibPathNew error:NULL];
        [manager copyItemAtPath:infoNibPathOld toPath:infoNibPathNew error:NULL];
      }
      else
      {
        NSLog(@"Class of the item must be NSString (current classname is %@) or file is not nib file",[itemPath className]);
      }
    }
  }
  else
  {
    NSLog(@"Class of the input must be NSArray (current classname is %@)",[input className]);
  }
	
	return input;
}

@end
