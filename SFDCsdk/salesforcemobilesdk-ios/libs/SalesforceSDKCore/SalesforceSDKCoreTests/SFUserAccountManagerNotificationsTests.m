/*
 Copyright (c) 2017-present, salesforce.com, inc. All rights reserved.

 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <objc/runtime.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "SFUserAccountConstants.h"
#import "SFUserAccountManager+Internal.h"
#import "SFUserAccountPersisterEphemeral.h"
#import "SFOAuthCoordinator+Internal.h"
#import "SFOAuthCredentials+Internal.h"
#import "CSFNetwork+Internal.h"

static NSString * const kUserIdFormatString = @"005R0000000Dsl%lu";
static NSString * const kOrgIdFormatString = @"00D000000000062EA%lu";
static NSString * const kSFOAuthAccessToken = @"access_token";
static NSString * const kSFOAuthInstanceUrl = @"instance_url";
static NSString * const kSFOAuthCommunityId = @"sfdc_community_id";
static NSString * const kSFOAuthCommunityUrl = @"sfdc_community_url";

@interface CSFNetwork(SalesforceNetworkMock)
- (void)setupSalesforceObserver;
@property (nonatomic) void(^completionBlock)(BOOL) ;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@implementation CSFNetwork(SalesforceNetworkMock)
@dynamic completionBlock;
NSString const *key = @"completionBlockKey";

- (void) setCompletionBlock:(void (^)(BOOL))completionBlock {
     objc_setAssociatedObject(self, &key, [completionBlock copy], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (void (^)(BOOL)) completionBlock {
   return objc_getAssociatedObject(self, &key);
}

- (void)setupSalesforceObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userAccountManagerDidChangeUser:)
                                                 name:SFUserAccountManagerDidChangeUserNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userAccountManagerDidChangeUserData:)
                                                 name:SFUserAccountManagerDidChangeUserDataNotification
                                               object:nil];

}

- (void)removeSalesforceObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)userAccountManagerDidChangeUser:(NSNotification*)notification {
    SFUserAccountManager *accountManager = (SFUserAccountManager*)notification.object;
    SFUserAccountChange change = (SFUserAccountChange)[notification.userInfo[SFUserAccountManagerUserChangeKey] integerValue];
    
    if ([accountManager isKindOfClass:[SFUserAccountManager class]]
        && (change & SFUserAccountChangeCurrentUser)) {
        if ([accountManager.currentUserIdentity isEqual:self.account.accountIdentity] )
        {
            if (self.completionBlock)
                self.completionBlock(YES);
        }else {
            if (self.completionBlock)
                self.completionBlock(NO);
        }
    }
}

- (void)userAccountManagerDidChangeUserData:(NSNotification*)notification {
    SFUserAccount *userAccount = (SFUserAccount*)notification.object;
    SFUserAccountDataChange change = (SFUserAccountDataChange)[notification.userInfo[SFUserAccountManagerUserChangeKey] integerValue];
    if ([userAccount isKindOfClass:[SFUserAccount class]]) {
        if([self.account.accountIdentity isEqual:userAccount.accountIdentity]) {
            if (![userAccount.communityId isEqualToString:self.defaultConnectCommunityId])
            {
                if(self.completionBlock)
                    self.completionBlock(YES);
            }

            if(self.completionBlock)self.completionBlock(NO);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CSFDidChangeUserDataNotification"
                                                                object:self
                                                              userInfo:@{
                                                                         SFUserAccountManagerUserChangeKey: @(change),
                                                                         SFUserAccountManagerUserChangeUserKey: userAccount
                                                                         }];

        }
    }
}


@end

@interface MOCKCSFAction : CSFSalesforceAction
- (void)removeSalesforceObserver;
@property (nonatomic) void (^actionCompletionBlock)(BOOL,SFUserAccountDataChange);
@property (nonatomic, weak) CSFNetwork *enqueuedNetwork;

@end

@implementation MOCKCSFAction
@dynamic enqueuedNetwork;
@synthesize actionCompletionBlock = _actionCompletionBlock;

- (void)removeSalesforceObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didChangeUserDataNotification:(NSNotification*)notification {
    CSFNetwork *csfNetwork = (CSFNetwork*)notification.object;
    
    if ([csfNetwork isKindOfClass:[CSFNetwork class]]) {
        
        SFUserAccount *userAccount = notification.userInfo[SFUserAccountManagerUserChangeUserKey];

        SFUserAccountDataChange change = (SFUserAccountDataChange)[notification.userInfo[SFUserAccountManagerUserChangeKey] integerValue];
        
        if ([self requiresAuthentication] && [self.enqueuedNetwork.account.accountIdentity isEqual:userAccount.accountIdentity]) {
            if (change & SFUserAccountDataChangeCommunityId) {
                self.actionCompletionBlock(YES,change);
                return;
            }
            SFUserAccountDataChange credsChanged = SFUserAccountDataChangeInstanceURL | SFUserAccountDataChangeAccessToken;
            if ((change & credsChanged) == credsChanged) {
                self.actionCompletionBlock(YES,change);
                return;
            }
           
        }
    }
    self.actionCompletionBlock(NO,SFUserAccountDataChangeUnknown);
}
@end

@interface SFUserAccountManagerNotificationsTests : XCTestCase {
    id<SFUserAccountPersister> _origAccountPersister;
    SFUserAccount *_user;
    SFUserAccount *_origCurrentUser;
}
@property (nonatomic, strong) SFUserAccountManager *uam;

@end

@implementation SFUserAccountManagerNotificationsTests

- (void)setUp {
    [super setUp];
    self.uam = [SFUserAccountManager sharedInstance];
    _origAccountPersister = self.uam.accountPersister;
    _origCurrentUser = self.uam.currentUser;
    self.uam.accountPersister = [SFUserAccountPersisterEphemeral new];
    _user = [self createNewUser:1];
}

- (void)tearDown {
    [self deleteUserAndVerify:_user];
    self.uam.accountPersister = _origAccountPersister;
    self.uam.currentUser = _origCurrentUser;
    [super tearDown];
}

- (void)testNotificationNotPosted
{
    NSString *notificationName = SFUserAccountManagerDidChangeUserDataNotification;
    
    id observerMock = [OCMockObject observerMock];
    [[NSNotificationCenter defaultCenter] addMockObserver:observerMock name:notificationName object:self.uam];
    NSDictionary *credentials = @{
                                  
                                  };
    SFOAuthCoordinator *coordinator = [[SFOAuthCoordinator alloc] initWithCredentials:_user.credentials];
    SFAuthenticationManager * authenticationManager = [SFAuthenticationManager sharedManager];
    authenticationManager.coordinator = coordinator;
    
    [coordinator updateCredentials:credentials];
    XCTAssertTrue(coordinator.credentials.credentialsChangeSet==nil || [coordinator.credentials.credentialsChangeSet count] < 1,@"There should not be any changes to existing credentials");
    
    [self.uam applyCredentials:coordinator.credentials];
    
    [[NSNotificationCenter defaultCenter] removeObserver:observerMock];
}

- (void)testCommunityIdNotificationPosted
{
    NSString *notificationName = SFUserAccountManagerDidChangeUserDataNotification;
    
    id observerMock = [OCMockObject observerMock];
    [[NSNotificationCenter defaultCenter] addMockObserver:observerMock name:notificationName object:nil];
    
    SFOAuthCoordinator *coordinator = [[SFOAuthCoordinator alloc] initWithCredentials:_user.credentials];
    SFAuthenticationManager * authenticationManager = [SFAuthenticationManager sharedManager];
    authenticationManager.coordinator = coordinator;
    
    NSDictionary *expectedUserInfo = @{
                                       SFUserAccountManagerUserChangeKey: @(SFUserAccountDataChangeCommunityId)
                                       };
    
    [[observerMock expect] notificationWithName:notificationName object:_user userInfo:expectedUserInfo];
    
    NSDictionary *credentials = @{kSFOAuthCommunityId:@"COMMUNITY_ID"
                                  };
    
    [coordinator updateCredentials:credentials];
    XCTAssertTrue(coordinator.credentials.credentialsChangeSet!=nil && [coordinator.credentials.credentialsChangeSet count] > 0,@"There should not be at least one change in credentials");
    
    XCTAssertTrue([coordinator.credentials hasPropertyValueChangedForKey:@"communityId"],@"SFAuthenticationManager should detect change to properties");
    
    [self.uam applyCredentials:coordinator.credentials withIdData:nil];
    
    [observerMock verify];
    [[NSNotificationCenter defaultCenter] removeObserver:observerMock];
}

- (void)testInstanceUrlChangeNotificationPosted
{
    NSString *notificationName = SFUserAccountManagerDidChangeUserDataNotification;
    
    id observerMock = [OCMockObject observerMock];
    [[NSNotificationCenter defaultCenter] addMockObserver:observerMock name:notificationName object:nil];
    
    SFOAuthCoordinator *coordinator = [[SFOAuthCoordinator alloc] initWithCredentials:_user.credentials];
    SFAuthenticationManager * authenticationManager = [SFAuthenticationManager sharedManager];
    authenticationManager.coordinator = coordinator;
    
    NSDictionary *expectedUserInfo = @{
                                       SFUserAccountManagerUserChangeKey: @(SFUserAccountDataChangeInstanceURL)
                                       };
    
    [[observerMock expect] notificationWithName:notificationName object:_user userInfo:expectedUserInfo];
    
    NSDictionary *credentials = @{
                                  kSFOAuthInstanceUrl:@"https://new.instance.url"
                                  };
    
    [coordinator updateCredentials:credentials];
    XCTAssertTrue(coordinator.credentials.credentialsChangeSet!=nil && [coordinator.credentials.credentialsChangeSet count] > 0,@"There should be at least one change in credentials");
    
    XCTAssertTrue([coordinator.credentials hasPropertyValueChangedForKey:@"instanceUrl"],@"SFAuthenticationManager should detect change to instanceUrl");
    
    [self.uam applyCredentials:coordinator.credentials];
    
    [observerMock verify];
    [[NSNotificationCenter defaultCenter] removeObserver:observerMock];
}

- (void)testAccessTokenChangeNotificationPosted
{
    NSString *notificationName = SFUserAccountManagerDidChangeUserDataNotification;
    
    id observerMock = [OCMockObject observerMock];
    [[NSNotificationCenter defaultCenter] addMockObserver:observerMock name:notificationName object:nil];
    
    SFOAuthCoordinator *coordinator = [[SFOAuthCoordinator alloc] initWithCredentials:_user.credentials];
    SFAuthenticationManager * authenticationManager = [SFAuthenticationManager sharedManager];
    authenticationManager.coordinator = coordinator;
    
    NSDictionary *expecTedUserInfo = @{
                                       SFUserAccountManagerUserChangeKey: @(SFUserAccountDataChangeAccessToken)
                                       };
    
    [[observerMock expect] notificationWithName:notificationName object:_user userInfo:expecTedUserInfo];
    
    NSDictionary *credentials = @{
                                  kSFOAuthAccessToken:@"new_access_token"
                                  };
    
    [coordinator updateCredentials:credentials];
    
    XCTAssertTrue(coordinator.credentials.credentialsChangeSet!=nil && [coordinator.credentials.credentialsChangeSet count] > 0,@"There should be at least one change in credentials");
    
    XCTAssertTrue([coordinator.credentials hasPropertyValueChangedForKey:@"accessToken"],@"SFAuthenticationManager should detect change to instanceUrl");

    
    [self.uam applyCredentials:coordinator.credentials];
    
    [observerMock verify];
    [[NSNotificationCenter defaultCenter] removeObserver:observerMock];
}

- (void)testMultipleChangesNotificationPosted
{
    NSString *notificationName = SFUserAccountManagerDidChangeUserDataNotification;
    
    id observerMock = [OCMockObject observerMock];
    [[NSNotificationCenter defaultCenter] addMockObserver:observerMock name:notificationName object:nil];
    
    SFOAuthCoordinator *coordinator = [[SFOAuthCoordinator alloc] initWithCredentials:_user.credentials];
    SFAuthenticationManager * authenticationManager = [SFAuthenticationManager sharedManager];
    authenticationManager.coordinator = coordinator;
    SFUserAccountDataChange expectedChange = (SFUserAccountDataChangeCommunityId|SFUserAccountDataChangeInstanceURL|SFUserAccountDataChangeAccessToken);
    NSDictionary *expecTedUserInfo = @{
                                       SFUserAccountManagerUserChangeKey: @(expectedChange)                                       };
    
    [[observerMock expect] notificationWithName:notificationName object:_user userInfo:expecTedUserInfo];
    
    NSDictionary *credentials = @{
                                  kSFOAuthCommunityId:@"COMMUNITY_ID_1",
                                  kSFOAuthAccessToken:@"new_access_token_1",
                                  kSFOAuthInstanceUrl:@"https://new.instance.url1"
                                  };
    
    [coordinator updateCredentials:credentials];
    XCTAssertTrue(coordinator.credentials.credentialsChangeSet!=nil && [coordinator.credentials.credentialsChangeSet count] > 0,@"There should be at least one change in credentials");
    
    XCTAssertTrue([coordinator.credentials  hasPropertyValueChangedForKey:@"accessToken"],@"SFAuthenticationManager should detect change to accessToken");
    
     XCTAssertTrue([coordinator.credentials hasPropertyValueChangedForKey:@"communityId"],@"SFAuthenticationManager should detect change to communityId");
    
     XCTAssertTrue([coordinator.credentials hasPropertyValueChangedForKey:@"instanceUrl"],@"SFAuthenticationManager should detect change to instanceUrl");
    
    [self.uam applyCredentials:coordinator.credentials];
    
    [observerMock verify];
    [[NSNotificationCenter defaultCenter] removeObserver:observerMock];
}

- (void)testNewUserChangeNotificationPosted
{
    NSString *notificationName = SFUserAccountManagerDidChangeUserNotification;

    id observerMock = [OCMockObject observerMock];
    [[NSNotificationCenter defaultCenter] addMockObserver:observerMock name:notificationName object:self.uam];

    SFOAuthCredentials *newUsercredentials = [SFOAuthCredentials new];
    newUsercredentials.userId = [NSString stringWithFormat:kUserIdFormatString, (NSUInteger)2];
    newUsercredentials.organizationId =_user.credentials.organizationId;
    newUsercredentials.instanceUrl = [NSURL URLWithString:@"http://a.new.url"];
    newUsercredentials.communityId = @"NEW_COMMUNITY_ID";

    SFOAuthCoordinator *coordinator = [[SFOAuthCoordinator alloc] initWithCredentials:newUsercredentials];
    SFAuthenticationManager * authenticationManager = [SFAuthenticationManager sharedManager];
    authenticationManager.coordinator = coordinator;
    [[observerMock expect] notificationWithName:notificationName object:self.uam userInfo:[OCMArg any]];

    NSDictionary *credentials = @{
                                  kSFOAuthAccessToken:@"new_access_token_1"
                                  };

    [coordinator updateCredentials:credentials];
    [self.uam applyCredentials:coordinator.credentials];

    [observerMock verify];
    [[NSNotificationCenter defaultCenter] removeObserver:observerMock];
}

- (void)testNotficationReceivedForSetCurrentUserWithCSFNetwork {
    
    SFOAuthCredentials *credentials1 = [[SFOAuthCredentials alloc] initWithIdentifier:@"the-identifier"
                                                                            clientId:@"the-client"
                                                                           encrypted:NO
                                                                         storageType:SFOAuthCredentialsStorageTypeNone];

    SFOAuthCredentials *credentials2 = [[SFOAuthCredentials alloc] initWithIdentifier:@"the-identifier-1"
                                                                            clientId:@"the-client-1"
                                                                           encrypted:NO
                                                                         storageType:SFOAuthCredentialsStorageTypeNone];
    SFUserAccount *user1 = [[SFUserAccountManager sharedInstance]  createUserAccount:credentials1];
    user1.credentials.accessToken = @"AccessToken";
    user1.credentials.refreshToken = @"RefreshToken";
    user1.credentials.instanceUrl = [NSURL URLWithString:@"http://example.org"];
    user1.credentials.identityUrl = [NSURL URLWithString:@"https://example.org/id/orgID/userID"];
    user1.credentials.communityId = @"OLD_COMMUNITY_ID";
    NSError *error = nil;
    [[SFUserAccountManager sharedInstance] saveAccountForUser:user1 error:&error];
    XCTAssertNil(error);
   
    SFUserAccount *user2 = [[SFUserAccountManager sharedInstance]  createUserAccount:credentials2];
    user2.credentials.accessToken = @"AccessToken1";
    user2.credentials.refreshToken = @"RefreshToken1";
    user2.credentials.instanceUrl = [NSURL URLWithString:@"http://example1.org/"];
    user2.credentials.identityUrl = [NSURL URLWithString:@"https://example1.org/id/orgID/userID-1"];
    [[SFUserAccountManager sharedInstance] saveAccountForUser:user2 error:&error];

    XCTAssertNil(error);
    XCTestExpectation *expectation = [self expectationWithDescription:@"user changed"];
    
    CSFNetwork *network = [[CSFNetwork alloc] initWithUserAccount:user1];
    
    //[network setupSalesforceObserver];
    network.completionBlock = ^(BOOL communityIdChanged) {
         // ignore the communityIdChanged flag here only applies the for same user
        [expectation fulfill];
    };
   
    self.uam.currentUser = user2;
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        XCTAssertNil(error);
        [network removeSalesforceObserver];
    }];
    [self deleteUserAndVerify:user1];
    [self deleteUserAndVerify:user2];
    
}

- (void)testNotficationReceivedForCommunityIdChangeWithCSFNetwork {
   
    self.uam.currentUser = _user;

    XCTestExpectation *expectation = [self expectationWithDescription:@"user changed"];
    CSFNetwork *network = [[CSFNetwork alloc] initWithUserAccount:_user];
    network.defaultConnectCommunityId = @"OLD_COMMUNITY_ID";
    
    //[network setupSalesforceObserver];
    network.completionBlock = ^(BOOL communityIdChanged) {
        if (communityIdChanged)
            [expectation fulfill];
    };
    
    NSDictionary *credentials = @{
                                  kSFOAuthCommunityId:@"NEW_COMMUNITY_ID"                             };
    SFOAuthCoordinator *coordinator = [[SFOAuthCoordinator alloc] initWithCredentials:_user.credentials];
    [coordinator updateCredentials:credentials];

    [self.uam applyCredentials:_user.credentials];
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        XCTAssertNil(error);
        [network removeSalesforceObserver];
    }];
}

- (void) testNotficationReceivedForCredentialsChangeWithCSFAction {
    self.uam.currentUser = _user;
    XCTestExpectation *expectation = [self expectationWithDescription:@"user changed"];
    CSFNetwork *network = [[CSFNetwork alloc] initWithUserAccount:_user];
    network.defaultConnectCommunityId = @"OLD_COMMUNITY_ID";
    
    NSDictionary *credentials = @{
                                  kSFOAuthAccessToken:@"__CHANGED_ACCESS_TOKEN",
                                  kSFOAuthInstanceUrl:@"http://changed.instance.url"
                                  };
    SFOAuthCoordinator *coordinator = [[SFOAuthCoordinator alloc] initWithCredentials:_user.credentials];
    [coordinator updateCredentials:credentials];

    
    MOCKCSFAction *action = [MOCKCSFAction new];
    action.enqueuedNetwork = network;
    action.requiresAuthentication = YES;
    action.actionCompletionBlock = ^(BOOL success,SFUserAccountDataChange change) {
        if (change & (SFUserAccountDataChangeAccessToken|SFUserAccountDataChangeInstanceURL))
            [expectation fulfill];
    };
    
    [self.uam applyCredentials:_user.credentials];
    
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        XCTAssertNil(error);
        [network removeSalesforceObserver];
    }];
}

- (SFUserAccount*)createNewUser:(NSUInteger) index {
  
    SFOAuthCredentials *credentials = [[SFOAuthCredentials alloc]initWithIdentifier:[NSString stringWithFormat:@"identifier-%lu",index] clientId:@"fakeClientIdForTesting" encrypted:YES];
    
    credentials.accessToken = nil;
    credentials.refreshToken = nil;
    credentials.instanceUrl = nil;

    SFUserAccount *user =[[SFUserAccount alloc] initWithCredentials:credentials];
    NSString *userId = [NSString stringWithFormat:kUserIdFormatString, index];
    NSString *orgId = [NSString stringWithFormat:kOrgIdFormatString, index];
    credentials.communityId = orgId;
    credentials.userId = userId;
    
    user.credentials.identityUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://login.salesforce.com/id/%@/%@", orgId, userId]];
    
    NSError *saveAccountError = nil;
    [self.uam saveAccountForUser:user error:&saveAccountError];
    
    XCTAssertNil(saveAccountError, @"User Should have been created for Notifications Test");
    return user;
}

- (void)deleteUserAndVerify:(SFUserAccount *) user {
    SFUserAccountIdentity *identity = user.accountIdentity;
    NSError *deleteAccountError = nil;
    [self.uam deleteAccountForUser:user error:&deleteAccountError];
    XCTAssertNil(deleteAccountError, @"Error deleting account with User ID '%@' and Org ID '%@': %@", identity.userId, identity.orgId, [deleteAccountError localizedDescription]);
    SFUserAccount *inMemoryAccount = [self.uam userAccountForUserIdentity:identity];
    XCTAssertNil(inMemoryAccount, @"deleteUser should have removed user account with User ID '%@' and OrgID '%@' from the list of users.", identity.userId, identity.orgId);
}

@end
#pragma clang diagnostic pop
