//
//  LXTools.h
//  LXTestDemo
//
//  Created by 刘新新 on 2019/4/27.
//  Copyright © 2019 漫漫. All rights reserved.
//

#ifndef LXTools_h
#define LXTools_h
#define LXColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]

#define LXRandomColor LXColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256),1)
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self

#define LXCurrentVersion  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
#define LXNotificationCenter [NSNotificationCenter defaultCenter]
#define LXUserDefaults     [NSUserDefaults standardUserDefaults]

//自定义 log
#ifdef DEBUG
#define NSLog(format, ...) NSLog((@"[%@] [Line %d] " format), [[[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] componentsSeparatedByString:@"["][1] componentsSeparatedByString:@"]"][0], __LINE__, ##__VA_ARGS__)
#else
#define NSLog(...)
#endif


#import "NSString+Extension.h"
#import "UIButton+LXExpandBtn.h"
#import "UILabel+YBAttributeTextTapAction.h"
#endif /* LXTools_h */
