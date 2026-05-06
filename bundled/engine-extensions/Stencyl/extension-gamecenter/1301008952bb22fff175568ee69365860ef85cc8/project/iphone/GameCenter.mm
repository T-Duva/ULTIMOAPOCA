#include <GameCenter.h>
#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import <GameKit/GameKit.h>


//NOTE:  These classes use some methods that are marked depricated as of IOS 7.  (e.g. presentModalViewController, etc..)
//       They are still functioning, but at sometime the code will have to be refactored.  For now they will generate
//       errors.  However they are still usable so I left them in to limit the amount of change/risk shorterm.


extern "C" void sendGameCenterEvent(const char* event, const char* data);

typedef void (*FunctionType)();

@interface GKViewDelegate : NSObject <GKAchievementViewControllerDelegate,GKLeaderboardViewControllerDelegate>
{
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController*)viewController;
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController*)viewController;

@property (nonatomic) FunctionType onAchievementFinished;
@property (nonatomic) FunctionType onLeaderboardFinished;

@end

@implementation GKViewDelegate

@synthesize onAchievementFinished;
@synthesize onLeaderboardFinished;

- (id)init 
{
    self = [super init];
    return self;
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController*)achViewController
{
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    [window.rootViewController dismissModalViewControllerAnimated:YES];
    
	onAchievementFinished();
}



- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController*)lbViewController
{
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    [window.rootViewController dismissModalViewControllerAnimated:YES];
    
    onLeaderboardFinished();
}

@end



namespace gamecenter 
{
    static int isInitialized = 0;
    GKViewDelegate* viewDelegate;
    
    //---
    
    //User
	void initializeGameCenter();
    bool isGameCenterAvailable();
	bool isUserAuthenticated();
    void authenticateLocalUser();
    
    const char* getPlayerName();
    const char* getPlayerID();
    
    //Leaderboards
    void showLeaderboard(const char* categoryID);
    void reportScore(const char* categoryID, int score);
    
    //Achievements
    void showAchievements();
    void resetAchievements();
    void reportAchievement(const char* achievementID, float percent);
    void showAchievementBanner(const char* title, const char* message);
    
    //Callbacks
    void registerForAuthenticationNotification();
    static void authenticationChanged(CFNotificationCenterRef center, void* observer, CFStringRef name, const void* object, CFDictionaryRef userInfo);
    
    void achievementViewDismissed();
	void leaderboardViewDismissed();

    //---
    
    //USER
    
	void initializeGameCenter() 
    {
	    if(isInitialized == 1)
        {
			return;
		}
        
		if(isGameCenterAvailable())
        {
            viewDelegate = [[GKViewDelegate alloc] init];
			viewDelegate.onAchievementFinished = &achievementViewDismissed;
			viewDelegate.onLeaderboardFinished = &leaderboardViewDismissed;
            
			isInitialized = 1;
            authenticateLocalUser();//JI slightly diff
            //JI diff not return bool
		}
    }
    
    bool isGameCenterAvailable()
    {
		Class gcClass = (NSClassFromString(@"GKLocalPlayer"));    
		NSString* reqSysVer = @"4.1";   
		NSString* currSysVer = [[UIDevice currentDevice] systemVersion];   
		BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);   
		
