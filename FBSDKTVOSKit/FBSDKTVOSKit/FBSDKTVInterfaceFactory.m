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

#import "FBSDKTVInterfaceFactory.h"

#import <TVMLKit/TVElementFactory.h>

#import "FBSDKDeviceLoginButton.h"
#import "FBSDKTVLoginButtonElement.h"
#import "FBSDKTVLoginViewControllerElement.h"

static NSString *const FBSDKLoginButtonTag = @"FBSDKLoginButton";
static NSString *const FBSDKLoginViewControllerTag = @"FBSDKLoginViewController";

@implementation FBSDKTVInterfaceFactory
{
  id<TVInterfaceCreating> _interfaceCreator;
}

- (instancetype)initWithInterfaceCreator:(id<TVInterfaceCreating>)interfaceCreator
{
  if ((self = [super init])) {
    _interfaceCreator = interfaceCreator;
  }

  [TVElementFactory registerViewElementClass:[FBSDKTVLoginButtonElement class] forElementName:FBSDKLoginButtonTag];
  [TVElementFactory registerViewElementClass:[FBSDKTVLoginViewControllerElement class] forElementName:FBSDKLoginViewControllerTag];
  return self;
}

#pragma mark - TVInterfaceCreating

- (UIView *)viewForElement:(TVViewElement *)element
              existingView:(UIView *)existingView
{
  if ([element isKindOfClass:[FBSDKTVLoginButtonElement class]]) {
    FBSDKDeviceLoginButton *button = [[FBSDKDeviceLoginButton alloc] initWithFrame:CGRectZero];
    button.delegate = (FBSDKTVLoginButtonElement *)element;
    button.permissions = [self permissionsFromElement:element];
    button.redirectURL = [NSURL URLWithString:element.attributes[@"redirectURL"]];
    return button;
  }
  if ([_interfaceCreator respondsToSelector:@selector(viewForElement:existingView:)]) {
    return [_interfaceCreator viewForElement:element existingView:existingView];
  }
  return nil;
}

- (UIViewController *)viewControllerForElement:(TVViewElement *)element existingViewController:(UIViewController *)existingViewController
{
  if ([element isKindOfClass:[FBSDKTVLoginViewControllerElement class]]) {
    FBSDKDeviceLoginViewController *vc = [FBSDKDeviceLoginViewController new];
    vc.delegate = (FBSDKTVLoginViewControllerElement *)element;
    vc.permissions = [self permissionsFromElement:element];
    vc.redirectURL = [NSURL URLWithString:element.attributes[@"redirectURL"]];
    return vc;
  }
  if ([_interfaceCreator respondsToSelector:@selector(viewControllerForElement:existingViewController:)]) {
    return [_interfaceCreator viewControllerForElement:element existingViewController:existingViewController];
  }
  return nil;
}

- (NSURL *)URLForResource:(NSString *)resourceName
{
  if ([_interfaceCreator respondsToSelector:@selector(URLForResource:)]) {
    return [_interfaceCreator URLForResource:resourceName];
  }
  return nil;
}

- (NSArray<NSString *> *)permissionsFromElement:(TVViewElement *)element
{
  NSMutableArray<NSString *> *permissions = [NSMutableArray new];
  [permissions addObjectsFromArray:[element.attributes[@"permissions"] componentsSeparatedByString:@","]];
  [permissions addObjectsFromArray:[element.attributes[@"readPermissions"] componentsSeparatedByString:@","]];
  [permissions addObjectsFromArray:[element.attributes[@"publishPermissions"] componentsSeparatedByString:@","]];

  return permissions;
}

@end
