#import "spawn.h"

@interface FBSystemService : NSObject
	+(id)sharedInstance;
	-(void)shutdownAndReboot:(BOOL)arg1;
	-(void)exitAndRelaunch:(BOOL)arg1;
@end

@interface UIView (QuitAll)
  - (id)_viewControllerForAncestor;
  - (id)_findNearestViewController;
@end

@interface SBDisplayItem: NSObject
	@property (nonatomic,copy,readonly) NSString * bundleIdentifier;               //@synthesize bundleIdentifier=_bundleIdentifier - In the implementation block
@end

@interface SBApplication : NSObject
	@property (nonatomic,readonly) NSString * bundleIdentifier;
	@property (nonatomic,readonly) NSString * displayName;
@end

@interface SBMediaController : NSObject
	@property (nonatomic, weak,readonly) SBApplication * nowPlayingApplication;
	+(id)sharedInstance;
@end

//interfaces
@interface SBMainSwitcherViewController: UIViewController
	+ (id)sharedInstance;
	-(id)recentAppLayouts;
	-(void)_deleteAppLayout:(id)arg1 forReason:(long long)arg2;
	-(void)_deleteAppLayoutsMatchingBundleIdentifier:(id)arg1;
@end

@interface SBAppLayout:NSObject
	-(id)itemForLayoutRole:(long long)arg1;
@end

@interface SBFluidSwitcherItemContainer : UIView
	-(void)quitAllApps:(bool)shouldSkipNowPlaying;
	-(void)SBReload;
	-(void)Respring;
	-(void)RebootUserspace;
	-(void)Reboot;
	-(void)SafeMode;
	-(void)UICache;
	-(void)LDRestart;
@end

%hook SBFluidSwitcherItemContainer

	- (void)scrollViewWillEndDragging: (UIScrollView *)arg1 withVelocity: (CGPoint)arg2 targetContentOffset: (CGPoint*)arg3
	{
		%orig;



		[self quitAllApps:YES];
	}


	%new
	-(void)quitAllApps:(bool)shouldSkipNowPlaying
	{
		//remove the apps
		SBMainSwitcherViewController *mainSwitcher = [%c(SBMainSwitcherViewController) sharedInstance];
		NSArray *items = [mainSwitcher recentAppLayouts];

		NSString *nowPlayingID = [[[%c(SBMediaController) sharedInstance] nowPlayingApplication] bundleIdentifier];

		for(SBAppLayout *item in items)
		{
			NSString *bundleID = [[item itemForLayoutRole:1] bundleIdentifier];

			if (shouldSkipNowPlaying && [bundleID isEqualToString: nowPlayingID])
				continue;
			else
			{
				if ([mainSwitcher respondsToSelector:@selector(_deleteAppLayout:forReason:)])
				{
					[mainSwitcher _deleteAppLayout:item forReason: 1];
				}
				else if ([mainSwitcher respondsToSelector:@selector(_deleteAppLayoutsMatchingBundleIdentifier:)])
				{
					[mainSwitcher _deleteAppLayoutsMatchingBundleIdentifier:bundleID];
				}
			}
		}

		dispatch_async(dispatch_get_main_queue(), ^{
				UINotificationFeedbackGenerator* _hapticFeedbackGenerator = [[UINotificationFeedbackGenerator alloc] init];
				[_hapticFeedbackGenerator prepare];
				[_hapticFeedbackGenerator notificationOccurred:UINotificationFeedbackTypeSuccess];
				_hapticFeedbackGenerator = nil;
		});
	}

%end
