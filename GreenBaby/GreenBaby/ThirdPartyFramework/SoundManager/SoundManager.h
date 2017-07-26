//
//  SoundManager.h
//  Puzzle
//
//  Created by Li XiangCheng on 12-10-9.
//
//

#import <Foundation/Foundation.h>
#import "CMOpenALSoundManager.h"

typedef enum {
	AUDIOEFFECT_beep
}mySoundIds;

//声音和音效管理
@interface SoundManager : NSObject{
    CMOpenALSoundManager *soundMgr;
}

@property (nonatomic, strong) CMOpenALSoundManager *soundMgr;

+(SoundManager*)shareInstance;

#pragma mark Action
- (void) setMusicVolume:(float) newVolume;//设置背景声音音量 0.0-1.0
- (void) setEffectsVolume:(float) newVolume;//设置音效音量 0.0-1.0
- (void) playSoundEffectsWithID:(mySoundIds) soundId;//播放音效
- (void) switchMusic;//开关背景声音

@end
