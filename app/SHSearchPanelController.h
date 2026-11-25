#import <AppKit/AppKit.h>
#import "SHQueryController.h"
#import "SHUsage.h"
#import "SHClipboard.h"
// A pasteboard type on each copy Ultrahound makes, so the clipboard history can name Ultrahound as the source.
extern NSString *const SHOwnCopyType;
@interface SHSearchPanelController : NSWindowController
// action: open, reveal, openWith, or trash; see SHResultActions.
@property(nonatomic,copy) void (^openResult)(NSDictionary *result,NSString *action,NSURL *application);
@property(nonatomic,strong) SHUsage *usage;
@property(nonatomic,strong) SHClipboard *clipboard;
// The menu bar menu; the logo and name in the footer open it.
@property(nonatomic,strong) NSMenu *appMenu;
- (instancetype)initWithQueries:(SHQueryController *)queries;
- (void)toggle;
// Shows the panel with the clipboard history only; Return pastes into the app that was in front.
- (void)toggleHistory;
// YES while a search location is still indexing, so a query without matches says that more can come.
@property(nonatomic) BOOL indexing;
- (void)updateSnapshot:(SHSearchSnapshot *)snapshot status:(NSString *)status;
- (void)showError:(NSString *)error;
@end
