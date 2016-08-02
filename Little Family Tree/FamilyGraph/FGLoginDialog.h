/*
 * Copyright 2012 MyHeritage, Ltd.
 *
 * The Family Graph SDK is based on the Facebook iOS SDK:
 * Copyright 2011 Facebook, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */


#import "FGDialog.h"

@protocol FGLoginDialogDelegate;

/**
 * Do not use this interface directly, instead, use authorize in FamilyGraph.h
 *
 * FamilyGraph Login Dialog interface for start the familygraph webView login dialog.
 * It start pop-ups prompting for credentials and permissions.
 */

@interface FGLoginDialog : FGDialog {
  id<FGLoginDialogDelegate> _loginDelegate;
}

-(id) initWithURL:(NSString *) loginURL
      loginParams:(NSMutableDictionary *) params
      delegate:(id <FGLoginDialogDelegate>) delegate;
@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol FGLoginDialogDelegate <NSObject>

- (void)fgDialogLogin:(NSString*)token expirationDate:(NSDate*)expirationDate;

- (void)fgDialogNotLogin:(BOOL)cancelled;

@end


