//
//  SoundManager.m
//  Puzzle
//
//  Created by Li XiangCheng on 12-10-9.
//
//

#import "SoundManager.h"

@implementation SoundManager

SoundManager* gSoundManager=nil;

@synthesize soundMgr;

+ (SoundManager *)shareInstance {
	if (gSoundManager == nil) {
		gSoundManager = [[SoundManager alloc] init];
	}
	return gSoundManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
        // Create an instance of CMOpenALSoundManager.
        //start the audio manager...
        soundMgr = [[CMOpenALSoundManager alloc] init];
        soundMgr.soundFileNames = [NSArray arrayWithObjects:@"beep.wav",nil];//or .caf
        // start background music
        //[soundMgr playBackgroundMusic:@"bgSound.wav"]; // you could use forcePlay: YES if you wanted to stop any other audio source (iPod)　or .m4a
    }
    
    return self;
}

#pragma mark Action

- (void) setMusicVolume:(float) newVolume{
    soundMgr.backgroundMusicVolume = newVolume;
}

- (void) setEffectsVolume:(float) newVolume{
    soundMgr.soundEffectsVolume = newVolume;
}

- (void) playSoundEffectsWithID:(mySoundIds) soundId{
    // play our sound effect
    [soundMgr playSoundWithID:soundId];
}

- (void) switchMusic{
    if ([soundMgr isBackGroundMusicPlaying]){
        [soundMgr pauseBackgroundMusic];
    }
    else{
        [soundMgr resumeBackgroundMusic];
    }
}

@end
