//
//  NSObject+Extension.m
//  ChatRom
//
//  Created by sumeng on 12/6/14.
//  Copyright (c) 2014 sumeng. All rights reserved.
//

#import "NSObject+Extension.h"

@implementation NSString (extension)

- (BOOL)notEmpty {
    return self.length > 0;
}

@end

@implementation NSDictionary(extension)

- (NSInteger)integerForKey:(NSString *)key {
    return [self integerForKey:key def:0];
}

- (int)intForKey:(NSString *)key {
    return [self intForKey:key def:0];
}

- (BOOL)boolForKey:(NSString *)key {
    return [self boolForKey:key def:NO];
}

- (float)floatForKey:(NSString *)key {
    return [self floatForKey:key def:0.0f];
}

- (double)doubleForKey:(NSString *)key {
    return [self doubleForKey:key def:0.0];
}

- (NSString *)stringForKey:(NSString *)key {
    return [self stringForKey:key def:@""];
}

- (NSArray *)arrayForKey:(NSString *)key {
    return [self arrayForKey:key def:nil];
}

- (NSData *)dataForKey:(NSString *)key {
    return [self dataForKey:key def:nil];
}

- (NSDictionary *)dictionaryForKey:(NSString *)key {
    return [self dictionaryForKey:key def:nil];
}

- (NSInteger)integerForKey:(NSString *)key def:(NSInteger)def {
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSNumber class]])
        return [(NSNumber *)obj integerValue];
    else if ([obj isKindOfClass:[NSString class]])
        return [(NSString *)obj integerValue];
    else
        return def;
}

- (int)intForKey:(NSString *)key def:(int)def {
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSNumber class]])
        return [(NSNumber *)obj intValue];
    else if ([obj isKindOfClass:[NSString class]])
        return [(NSString *)obj intValue];
    else
        return def;
}

- (BOOL)boolForKey:(NSString *)key def:(BOOL)def {
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSNumber class]])
        return [(NSNumber *)obj boolValue];
    else if ([obj isKindOfClass:[NSString class]])
        return [(NSString *)obj boolValue];
    else
        return def;
    
}

- (float)floatForKey:(NSString *)key def:(float)def {
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSNumber class]])
        return [(NSNumber *)obj floatValue];
    else if ([obj isKindOfClass:[NSString class]])
        return [(NSString *)obj floatValue];
    else
        return def;
}

- (double)doubleForKey:(NSString *)key def:(double)def {
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSNumber class]])
        return [(NSNumber *)obj doubleValue];
    else if ([obj isKindOfClass:[NSString class]])
        return [(NSString *)obj doubleValue];
    else
        return def;
    
}

- (NSString *)stringForKey:(NSString *)key def:(NSString *)def {
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSNumber class]])
        return [(NSNumber *)obj stringValue];
    else if ([obj isKindOfClass:[NSString class]])
        return obj;
    else
        return def;
    
}

- (NSArray *)arrayForKey:(NSString *)key def:(NSArray *)def {
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSArray class]])
        return obj;
    else
        return def;
    
}

- (NSData *)dataForKey:(NSString *)key def:(NSData *)def {
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSData class]])
        return obj;
    else
        return def;
}

- (NSDictionary *)dictionaryForKey:(NSString *)key def:(NSDictionary *)def {
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSDictionary class]])
        return obj;
    else
        return def;
}

@end

@implementation NSMutableDictionary (extension)

- (void)setInteger:(NSInteger)value forKey:(NSString *)key {
    [self setObject:[NSNumber numberWithInteger:value] forKey:key];
}

- (void)setInt:(int)value forKey:(NSString *)key {
    [self setObject:[NSNumber numberWithInt:value] forKey:key];
}

- (void)setBool:(BOOL)value forKey:(NSString *)key {
    [self setObject:[NSNumber numberWithBool:value] forKey:key];
}

- (void)setFloat:(float)value forKey:(NSString *)key {
    [self setObject:[NSNumber numberWithFloat:value] forKey:key];
}

- (void)setDouble:(double)value forKey:(NSString *)key {
    [self setObject:[NSNumber numberWithDouble:value] forKey:key];
}

@end

@implementation NSData (extension)

- (int)readInt:(int)offset {
    return *(int *)(self.bytes + offset);
}

- (Byte)readByte:(int)offset {
    return *(Byte *)(self.bytes + offset);
}

@end

@implementation NSMutableData (extension)

- (NSMutableData*)appendInt:(int)val {
    [self appendBytes:&val length:sizeof(int)];
    return self;
}

- (NSMutableData*)appendByte:(Byte)val {
    [self appendBytes:&val length:sizeof(Byte)];
    return self;
}

- (NSMutableData*)appendCString:(char const*)str {
    int len = (int)strlen(str);
    [self appendBytes:str length:len];
    return self;
}

- (NSMutableData*)appendString:(NSString*)str encoding:(NSStringEncoding)encoding {
    NSData* strdata = [str dataUsingEncoding:encoding];
    [self appendData:strdata];
    return self;
}

@end

@implementation NSArray (extension)

