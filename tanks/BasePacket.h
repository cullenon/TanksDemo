//
//  BasePacket.h
//  tanks
//
//  Created by Cullen O'Neill on 2/14/12.
//  Copyright (c) 2012 Lot18. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum
{
    kPacketTypeDeck = 1,
    kPacketTypeCardMoved,
    kPacketTypeCardFlipped,
    kPacketTypePlayerMoved,
    kPacketTypePlayerPickedUpCard,
    kPacketTypePlayerDroppedCard,
    kPacketTypeCardRotated,
    kPacketTypeCardRemoved,
    kPacketTypePlayerRequestingSwap, 
    kPacketTypePlayerAcceptedSwap, 
    kPacketTypePlayerRejectedSwap,
    kPacketTypePlayerSwap,
    kPacketTypePlayerBet,
    kPacketTypePlayerAsksForPot,
    kPacketTypePlayerSaysYouCanHaveIt,
    kPacketTypePlayerSaysYaCantHaveIt,
    kPacketTypePlayerTookPot,
    kPacketTypePlayerQuitGame
} EPacketTypes;

@interface BasePacket : NSObject <NSCoding> {
    EPacketTypes type;
}
@property EPacketTypes type;

- (id) initWithType:(EPacketTypes) inputType;
@end
