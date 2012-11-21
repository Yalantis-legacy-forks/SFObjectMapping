//
//  SFMappingRuntime
//  Pods
//
//  Created by Paul Taykalo on 11/21/12.
//  Copyright (c) 2012 Stanfy LLC. All rights reserved.
//
#import <objc/runtime.h>
#import "SFMappingRuntime.h"


@implementation SFMappingRuntime {

}

+ (NSString *)typeForProperty:(NSString *)propertyName ofClass:(Class)objectClass {
   const char *attributes;
   objc_property_t property = class_getProperty(objectClass, [propertyName UTF8String]);

   // Searching property
   if (property) {
      attributes = property_getAttributes(property);
   }
    // Searchng Ivar if property wasn't found
   else {
      Ivar ivar = class_getInstanceVariable(objectClass, [propertyName UTF8String]);
      attributes = ivar_getTypeEncoding(ivar);
   }

   // If attributes is nil - we've found nothing. Return nil
   if ( ! attributes) {
      return nil;
   }

   NSString *attributesString = [NSString stringWithUTF8String:attributes];

   // Class
   if ([attributesString hasPrefix:@"T@\""]) {
      int commaLocation = [attributesString rangeOfString:@","].location;
      NSString *name = [attributesString substringWithRange:NSMakeRange(3, commaLocation - 4)];
      return name;
   }

   // Structure
   // T{CGRect="origin"{CGPoint="x"f"y"f}"size"{CGSize="width"f"height"f}},N,V_rectProperty
   if ([attributesString hasPrefix:@"T{"]) {
      int commaLocation = [attributesString rangeOfString:@"="].location;
      NSString *name = [attributesString substringWithRange:NSMakeRange(2, commaLocation - 2 )];
      return name;
   }

   // Number
   // BOOL == char
   // Tc,N,V_iPadEnabled
   if ([attributesString hasPrefix:@"Tf"] ||
    [attributesString hasPrefix:@"Ti"] ||
    [attributesString hasPrefix:@"Td"] ||
    [attributesString hasPrefix:@"Ts"]) {
      NSString *name = @"NSNumber";
      return name;
   }

   // BOOL
   if ([attributesString hasPrefix:@"Tc"]) {
      return @"BOOL";
   }

   return nil;
}

@end