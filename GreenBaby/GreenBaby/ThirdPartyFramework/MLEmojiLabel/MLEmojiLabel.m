//
//  MLEmojiLabel.m
//  MLEmojiLabel
//
//  Created by LiXiangCheng on 5/19/14.
//  Copyright (c) 2014 idea.com. All rights reserved.
//

#import "MLEmojiLabel.h"

#pragma mark - 正则列表

#define REGULAREXPRESSION_OPTION(regularExpression,regex,option) \
\
static inline NSRegularExpression * k##regularExpression() { \
static NSRegularExpression *_##regularExpression = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_##regularExpression = [[NSRegularExpression alloc] initWithPattern:(regex) options:(option) error:nil];\
});\
\
return _##regularExpression;\
}\


#define REGULAREXPRESSION(regularExpression,regex) REGULAREXPRESSION_OPTION(regularExpression,regex,NSRegularExpressionCaseInsensitive)

//正则1
REGULAREXPRESSION(URLRegularExpression,@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)")
//正则2
REGULAREXPRESSION(PhoneNumerRegularExpression, @"\\d{3}-\\d{8}|\\d{3}-\\d{7}|\\d{4}-\\d{8}|\\d{4}-\\d{7}|1+[358]+\\d{9}|\\d{8}|\\d{7}")
//正则3
REGULAREXPRESSION(EmailRegularExpression, @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}")
//正则4
REGULAREXPRESSION(AtRegularExpression, @"@[\\u4e00-\\u9fa5\\w\\-]+")//@
//正则5
//@"#([^\\#|.]+)#"
REGULAREXPRESSION_OPTION(PoundSignRegularExpression, @"#([\\u4e00-\\u9fa5\\w\\-]+)#", NSRegularExpressionCaseInsensitive)//话题##
//正则--用于表情
//微信的表情符其实不是这种格式，这个格式的只是让人看起来更友好。。
//REGULAREXPRESSION(EmojiRegularExpression, @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]")

//@"/:[\\w:~!@$&*()|+<>',?-]{1,8}" , // @"/:[\\x21-\\x2E\\x30-\\x7E]{1,8}" ，经过检测发现\w会匹配中文，好奇葩。
REGULAREXPRESSION(SlashEmojiRegularExpression, @"/:[\\x21-\\x2E\\x30-\\x7E]{1,8}")
//正则6
REGULAREXPRESSION(ReplyRegularExpression, @"^.*?(?=:%C)")//xxx： %c=kEmojiReplaceCharacter
//REGULAREXPRESSION(ReplyRegularExpression, @"(^.*?(?=回复)|(?<=回复).*?(?=:%C))")//xxx回复xxx：  %c=kEmojiReplaceCharacter
//REGULAREXPRESSION(ReplyRegularExpression, @"(?<=回复).*?(?=:%C)")//回复xxx：  %c=kEmojiReplaceCharacter

const CGFloat kLineSpacing = 4.0; //默认行间距
const CGFloat kAscentDescentScale = 0.25; //在这里的话无意义，高度的结局都是和宽度一样

const CGFloat kEmojiWidthRatioWithLineHeight = 1.25;//和字体高度的比例

const CGFloat kEmojiOriginYOffsetRatioWithLineHeight = 0.10; //表情绘制的y坐标矫正值，和字体高度的比例，越大越往下
NSString *const kCustomGlyphAttributeImageName = @"CustomGlyphAttributeImageName";

#define kURLActionCount 6
NSString * const kURLActions[] = {@"url->",@"phoneNumber->",@"email->",@"at->",@"poundSign->",@"reply->"};

@interface MLEmojiLabel()<TTTAttributedLabelDelegate>

@property (nonatomic, strong) NSRegularExpression *customEmojiRegularExpression;
@property (nonatomic, strong) NSRegularExpression *customReplyRegularExpression;

@end

@implementation MLEmojiLabel

#pragma mark - 表情包字典
+ (NSDictionary *)emojiDictionary {
//    static NSDictionary *emojiDictionary = nil;
//    static dispatch_once_t onceToken;
//	dispatch_once(&onceToken, ^{
//	    NSString *emojiFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"faceMap_ch.plist"];
//	    emojiDictionary = [[NSDictionary alloc] initWithContentsOfFile:emojiFilePath];
//	});
//	return emojiDictionary;
    
    return [Configs faceMap];
}

#pragma mark - 表情 callback
typedef struct CustomGlyphMetrics {
    CGFloat ascent;
    CGFloat descent;
    CGFloat width;
} CustomGlyphMetrics, *CustomGlyphMetricsRef;

