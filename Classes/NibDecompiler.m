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
  if (![input isKindOfClass:[NSArray class]])
  {
    NSLog(@"Class of the input must be NSArray (current classname is %@)", [input className]);
    return input;
  }
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
  NSBundle *bundle = self.bundle;
  
  for (NSString *itemPath in input)
  {
    if (![itemPath isKindOfClass:[NSString class]])
    {
      NSLog(@"Class of the item must be NSString (current classname is %@)", [itemPath className]);
      continue;
    }
    if (![[itemPath pathExtension] isEqualToString:@"nib"])
    {
      NSLog(@"File %@ is not a nib file", itemPath);
      continue;
    }
    
    if (![workspace isFilePackageAtPath:itemPath])
    {
      NSString *keyedobjectsPathOld = [NSString stringWithFormat:@"%@/keyedobjects.nib", [itemPath stringByDeletingLastPathComponent]];
      NSString *keyedobjectsPathNew = [NSString stringWithFormat:@"%@/keyedobjects.nib", itemPath];
      [fileManager moveItemAtPath:itemPath toPath:keyedobjectsPathOld error:NULL];
      [fileManager createDirectoryAtPath:itemPath withIntermediateDirectories:YES attributes:nil error:NULL];
      [fileManager moveItemAtPath:keyedobjectsPathOld toPath:keyedobjectsPathNew error:NULL];
    }
    
    NSString *classesNibPathNew = [NSString stringWithFormat:@"%@/classes.nib", itemPath];
    NSString *infoNibPathNew = [NSString stringWithFormat:@"%@/info.nib", itemPath];
    NSString *classesNibPathOld = [bundle pathForResource:@"classes" ofType:@"nib"];
    NSString *infoNibPathOld = [bundle pathForResource:@"info" ofType:@"nib"];
    
    [fileManager copyItemAtPath:classesNibPathOld toPath:classesNibPathNew error:NULL];
    [fileManager copyItemAtPath:infoNibPathOld toPath:infoNibPathNew error:NULL];
  }
	
	return input;
}

@end
