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

 #import "FBSDKBridgeAPIProtocolWebV1.h"

 #import <UIKit/UIKit.h>

 #import "FBSDKCoreKitBasicsImport.h"
 #import "FBSDKError+Internal.h"
 #import "FBSDKInternalUtility+Internal.h"

 #define FBSDK_BRIDGE_API_PROTOCOL_WEB_V1_ACTION_ID_KEY @"action_id"
 #define FBSDK_BRIDGE_API_PROTOCOL_WEB_V1_BRIDGE_ARGS_KEY @"bridge_args"

@implementation FBSDKBridgeAPIProtocolWebV1

 #pragma mark - FBSDKBridgeAPIProtocol

- (NSURL *)requestURLWithActionID:(NSString *)actionID
                           scheme:(NSString *)scheme
                       methodName:(NSString *)methodName
                    methodVersion:(NSString *)methodVersion
                       parameters:(NSDictionary<NSString *, id> *)parameters
                            error:(NSError *__autoreleasing *)errorRef
{
  if (![FBSDKTypeUtility coercedToStringValue:actionID] || ![FBSDKTypeUtility coercedToStringValue:methodName]) {
    return nil;
  }
  NSMutableDictionary<NSString *, id> *queryParameters = [[NSMutableDictionary alloc] initWithDictionary:parameters];
  [FBSDKTypeUtility dictionary:queryParameters setObject:@"touch" forKey:@"display"];
  NSString *bridgeArgs = [FBSDKBasicUtility JSONStringForObject:@{ FBSDK_BRIDGE_API_PROTOCOL_WEB_V1_ACTION_ID_KEY : actionID }
                                                          error:NULL
                                           invalidObjectHandler:NULL];
  NSDictionary<NSString *, id> *redirectQueryParameters = @{ FBSDK_BRIDGE_API_PROTOCOL_WEB_V1_BRIDGE_ARGS_KEY : bridgeArgs };
  NSURL *redirectURL = [FBSDKInternalUtility.sharedUtility appURLWithHost:@"bridge"
                                                                     path:methodName
                                                          queryParameters:redirectQueryParameters
                                                                    error:NULL];
  [FBSDKTypeUtility dictionary:queryParameters setObject:redirectURL forKey:@"redirect_uri"];
  [queryParameters addEntriesFromDictionary:parameters];
  return [FBSDKInternalUtility.sharedUtility facebookURLWithHostPrefix:@"m"
                                                                  path:[@"/dialog/" stringByAppendingString:methodName]
                                                       queryParameters:queryParameters
                                                                 error:NULL];
}

- (NSDictionary<NSString *, id> *)responseParametersForActionID:(NSString *)actionID
                                                queryParameters:(NSDictionary<NSString *, id> *)queryParameters
                                                      cancelled:(BOOL *)cancelledRef
                                                          error:(NSError *__autoreleasing *)errorRef
{
  if (errorRef != NULL) {
    *errorRef = nil;
  }
  NSInteger errorCode = [FBSDKTypeUtility integerValue:queryParameters[@"error_code"]];
  switch (errorCode) {
    case 0: {
      // good to go, handle the other codes and bail
      break;
    }
    case 4201: {
      return @{
        @"completionGesture" : @"cancel",
      };
    }
    default: {
      if (errorRef != NULL) {
        *errorRef = [FBSDKError errorWithCode:errorCode
                                      message:[FBSDKTypeUtility coercedToStringValue:queryParameters[@"error_message"]]];
      }
      return nil;
    }
  }

  NSError *error;
  NSString *bridgeParametersJSON = [FBSDKTypeUtility coercedToStringValue:queryParameters[FBSDK_BRIDGE_API_PROTOCOL_WEB_V1_BRIDGE_ARGS_KEY]];
  NSDictionary<id, id> *bridgeParameters = [FBSDKBasicUtility objectForJSONString:bridgeParametersJSON error:&error];
  if (!bridgeParameters) {
    if (error && (errorRef != NULL)) {
      *errorRef = [FBSDKError invalidArgumentErrorWithName:FBSDK_BRIDGE_API_PROTOCOL_WEB_V1_BRIDGE_ARGS_KEY
                                                     value:bridgeParametersJSON
                                                   message:nil
                                           underlyingError:error];
    }
    return nil;
  }
  NSString *responseActionID = bridgeParameters[FBSDK_BRIDGE_API_PROTOCOL_WEB_V1_ACTION_ID_KEY];
  responseActionID = [FBSDKTypeUtility coercedToStringValue:responseActionID];
  if (![responseActionID isEqualToString:actionID]) {
    return nil;
  }
  NSMutableDictionary<NSString *, id> *resultParameters = [queryParameters mutableCopy];
  [resultParameters removeObjectForKey:FBSDK_BRIDGE_API_PROTOCOL_WEB_V1_BRIDGE_ARGS_KEY];
  resultParameters[@"didComplete"] = @YES;
  return resultParameters;
}

@end

#endif
