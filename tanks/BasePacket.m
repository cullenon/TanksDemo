//
//  BasePacket.m
//  tanks
//
//  Created by Cullen O'Neill on 2/14/12.
//  Copyright (c) 2012 Lot18. All rights reserved.
//

#import "BasePacket.h"

@implementation BasePacket

@synthesize type;

- (id) initWithType:(EPacketTypes) inputType
{
    if (self = [super init]) {
        [self setType:inputType];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        [aDecoder decodeValueOfObjCType:@encode(EPacketTypes) at:& type];
    }
    return self;    
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeValueOfObjCType:@encode(EPacketTypes) at:&type];
}

@end
