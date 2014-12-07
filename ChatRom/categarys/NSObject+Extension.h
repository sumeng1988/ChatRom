//
//  NSObject+Extension.h
//  ChatRom
//
//  Created by sumeng on 12/6/14.
//  Copyright (c) 2014 sumeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (extension)

- (BOOL)notEmpty;

@end

@interface NSDictionary (extension)

- (NSInteger)integerForKey:(NSString *)key;
- (int)intForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;
- (float)floatForKey:(NSString *)key;
- (double)doubleForKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key;
- (NSArray *)arrayForKey:(NSString *)key;
- (NSData *)dataForKey:(NSString *)key;
- (NSDictionary *)dictionaryForKey:(NSString *)key;

- (NSInteger)integerForKey:(NSString *)key def:(NSInteger)def;
- (int)intForKey:(NSString *)key def:(int)def;
- (BOOL)boolForKey:(NSString *)key def:(BOOL)def;
- (float)floatForKey:(NSString *)key def:(float)def;
- (double)doubleForKey:(NSString *)key def:(double)def;
- (NSString *)stringForKey:(NSString *)key def:(NSString *)def;
- (NSArray *)arrayForKey:(NSString *)key def:(NSArray *)def;
- (NSData *)dataForKey:(NSString *)key def:(NSData *)def;
- (NSDictionary *)dictionaryForKey:(NSString *)key def:(NSDictionary *)def;

@end

@interface NSMutableDictionary (extension)

- (void)setInteger:(NSInteger)value forKey:(NSString *)key;
- (void)setInt:(int)value forKey:(NSString *)key;
- (void)setBool:(BOOL)value forKey:(NSString *)key;
- (void)setFloat:(float)value forKey:(NSString *)key;
- (void)setDouble:(double)value forKey:(NSString *)key;

@end

@interface NSData (extension)

- (int)readInt:(int)offset;
- (Byte)readByte:(int)offset;

@end

@interface NSMutableData (extension)

- (NSMutableData*)appendInt:(int)val;
- (NSMutableData*)appendByte:(Byte)val;
- (NSMutableData*)appendCString:(char const*)str;
- (NSMutableData*)appendString:(NSString*)str encoding:(NSStringEncoding)encoding;

@end

@interface NSArray (extension)

- (id)objectAtIndexSafe:(NSUInteger)index;
- (id)objectAtIndex:(NSUInteger)index def:(id)def;

- (id)firstObject;
- (id)secondObject;
- (id)thirdObject;

@end

@interface NSMutableArray (extension)

- (void)addObjectSafe:(id)anObject;
- (void)insertObjectAtFirstIndex:(id)anObject;

@end

@interface UIFont (extension)

+ (UIFont*)font:(CGFloat)size;
+ (UIFont*)bold:(CGFloat)size;

@end

@interface UIView (extension)

@property (nonatomic, assign) CGPoint leftTop;
@property (nonatomic, assign) CGPoint leftCenter;
@property (nonatomic, assign) CGPoint leftBottom;
@property (nonatomic, assign) CGPoint rightTop;
@property (nonatomic, assign) CGPoint rightCenter;
@property (nonatomic, assign) CGPoint rightBottom;
@property (nonatomic, assign) CGPoint topCenter;
@property (nonatomic, assign) CGPoint bottomCenter;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@end

@interface UIImage (extension)

+ (UIImage *)stretchImage:(NSString *)name;

@end