- (id)objectAtIndexSafe:(NSUInteger)index {
    id ret = [self objectAtIndex:index];
    if ([ret isKindOfClass:[NSNull class]])
        return nil;
    return ret;
}

- (id)objectAtIndex:(NSUInteger)index def:(id)def {
    if (index >= self.count)
        return def;
    id ret = [self objectAtIndexSafe:index];
    if (ret == nil)
        return def;
    return ret;
}

- (id)firstObject {
    return [self objectAtIndex:0 def:nil];
}

- (id)secondObject {
    return [self objectAtIndex:1 def:nil];
}

- (id)thirdObject {
    return [self objectAtIndex:2 def:nil];
}

@end

@implementation NSMutableArray (extension)

- (void)addObjectSafe:(id)anObject {
    if (anObject == nil)
        [self addObject:[NSNull null]];
    else
        [self addObject:anObject];
}

- (void)insertObjectAtFirstIndex:(id)anObject {
    if (self.count > 0) {
        [self insertObject:anObject atIndex:0];
    }
    else {
        [self addObject:anObject];
    }
}

@end

@implementation UIFont (extension)

+ (UIFont*)font:(CGFloat)size {
    return [UIFont systemFontOfSize:size];
}

+ (UIFont*)bold:(CGFloat)size {
    return [UIFont boldSystemFontOfSize:size];
}

@end

@implementation UIView (extension)

- (void)setLeftTop:(CGPoint)pt {
    CGRect rc = self.frame;
    if (CGPointEqualToPoint(rc.origin, pt))
        return;
    rc.origin = pt;
    self.frame = rc;
}

- (CGPoint)leftTop {
    return self.frame.origin;
}

- (void)setLeftCenter:(CGPoint)pt {
    pt.y -= self.bounds.size.height * .5f;
    [self setLeftTop:pt];
}

- (CGPoint)leftCenter {
    CGPoint pt = self.leftTop;
    pt.y += self.bounds.size.height * .5f;
    return pt;
}

- (void)setLeftBottom:(CGPoint)pt {
    CGRect rc = self.frame;
    rc.origin.x = pt.x;
    rc.origin.y = pt.y - rc.size.height;
    self.frame = rc;
}

- (CGPoint)leftBottom {
    CGPoint pt = self.frame.origin;
    pt.y += self.frame.size.height;
    return pt;
}

- (void)setRightTop:(CGPoint)pt {
    CGRect rc = self.frame;
    rc.origin.x = pt.x - rc.size.width;
    rc.origin.y = pt.y;
    self.frame = rc;
}

- (CGPoint)rightTop {
    CGPoint pt = self.frame.origin;
    pt.x += self.frame.size.width;
    return pt;
}

- (void)setRightCenter:(CGPoint)pt {
    pt.y -= self.bounds.size.height * .5f;
    [self setRightTop:pt];
}

- (CGPoint)rightCenter {
    CGPoint pt = self.rightTop;
    pt.y += self.bounds.size.height * .5f;
    return pt;
}

- (void)setRightBottom:(CGPoint)pt {
    CGRect rc = self.frame;
    rc.origin.x = pt.x - rc.size.width;
    rc.origin.y = pt.y - rc.size.height;
    self.frame = rc;
}

- (CGPoint)rightBottom {
    CGPoint pt = self.frame.origin;
    pt.x += self.frame.size.width;
    pt.y += self.frame.size.height;
    return pt;
}

- (void)setTopCenter:(CGPoint)pt {
    pt.x -= self.bounds.size.width * .5f;
    [self setLeftTop:pt];
}

- (CGPoint)topCenter {
    CGPoint pt = self.leftTop;
    pt.x += self.bounds.size.width * .5f;
    return pt;
}

- (void)setBottomCenter:(CGPoint)pt {
    pt.x -= self.bounds.size.width * .5f;
    [self setLeftBottom:pt];
}

- (CGPoint)bottomCenter {
    CGPoint pt = self.leftBottom;
    pt.x += self.bounds.size.width * .5f;
    return pt;
}

- (void)setSize:(CGSize)sz {
    CGRect r = self.frame;
    r.size = sz;
    self.frame = r;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setX:(CGFloat)x {
    CGRect r = self.frame;
    r.origin.x = x;
    self.frame = r;
}

- (CGFloat)x {
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y {
    CGRect r = self.frame;
    r.origin.y = y;
    self.frame = r;
}

- (CGFloat)y {
    return self.frame.origin.y;
}

- (void)setWidth:(CGFloat)width {
    CGRect r = self.frame;
    r.size.width = width;
    self.frame = r;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height {
    CGRect r = self.frame;
    r.size.height = height;
    self.frame = r;
}

- (CGFloat)height {
    return self.frame.size.height;
}

@end

@implementation UIImage (extension)

+ (UIImage*)stretchImage:(NSString *)name {
    UIImage *image = [self imageNamed:name];
    UIEdgeInsets capInsets = UIEdgeInsetsMake(image.size.height * 0.5f,
                                              image.size.width * 0.5f,
                                              image.size.height * 0.5f,
                                              image.size.width * 0.5f);
    return [image resizableImageWithCapInsets:capInsets];
}

@end