static void deallocCallback(void *refCon) {
    free(refCon);
    refCon = NULL;
}

static CGFloat ascentCallback(void *refCon) {
	CustomGlyphMetricsRef metrics = (CustomGlyphMetricsRef)refCon;
	return metrics->ascent;
}

static CGFloat descentCallback(void *refCon) {
	CustomGlyphMetricsRef metrics = (CustomGlyphMetricsRef)refCon;
	return metrics->descent;
}

static CGFloat widthCallback(void *refCon) {
	CustomGlyphMetricsRef metrics = (CustomGlyphMetricsRef)refCon;
	return metrics->width;
}

#pragma mark - 初始化和TTT的一些修正
/**
 *  TTT很鸡巴。commonInit是被调用了两回。如果直接init的话，因为init其中会调用initWithFrame
 *  PS.已经在里面把init里的修改掉了
 */
- (void)commonInit {
    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled = NO;
    
    self.delegate = self;
    self.numberOfLines = 0;
    self.font = [UIFont systemFontOfSize:16.0];
    self.textColor = [UIColor blackColor];
    self.backgroundColor = [UIColor clearColor];
    
    /**
     *  PS:这里需要注意，TTT里默认把numberOfLines不为1的情况下实际绘制的lineBreakMode是以word方式。
     *  而默认UILabel似乎也是这样处理的。我不知道为何。已经做修改。
     */
    self.lineBreakMode = NSLineBreakByCharWrapping;
    
    self.textInsets = UIEdgeInsetsZero;
    self.lineHeightMultiple = 1.0f;
    self.lineSpacing = kLineSpacing; //默认行间距
    
    [self setValue:[NSArray array] forKey:@"links"];
    
    NSMutableDictionary *mutableLinkAttributes = [NSMutableDictionary dictionary];
    [mutableLinkAttributes setObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    
    NSMutableDictionary *mutableActiveLinkAttributes = [NSMutableDictionary dictionary];
    [mutableActiveLinkAttributes setObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    
    NSMutableDictionary *mutableInactiveLinkAttributes = [NSMutableDictionary dictionary];
    [mutableInactiveLinkAttributes setObject:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    
    UIColor *commonLinkColor = MKRGBA(27,155,246,255);
    
    //点击时候的背景色
    [mutableActiveLinkAttributes setValue:(__bridge id)[MKRGBA(246,246,248,255) CGColor] forKey:(NSString *)kTTTBackgroundFillColorAttributeName];
    
    if ([NSMutableParagraphStyle class]) {
        [mutableLinkAttributes setObject:commonLinkColor forKey:(NSString *)kCTForegroundColorAttributeName];
        [mutableActiveLinkAttributes setObject:commonLinkColor forKey:(NSString *)kCTForegroundColorAttributeName];
        [mutableInactiveLinkAttributes setObject:[UIColor grayColor] forKey:(NSString *)kCTForegroundColorAttributeName];
        
        
        //把原有TTT的NSMutableParagraphStyle设置给去掉了。会影响到整个段落的设置
    } else {
        [mutableLinkAttributes setObject:(__bridge id)[commonLinkColor CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
        [mutableActiveLinkAttributes setObject:(__bridge id)[commonLinkColor CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
        [mutableInactiveLinkAttributes setObject:(__bridge id)[[UIColor grayColor] CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
        
        
        //把原有TTT的NSMutableParagraphStyle设置给去掉了。会影响到整个段落的设置
    }
    
    self.linkAttributes = [NSDictionary dictionaryWithDictionary:mutableLinkAttributes];
    self.activeLinkAttributes = [NSDictionary dictionaryWithDictionary:mutableActiveLinkAttributes];
    self.inactiveLinkAttributes = [NSDictionary dictionaryWithDictionary:mutableInactiveLinkAttributes];
}

/**
 *  如果是有attributedText的情况下，有可能会返回少那么点的，这里矫正下
 *
 */
- (CGSize)sizeThatFits:(CGSize)size {
    if (!self.attributedText) {
        return [super sizeThatFits:size];
    }
    
    CGSize rSize = [super sizeThatFits:size];
    rSize.height +=1;
    return rSize;
}


//这里是抄TTT里的，因为他不是放在外面的
static inline CGFloat TTTFlushFactorForTextAlignment(NSTextAlignment textAlignment) {
    switch (textAlignment) {
        case NSTextAlignmentCenter:
            return 0.5f;
        case NSTextAlignmentRight:
            return 1.0f;
        case NSTextAlignmentLeft:
        default:
            return 0.0f;
    }
}

#pragma mark - 绘制表情
- (void)drawOtherForEndWithFrame:(CTFrameRef)frame
                          inRect:(CGRect)rect
                         context:(CGContextRef)c
{
    //PS:这个是在TTT里drawFramesetter....方法最后做了修改的基础上。
    
    CGFloat emojiOriginYOffset = self.font.lineHeight*kEmojiOriginYOffsetRatioWithLineHeight;
    
    //找到行
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    //找到每行的origin，保存起来
    CGPoint origins[[lines count]];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
    
    //修正绘制offset，根据当前设置的textAlignment
    CGFloat flushFactor = TTTFlushFactorForTextAlignment(self.textAlignment);
    
    CFIndex lineIndex = 0;
    for (id line in lines) {
        //获取当前行的宽度和高度，并且设置对应的origin进去，就获得了这行的bounds
        CGFloat ascent = 0.0f, descent = 0.0f, leading = 0.0f;
        CGFloat width = (CGFloat)CTLineGetTypographicBounds((__bridge CTLineRef)line, &ascent, &descent, &leading) ;
        CGRect lineBounds = CGRectMake(0.0f, 0.0f, width, ascent + descent + leading) ;
        lineBounds.origin.x = origins[lineIndex].x;
        lineBounds.origin.y = origins[lineIndex].y;
        
        //这里其实是能获取到当前行的真实origin.x，根据textAlignment，而lineBounds.origin.x其实是默认一直为0的(不会受textAlignment影响)
        CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush((__bridge CTLineRef)line, flushFactor, rect.size.width);
        
        //找到当前行的每一个要素，姑且这么叫吧。可以理解为有单独的attr属性的各个range。
        for (id glyphRun in (__bridge NSArray *)CTLineGetGlyphRuns((__bridge CTLineRef)line)) {
            //找到此要素所对应的属性
            NSDictionary *attributes = (__bridge NSDictionary *)CTRunGetAttributes((__bridge CTRunRef) glyphRun);
            //判断是否有图像，如果有就绘制上去
            NSString *imageName = attributes[kCustomGlyphAttributeImageName];
            if (imageName) {
                CGRect runBounds = CGRectZero;
                CGFloat runAscent = 0.0f;
                CGFloat runDescent = 0.0f;
                
                runBounds.size.width = (CGFloat)CTRunGetTypographicBounds((__bridge CTRunRef)glyphRun, CFRangeMake(0, 0), &runAscent, &runDescent, NULL);
                runBounds.size.height = runAscent + runDescent;
                
                CGFloat xOffset = 0.0f;
                CFRange glyphRange = CTRunGetStringRange((__bridge CTRunRef)glyphRun);
                switch (CTRunGetStatus((__bridge CTRunRef)glyphRun)) {
                    case kCTRunStatusRightToLeft:
                        xOffset = CTLineGetOffsetForStringIndex((__bridge CTLineRef)line, glyphRange.location + glyphRange.length, NULL);
                        break;
                    default:
                        xOffset = CTLineGetOffsetForStringIndex((__bridge CTLineRef)line, glyphRange.location, NULL);
                        break;
                }
                runBounds.origin.x = penOffset + xOffset;
                runBounds.origin.y = origins[lineIndex].y;
                runBounds.origin.y -= runDescent;
                
                UIImage *image = [UIImage imageNamed:imageName];
                runBounds.origin.y -= emojiOriginYOffset; //稍微矫正下。
                CGContextDrawImage(c, runBounds, image.CGImage);
            }
        }
        
        lineIndex++;
    }
    
}


#pragma mark - main
/**
 *  返回经过表情识别处理的Attributed字符串
 */
- (NSMutableAttributedString*)mutableAttributeStringWithEmojiText:(NSString*)emojiText
{
    //获取所有表情的位置
//    NSArray *emojis = [kEmojiRegularExpression() matchesInString:emojiText
//                                                         options:NSMatchingWithTransparentBounds
//                                                           range:NSMakeRange(0, [emojiText length])];

    NSArray *emojis = nil;
    
    if (self.customEmojiRegularExpression) {
        //自定义表情正则
        emojis = [self.customEmojiRegularExpression matchesInString:emojiText
                        options:NSMatchingWithTransparentBounds
                        range:NSMakeRange(0, [emojiText length])];
    }else{
        emojis = [kSlashEmojiRegularExpression() matchesInString:emojiText
                                                options:NSMatchingWithTransparentBounds
                                                  range:NSMakeRange(0, [emojiText length])];
    }
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] init];
    NSUInteger location = 0;
    
    
    CGFloat emojiWith = self.font.lineHeight*kEmojiWidthRatioWithLineHeight;
    for (NSTextCheckingResult *result in emojis) {
        NSRange range = result.range;
		NSString *subStr = [emojiText substringWithRange:NSMakeRange(location, range.location - location)];
		NSMutableAttributedString *attSubStr = [[NSMutableAttributedString alloc] initWithString:subStr];
		[attrStr appendAttributedString:attSubStr];
        
		location = range.location + range.length;
        
		NSString *emojiKey = [emojiText substringWithRange:range];
        
        
        NSDictionary *emojiDict = [MLEmojiLabel emojiDictionary];
        
        //如果当前获得key后面有多余的，这个需要记录下
        NSMutableAttributedString *otherAppendStr = nil;
        
		NSString *imageName = emojiDict[emojiKey];
        if (!self.customEmojiRegularExpression) {
            //微信的表情没有结束符号,所以有可能会发现过长的只有头部才是表情的段，需要循环检测一次。微信最大表情特殊字符是8个长度，检测8次即可
            if (!imageName&&emojiKey.length>2) {
                NSUInteger maxDetctIndex = emojiKey.length>8+2?8:emojiKey.length-2;
                //从头开始检测是否有对应的
                for (NSUInteger i=0; i<maxDetctIndex; i++) {
                    //                NSLog(@"%@",[emojiKey substringToIndex:3+i]);
                    imageName = emojiDict[[emojiKey substringToIndex:3+i]];
                    if (imageName) {
                        otherAppendStr  = [[NSMutableAttributedString alloc]initWithString:[emojiKey substringFromIndex:3+i]];
                        break;
                    }
                }
            }
        }
        
		if (imageName) {
			// 这里不用空格，空格有个问题就是连续空格的时候只显示在一行
			NSMutableAttributedString *replaceStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%C",kEmojiReplaceCharacter]];
			NSRange __range = NSMakeRange([attrStr length], 1);
			[attrStr appendAttributedString:replaceStr];
            if (otherAppendStr) { //有其他需要添加的
                [attrStr appendAttributedString:otherAppendStr];
            }
            
			// 定义回调函数
			CTRunDelegateCallbacks callbacks;
			callbacks.version = kCTRunDelegateCurrentVersion;
			callbacks.getAscent = ascentCallback;
			callbacks.getDescent = descentCallback;
			callbacks.getWidth = widthCallback;
			callbacks.dealloc = deallocCallback;
            
			// 这里设置下需要绘制的图片的大小，这里我自定义了一个结构体以便于存储数据
			CustomGlyphMetricsRef metrics = malloc(sizeof(CustomGlyphMetrics));
            metrics->width = emojiWith;
			metrics->ascent = 1/(1+kAscentDescentScale)*metrics->width;
			metrics->descent = metrics->ascent*kAscentDescentScale;
			CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, metrics);
			[attrStr addAttribute:(NSString *)kCTRunDelegateAttributeName
                            value:(__bridge id)delegate
                            range:__range];
			CFRelease(delegate);
            
			// 设置自定义属性，绘制的时候需要用到
			[attrStr addAttribute:kCustomGlyphAttributeImageName
                            value:imageName
                            range:__range];
		} else {
			NSMutableAttributedString *originalStr = [[NSMutableAttributedString alloc] initWithString:emojiKey];
			[attrStr appendAttributedString:originalStr];
		}
    }
    if (location < [emojiText length]) {
        NSRange range = NSMakeRange(location, [emojiText length] - location);
        NSString *subStr = [emojiText substringWithRange:range];
        NSMutableAttributedString *attrSubStr = [[NSMutableAttributedString alloc] initWithString:subStr];
        [attrStr appendAttributedString:attrSubStr];
    }
    return attrStr;
}


- (void)setEmojiText:(NSString*)emojiText
{
    _emojiText = emojiText;
    if (!emojiText||emojiText.length<=0) {
        [super setText:nil];
        return;
    }
    
    NSMutableAttributedString *mutableAttributedString = nil;
    
    if (self.disableEmoji) {
        mutableAttributedString = [[NSMutableAttributedString alloc]initWithString:emojiText];
    }else{
        mutableAttributedString = [self mutableAttributeStringWithEmojiText:emojiText];
    }
    
    [self setText:mutableAttributedString afterInheritingLabelAttributesAndConfiguringWithBlock:nil];
    
    NSRange stringRange = NSMakeRange(0, mutableAttributedString.length);
    
    NSRegularExpression * const regexps[] = {kURLRegularExpression(),kPhoneNumerRegularExpression(),kEmailRegularExpression(),kAtRegularExpression(),kPoundSignRegularExpression(),self.customReplyRegularExpression?self.customReplyRegularExpression:kReplyRegularExpression()};
    
    NSMutableArray *results = [NSMutableArray array];
    
    NSUInteger maxIndex = self.isNeedReply?kURLActionCount:kURLActionCount-1;
    maxIndex = self.isNeedAtAndPoundSign?maxIndex:maxIndex-2;
    for (NSUInteger i=0; i<maxIndex; i++) {
        if (self.disableThreeCommon&&i<kURLActionCount-2) {
            continue;
        }
        NSString *urlAction = kURLActions[i];
        [regexps[i] enumerateMatchesInString:[mutableAttributedString string] options:0 range:stringRange usingBlock:^(NSTextCheckingResult *result, __unused NSMatchingFlags flags, __unused BOOL *stop) {
            
            //检查是否和之前记录的有交集，有的话则忽略
            for (NSTextCheckingResult *record in results){
                if (NSMaxRange(NSIntersectionRange(record.range, result.range))>0){
                    return;
                }
            }
            
            //添加链接
            NSString *actionString = [NSString stringWithFormat:@"%@%@",urlAction,[self.text substringWithRange:result.range]];
            
            //这里暂时用NSTextCheckingTypeCorrection类型的传递消息吧
            //因为有自定义的类型出现，所以这样方便点。
            NSTextCheckingResult *aResult = [NSTextCheckingResult correctionCheckingResultWithRange:result.range replacementString:actionString];
            
            [results addObject:aResult];
        }];
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    //这里直接调用父类私有方法，好处能内部只会setNeedDisplay一次。一次更新所有添加的链接
    [super performSelector:@selector(addLinksWithTextCheckingResults:attributes:) withObject:results withObject:self.linkAttributes];
#pragma clang diagnostic pop
    
}

#pragma mark - setter
- (void)setIsNeedAtAndPoundSign:(BOOL)isNeedAtAndPoundSign
{
    _isNeedAtAndPoundSign = isNeedAtAndPoundSign;
    self.emojiText = self.emojiText; //简单重新绘制处理下
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode
{
    [super setLineBreakMode:lineBreakMode];
    self.emojiText = self.emojiText; //简单重新绘制处理下
}

- (void)setDisableEmoji:(BOOL)disableEmoji
{
    _disableEmoji = disableEmoji;
    self.emojiText = self.emojiText; //简单重新绘制处理下
}

- (void)setDisableThreeCommon:(BOOL)disableThreeCommon
{
    _disableThreeCommon = disableThreeCommon;
    self.emojiText = self.emojiText; //简单重新绘制处理下
}

- (void)setCustomEmojiRegex:(NSString *)customEmojiRegex
{
    _customEmojiRegex = customEmojiRegex;
    
    if (customEmojiRegex && customEmojiRegex.length>0) {
        self.customEmojiRegularExpression = [[NSRegularExpression alloc] initWithPattern:customEmojiRegex options:NSRegularExpressionCaseInsensitive error:nil];
    }else{
        self.customEmojiRegularExpression = nil;
    }
    
    self.emojiText = self.emojiText; //简单重新绘制处理下
}

- (void)setCustomReplyRegex:(NSString *)customReplyRegex
{
    _customReplyRegex = customReplyRegex;
    
    if (customReplyRegex && customReplyRegex.length>0) {
        self.customReplyRegularExpression = [[NSRegularExpression alloc] initWithPattern:customReplyRegex options:NSRegularExpressionCaseInsensitive error:nil];
    }else{
        self.customReplyRegularExpression = nil;
    }
    
    self.emojiText = self.emojiText; //简单重新绘制处理下
}

#pragma mark - delegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTextCheckingResult:(NSTextCheckingResult *)result;
{
    if (result.resultType == NSTextCheckingTypeCorrection) {
        //判断消息类型
        for (NSUInteger i=0; i<kURLActionCount; i++) {
            if ([result.replacementString hasPrefix:kURLActions[i]]) {
                NSString *content = [result.replacementString substringFromIndex:kURLActions[i].length];
                if(self.emojiDelegate&&[self.emojiDelegate respondsToSelector:@selector(mlEmojiLabel:didSelectLink:withType:)]){
                    //type的数组和i刚好对应
                    [self.emojiDelegate mlEmojiLabel:self didSelectLink:content withType:i];
                }
            }
        }
    }
}

@end