		return (gcClass && osVersionSupported);
	}
    
    bool isUserAuthenticated()
    {
		return ([GKLocalPlayer localPlayer].isAuthenticated);
	}
    
    void authenticateLocalUser() 
    {
        if(!isGameCenterAvailable())
        {
			return;
		}
		
		[[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) 
        {     
			if(error == nil)
            {
				registerForAuthenticationNotification();
				sendGameCenterEvent("auth-success", "");
			}
            
            else
            {
				sendGameCenterEvent("auth-failed", "");
			}
		}];
	}
    
    const char* getPlayerName()
    {
        GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
        
        if(localPlayer.isAuthenticated)
        {
            return [localPlayer.alias cStringUsingEncoding:NSUTF8StringEncoding];
        }
        
        else
        {
            return "";
        }
    }
    
    const char* getPlayerID()
    {
        GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
        
        if(localPlayer.isAuthenticated)
        {
            return [localPlayer.playerID cStringUsingEncoding:NSUTF8StringEncoding];
        }
        
        else
        {
            return "";
        }
    }
    
    //LEADERBOARDS
    
    void showLeaderboard(const char* categoryID)
    {
        @autoreleasepool {
            NSString* strCategory = [[NSString alloc] initWithUTF8String:categoryID];
    		
    		UIWindow* window = [UIApplication sharedApplication].keyWindow;
    		GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];  
    		
            if(leaderboardController != nil) 
            {
    			leaderboardController.category = strCategory;
    			leaderboardController.leaderboardDelegate = viewDelegate;
    			[window.rootViewController presentModalViewController:leaderboardController animated:YES];
    		}
        }
	}
    
    void reportScore(const char* categoryID, int score)
    {
        @autoreleasepool {
            NSString* strCategory = [[NSString alloc] initWithUTF8String:categoryID];
    		GKScore* scoreReporter = [[GKScore alloc] initWithCategory:strCategory];
            
    		if(scoreReporter)
            {
    			scoreReporter.value = score;
    			
    			[scoreReporter reportScoreWithCompletionHandler:^(NSError *error) 
                {   
    				if(error != nil)
                    {
    					NSLog(@"Game Center: Error occurred reporting score-");
    					NSLog(@"  %@", [error userInfo]);
    					sendGameCenterEvent("score-failed", categoryID);
    				}
                    
                    else
                    {
    					NSLog(@"Game Center: Score was successfully sent");
    					sendGameCenterEvent("score-success", categoryID);
    				}
    			}];   
    		}
        }
    }
    
    //ACHIEVEMENTS
    
    void showAchievements()
    {
        NSLog(@"Game Center: Show Achievements");
		UIWindow* window = [UIApplication sharedApplication].keyWindow;
		GKAchievementViewController* achievements = [[GKAchievementViewController alloc] init]; 
        
		if(achievements != nil)
        {
			achievements.achievementDelegate = viewDelegate;
			[window.rootViewController presentModalViewController: achievements animated:YES];
			//dispatchHaxeEvent(ACHIEVEMENTS_VIEW_OPENED);
		}
    }
    
    void resetAchievements()
    {
        [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error)
        {
            if(error != nil)
            {
                NSLog(@"  %@", [error userInfo]);
                sendGameCenterEvent("achieve-reset-failed", "");
            }
            
            else
            {
                 sendGameCenterEvent("achieve-reset-success", "");
            }
        }];
    }
    
    void reportAchievement(const char* achievementID, float percent)
    {
        @autoreleasepool {
            NSString* strAchievement = [[NSString alloc] initWithUTF8String:achievementID];
    		GKAchievement* achievement = [[GKAchievement alloc] initWithIdentifier:strAchievement];
            
    		if(achievement)
            {
            	/*if(percent >= 1)
            	{
            		achievement.showsCompletionBanner = YES;
            	}*/
            	
    			achievement.percentComplete = percent;    
    			[achievement reportAchievementWithCompletionHandler:^(NSError *error)
                {
    				if(error != nil)
                    {
    					NSLog(@"Game Center: Error occurred reporting achievement-");
    					NSLog(@"  %@", [error userInfo]);
    					sendGameCenterEvent("achieve-failed", achievementID);
    				}
                    
                    else
                    {
    					NSLog(@"Game Center: Achievement report successfully sent");
    					sendGameCenterEvent("achieve-success", achievementID);
    				}
                    
    			}];
    		}
            
            else 
            {
    			sendGameCenterEvent("achieve-failed", achievementID);
    		}
        }
    }
    
    void showAchievementBanner(const char* title, const char* message)
    {
    	NSString* t = [[NSString alloc] initWithUTF8String:title];
    	NSString* m = [[NSString alloc] initWithUTF8String:message];
    	
    	[GKNotificationBanner showBannerWithTitle:t message:m completionHandler:nil];
    }
    
    //CALLBACKS

    void registerForAuthenticationNotification()
    {
		// TODO: need to REMOVE OBSERVER on dispose
		CFNotificationCenterAddObserver
		(
        	CFNotificationCenterGetLocalCenter(),
         	NULL,
         	&authenticationChanged,
         	(CFStringRef)GKPlayerAuthenticationDidChangeNotificationName,
         	NULL,
         	CFNotificationSuspensionBehaviorDeliverImmediately
        );
	}
    
    void authenticationChanged(CFNotificationCenterRef center, void* observer, CFStringRef name, const void* object, CFDictionaryRef userInfo)
    {
		if(!isGameCenterAvailable())
        {
			return;
		}
		
		if([GKLocalPlayer localPlayer].isAuthenticated)
        {      
			NSLog(@"Game Center: You are logged in to game center.");
		}
        
        else
        {
			NSLog(@"Game Center: You are NOT logged in to game center.");
		}
	}
    
    void achievementViewDismissed()
    {
		//dispatchHaxeEvent(ACHIEVEMENTS_VIEW_CLOSED);
	}
	
	void leaderboardViewDismissed()
    {
		//dispatchHaxeEvent(LEADERBOARD_VIEW_CLOSED);
	}
}