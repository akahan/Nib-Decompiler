//
//  NibDecompiler.m
//  Nib Decompiler
//
//  Created by Roman Yusufkhanov on 06.11.10.
//  Copyright (c) 2010 Yukka-S. All rights reserved.
//

#import "NibDecompiler.h"

@implementation NibDecompiler

NSString *const IBObjectDataKeyNSNextOid = @"NSNextOid";

// https://stackoverflow.com/questions/25397048/extract-cfkeyedarchiveruid-value
typedef struct CFRuntimeBase {
  void* isa;
  uint32_t runtimeInfo;
} CFRuntimeBase;
typedef struct CFKeyedArchiverUID {
  CFRuntimeBase base;
  uint32_t value;
} CFKeyedArchiverUID;

id readPlistFileContents(NSString *path) {
  NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:path];
  [inputStream open];
  return [NSPropertyListSerialization propertyListWithStream:inputStream options:NSPropertyListMutableContainers format:NULL error:NULL];
}
void writeBplistToFile(id plist, NSString *path) {
  NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
  [outputStream open];
  [NSPropertyListSerialization writePropertyList:plist toStream:outputStream format:NSPropertyListBinaryFormat_v1_0 options:0 error:NULL];
}
uint32_t cfKeyedArchiverUIDValue(id cfKeyedArchiverUID) {
  return ((__bridge CFKeyedArchiverUID*)cfKeyedArchiverUID)->value;
}
uint32_t topUIDInKeyedArchiverPlist(NSDictionary *keyedArchiverPlist, NSString *key) {
  NSDictionary *dollarTop = keyedArchiverPlist[@"$top"];
  return cfKeyedArchiverUIDValue(dollarTop[key]);
}
id objectInKeyedArchiverPlistForUID(id keyedArchiverPlist, uint32_t uid) {
  NSArray *dollarObjects = keyedArchiverPlist[@"$objects"];
  return dollarObjects[uid];
}
NSUInteger numberOfObjectsInKeyedArchiverPlist(id keyedArchiverPlist) {
  NSArray *dollarObjects = keyedArchiverPlist[@"$objects"];
  return dollarObjects.count;
}
void processKeyedobjectsKeyedArchiverPlist(NSString *path) {
  NSMutableDictionary *plist = readPlistFileContents(path);
  uint32_t ibObjectDataUID = topUIDInKeyedArchiverPlist(plist, @"IB.objectdata");
  
  NSMutableDictionary *ibObjectData = objectInKeyedArchiverPlistForUID(plist, ibObjectDataUID);
  ibObjectData[IBObjectDataKeyNSNextOid] = @(numberOfObjectsInKeyedArchiverPlist(plist) * 2);
  
  writeBplistToFile(plist, path);
}
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
    
    processKeyedobjectsKeyedArchiverPlist(itemPath);
    
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
