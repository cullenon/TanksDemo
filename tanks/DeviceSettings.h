//
//  DeviceSettings.h
//  Aiden's Adventures
//
//  Created by Cullen O'Neill on 9/22/11.
//  Copyright 2011 Lot18. All rights reserved.
//

#import <UIKit/UIDevice.h>

/*  DETERMINE THE DEVICE USED  */
#ifdef UI_USER_INTERFACE_IDIOM()
#define IS_IPAD() (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#else
#define IS_IPAD() (NO)
#endif

/*  NORMAL DETAILS */
#define kScreenHeight       320
#define kScreenWidth        480

/* OFFSETS TO ACCOMMODATE IPAD */
#define kXoffsetiPad        32
#define kYoffsetiPad        64

#define SD_PNG      @".png"
#define HD_PNG      @"-hd.png"

#define SD_PLIST      @".plist"
#define HD_PLIST      @"-hd.plist"

#define SD_PVR      @".pvr"
#define HD_PVR      @"-hd.pvr"

#define SD_FNT      @".fnt"
#define HD_FNT      @"-hd.fnt"

#define SD_TMX      @".tmx"
#define HD_TMX      @"-hd.tmx"

#define ADJUST_CCP(__p__)       \
(IS_IPAD() == YES ?             \
ccp( ( __p__.x * 2 ) + kXoffsetiPad, ( __p__.y * 2 ) + kYoffsetiPad ) : \
__p__)

#define REVERSE_CCP(__p__)      \
(IS_IPAD() == YES ?             \
ccp( ( __p__.x - kXoffsetiPad ) / 2, ( __p__.y - kYoffsetiPad ) / 2 ) : \
__p__)

#define ADJUST_XY(__x__, __y__)     \
(IS_IPAD() == YES ?                     \
ccp( ( __x__ * 2 ) + kXoffsetiPad, ( __y__ * 2 ) + kYoffsetiPad ) : \
ccp(__x__, __y__))

#define ADJUST_X(__x__)         \
(IS_IPAD() == YES ?             \
( __x__ * 2 ) + kXoffsetiPad :      \
__x__)

#define ADJUST_Y(__y__)         \
(IS_IPAD() == YES ?             \
( __y__ * 2 ) + kYoffsetiPad :      \
__y__)

#define HD_PIXELS(__pixels__)       \
(IS_IPAD() == YES ?             \
( __pixels__ * 2 ) :                \
__pixels__)

#define HD_TEXT(__size__)   \
(IS_IPAD() == YES ?         \
( __size__ * 1.5 ) :            \
__size__)

#define SD_OR_HD_PNG(__filename__)  \
(IS_IPAD() == YES ?             \
[__filename__ stringByReplacingOccurrencesOfString:SD_PNG withString:HD_PNG] :  \
__filename__)

#define SD_OR_HD_PLIST(__filename__)  \
(IS_IPAD() == YES ?             \
[__filename__ stringByReplacingOccurrencesOfString:SD_PLIST withString:HD_PLIST] :  \
__filename__)

#define SD_OR_HD_PVR(__filename__)  \
(IS_IPAD() == YES ?             \
[__filename__ stringByReplacingOccurrencesOfString:SD_PVR withString:HD_PVR] :  \
__filename__)

#define SD_OR_HD_FNT(__filename__)  \
(IS_IPAD() == YES ?             \
[__filename__ stringByReplacingOccurrencesOfString:SD_FNT withString:HD_FNT] :  \
__filename__)

#define SD_OR_HD_TMX(__filename__)  \
(IS_IPAD() == YES ?             \
[__filename__ stringByReplacingOccurrencesOfString:SD_TMX withString:HD_TMX] :  \
__filename__)

#define ADJUST_COORD(__coord__)   \
(IS_IPAD() == YES ?                     \
(__coord__ * 2) :                       \
__coord__)

#define ADJUST_TEXTFIELD(__x__) \
(IS_IPAD() == YES ?                     \
(__x__ * 3/2) :                         \
__x__)

#define ADJUST_AD_X(__x__)  \
(IS_IPAD() == YES ?                     \
(__x__ * 2.275) :                       \
__x__)

#define ADJUST_AD_Y(__y__)  \
(IS_IPAD() == YES ?                     \
(__y__ * 1.8) :                         \
__y__)

#define ADJUST_TILENUM(__num__) \
(IS_IPAD() == YES ?                     \
(__num__ * 4/3) :                       \
__num__)

#define ADJUST_SPEED(__s__)  \
(IS_IPAD() == YES ?                     \
(__s__ * 1.7) :                         \
__s__)

#define PNG_TMX_SW(__filename__)  \
[__filename__ stringByReplacingOccurrencesOfString:SD_PNG withString:SD_TMX]



#define IS_HD ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.0f)

#define TILE_HEIGHT 32
#define TILE_HEIGHT_HD 64




