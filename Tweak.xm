#import "spawn.h"

@interface FBSystemService : NSObject
	+(id)sharedInstance;
	-(void)shutdownAndReboot:(BOOL)arg1;
	-(void)exitAndRelaunch:(BOOL)arg1;
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
	-(void)Reboot;
	-(void)SafeMode;
	-(void)UICache;
	-(void)LDRestart;
@end

%hook SBFluidSwitcherItemContainer

	- (void)scrollViewWillEndDragging: (UIScrollView *)arg1 withVelocity: (CGPoint)arg2 targetContentOffset: (CGPoint*)arg3
	{
		%orig;

		if (arg1.contentOffset.y <= -140)
		{
			UIAlertController * alert = [UIAlertController
									alertControllerWithTitle:@"QuitAll"
									message:@"What would you like to do?"
									preferredStyle:UIAlertControllerStyleActionSheet];

			UIAlertAction* killAllButton = [UIAlertAction
		                              actionWithTitle:@"Kill All Apps"
		                              style:UIAlertActionStyleDestructive
		                              handler:^(UIAlertAction * action) {

																		SBApplication* nowPlayingApp = [[%c(SBMediaController) sharedInstance] nowPlayingApplication];

																		if (nowPlayingApp)
																		{
																			NSString *message = [NSString stringWithFormat:@"'%@' seems to be playing Media. Do you want to kill it alongwith other apps?",[nowPlayingApp displayName]];
																			UIAlertController * confirmAlert = [UIAlertController
																									alertControllerWithTitle:@"QuitAll"
																									message:message
																									preferredStyle:UIAlertControllerStyleAlert];

																			UIAlertAction* killButton = [UIAlertAction
																																	actionWithTitle:@"Kill"
																																	style:UIAlertActionStyleDestructive
																																	handler:^(UIAlertAction * action) {
																																				[self quitAllApps:NO];
																								}];

																			UIAlertAction* dontKillButton = [UIAlertAction
																																	actionWithTitle:@"Don't Kill"
																																	style:UIAlertActionStyleDefault
																																	handler:^(UIAlertAction * action) {
																																				[self quitAllApps:YES];
																								}];


																			[confirmAlert addAction:killButton];
																			[confirmAlert addAction:dontKillButton];

																			[[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:confirmAlert animated:YES completion:nil];
																		}
																		else
																			[self quitAllApps:NO];

								}];

			UIAlertAction* powerOptionButton = [UIAlertAction
		                              actionWithTitle:@"Power Options..."
		                              style:UIAlertActionStyleDestructive
		                              handler:^(UIAlertAction * action) {

																		UIAlertController * powerAlert = [UIAlertController
																								alertControllerWithTitle:@"Power Options"
																								message:@"What would you like to do?"
																								preferredStyle:UIAlertControllerStyleActionSheet];

																		UIAlertAction* sbReloadButton = [UIAlertAction
																	                              actionWithTitle:@"SBReload"
																	                              style:UIAlertActionStyleDestructive
																	                              handler:^(UIAlertAction * action) {
																																			[self SBReload];
																							}];

																		UIAlertAction* respringButton = [UIAlertAction
																	                              actionWithTitle:@"Respring"
																	                              style:UIAlertActionStyleDestructive
																	                              handler:^(UIAlertAction * action) {
																																			[self Respring];
																							}];

																		// UIAlertAction* ldRestartButton = [UIAlertAction
																	  //                             actionWithTitle:@"LDRestart"
																	  //                             style:UIAlertActionStyleDestructive
																	  //                             handler:^(UIAlertAction * action) {
																		// 																	[self LDRestart];
																		// 					}];

																		UIAlertAction* rebootButton = [UIAlertAction
																	                              actionWithTitle:@"Reboot"
																	                              style:UIAlertActionStyleDestructive
																	                              handler:^(UIAlertAction * action) {
																																			[self Reboot];
																							}];

																		UIAlertAction* uiCacheButton = [UIAlertAction
																	                              actionWithTitle:@"UICache"
																	                              style:UIAlertActionStyleDestructive
																	                              handler:^(UIAlertAction * action) {
																																			[self UICache];
																							}];


																		UIAlertAction* safeModeButton = [UIAlertAction
																	                              actionWithTitle:@"SafeMode"
																	                              style:UIAlertActionStyleDestructive
																	                              handler:^(UIAlertAction * action) {
																																			[self SafeMode];
																							}];


																		UIAlertAction* cancelButton = [UIAlertAction
																						actionWithTitle:@"Cancel"
																						style:UIAlertActionStyleCancel
																						handler:^(UIAlertAction * action) {
																						}];

																		[powerAlert addAction:rebootButton];
																		//[powerAlert addAction:ldRestartButton];
																		[powerAlert addAction:uiCacheButton];
																		[powerAlert addAction:safeModeButton];
																		[powerAlert addAction:respringButton];
																		[powerAlert addAction:sbReloadButton];
																		[powerAlert addAction:cancelButton];

																		[[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:powerAlert animated:YES completion:nil];
								}];

			UIAlertAction* cancelButton = [UIAlertAction
							actionWithTitle:@"Cancel"
							style:UIAlertActionStyleCancel
							handler:^(UIAlertAction * action) {
							}];

			[alert addAction:powerOptionButton];
		  [alert addAction:killAllButton];
			[alert addAction:cancelButton];

			[[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alert animated:YES completion:nil];
		}

	}

	%new
	-(void)UICache {
		pid_t pid;
		const char* args[] = {"uicache", NULL, NULL};
		posix_spawn(&pid, "/usr/bin/uicache", NULL, NULL, (char* const*)args, NULL);
	}

	%new
	-(void)Respring {
		// pid_t pid;
		// const char* args[] = {"killall", "-9", "SpringBoard", NULL, NULL};
		// posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
		[[objc_getClass("FBSystemService") sharedInstance] exitAndRelaunch:1];
	}

	%new
	-(void)SBReload {
		pid_t pid;
		const char* args[] = {"sbreload", NULL, NULL, NULL, NULL};
		posix_spawn(&pid, "/usr/bin/sbreload", NULL, NULL, (char* const*)args, NULL);
	}

	// %new
	// -(void)LDRestart {
	// 	pid_t pid;
	// 	int status;
	// 	const char *args[] = {"_ldrestart", NULL};
	// 	posix_spawn(&pid, "/usr/bin/_ldrestart", NULL, NULL, (char * const *)args, NULL);
	// 	waitpid(pid, &status, WEXITED);
	// }

	%new
	-(void)Reboot {
		[[objc_getClass("FBSystemService") sharedInstance] shutdownAndReboot:1];
	}

	%new
	-(void)SafeMode {
		pid_t pid;
		const char* args[] = {"killall", "-SEGV", "SpringBoard", NULL};
		posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
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
