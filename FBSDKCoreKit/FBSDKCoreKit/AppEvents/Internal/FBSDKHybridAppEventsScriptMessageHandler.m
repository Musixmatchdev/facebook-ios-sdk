// Copyright (c) 2014-present, Facebook, Inc. All rights reserved.
//
// You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
// copy, modify, and distribute this software in source code or binary form for use
// in connection with the web services and APIs provided by Facebook.
//
// As with any software that integrates with the Facebook platform, your use of
// this software is subject to the Facebook Developer Principles and Policies
// [http://developers.facebook.com/policy/]. This copyright notice shall be
// included in all copies or substantial portions of the software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "TargetConditionals.h"

#if !TARGET_OS_TV

 #import "FBSDKHybridAppEventsScriptMessageHandler.h"

 #import "FBSDKAppEvents+EventLogging.h"
 #import "FBSDKAppEvents+Internal.h"
 #import "FBSDKCoreKitBasicsImport.h"
 #import "FBSDKEventLogging.h"

NSString *const FBSDKAppEventsWKWebViewMessagesPixelReferralParamKey = @"_fb_pixel_referral_id";

@protocol FBSDKEventLogging;
@class WKUserContentController;

@interface FBSDKHybridAppEventsScriptMessageHandler ()

@property (nonatomic) id<FBSDKEventLogging> eventLogger;

@end

@implementation FBSDKHybridAppEventsScriptMessageHandler

- (instancetype)init
{
  return [self initWithEventLogger:FBSDKAppEvents.singleton];
}

- (instancetype)initWithEventLogger:(id<FBSDKEventLogging>)eventLogger
{
  if ((self = [super init])) {
    _eventLogger = eventLogger;
  }
  return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
  if ([message.name isEqualToString:FBSDKAppEventsWKWebViewMessagesHandlerKey]) {
    NSDictionary<NSString *, id> *body = [FBSDKTypeUtility dictionaryValue:message.body];
    if (!body) {
      return;
    }
    NSString *event = body[FBSDKAppEventsWKWebViewMessagesEventKey];
    if ([event isKindOfClass:NSString.class] && (event.length > 0)) {
      NSString *stringedParams = [FBSDKTypeUtility stringValueOrNil:body[FBSDKAppEventsWKWebViewMessagesParamsKey]];
      NSMutableDictionary<NSString *, id> *params = nil;
      NSError *jsonParseError = nil;
      if (stringedParams) {
        params = [FBSDKTypeUtility JSONObjectWithData:[stringedParams dataUsingEncoding:NSUTF8StringEncoding]
                                              options:NSJSONReadingMutableContainers
                                                error:&jsonParseError
        ];
      }
      NSString *pixelID = body[FBSDKAppEventsWKWebViewMessagesPixelIDKey];
      if (pixelID == nil) {
        [FBSDKAppEventsUtility logAndNotify:@"Can't bridge an event without a referral Pixel ID. Check your webview Pixel configuration."];
        return;
      }
      if (jsonParseError != nil || ![params isKindOfClass:[NSDictionary<NSString *, id> class]] || params == nil) {
        [FBSDKAppEventsUtility logAndNotify:@"Could not find parameters for your Pixel request. Check your webview Pixel configuration."];
        params = [@{FBSDKAppEventsWKWebViewMessagesPixelReferralParamKey : pixelID} mutableCopy];
      } else {
        [FBSDKTypeUtility dictionary:params setObject:pixelID forKey:FBSDKAppEventsWKWebViewMessagesPixelReferralParamKey];
      }
      [self.eventLogger logInternalEvent:event
                              parameters:params
                      isImplicitlyLogged:NO];
    }
  }
}

@end

#endif
