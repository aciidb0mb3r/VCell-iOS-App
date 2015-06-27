/*
 * Copyright (C) 1999-2011 University of Connecticut Health Center
 *
 * Licensed under the MIT License (the "License").
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *
 *  http://www.opensource.org/licenses/mit-license.php
 */

#import "LoginViewController.h"
#import <CommonCrypto/CommonDigest.h>

@interface LoginViewController ()
{
    AccessToken *accessToken;
}
@property UITapGestureRecognizer *tapToHide;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if([[NSUserDefaults standardUserDefaults] objectForKey:USERPASSKEY]) {
        UITabBarController *tabBarController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainTabBarContoller"];
        [self presentViewController:tabBarController animated:NO completion:nil];
    }
    
    _tapToHide = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    _tapToHide.cancelsTouchesInView = NO; // Will ensure that cell selection takes place when tapped
    [self.tableView addGestureRecognizer:_tapToHide];
}

- (void)hideKeyboard
{
    [_usernameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
}

- (NSString*)sha1:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (int)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return [output uppercaseString];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 1 && indexPath.row == 0) //Login btn
    {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?user_id=%@&user_password=%@",ACCESS_TOKEN_URL,self.usernameTextField.text,[self sha1:self.passwordTextField.text]]];
        NSLog(@"%@",url);
        [[[Functions alloc] init] fetchJSONFromURL:url HUDTextMode:NO AddHUDToView:self.view delegate:self disableTokenMode:YES];
    }
    if(indexPath.section == 1 && indexPath.row == 2)
    {
        [self performSegueWithIdentifier:@"loggedIn" sender:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"loggedIn"])
    {
        if (!IS_PHONE)
        {
            UITabBarController *tabBar = [segue destinationViewController];
            UISplitViewController *splitViewController = (UISplitViewController *)[tabBar.viewControllers objectAtIndex:0];
            splitViewController.delegate = (id)[splitViewController.viewControllers lastObject];
        }
    }
}


- (void)fetchJSONDidCompleteWithJSONArray:(NSArray *)jsonData function:(Functions *)function
{
    if(jsonData == nil) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Wrong User/Pass" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }
    else {
   
        [AccessToken setSharedInstance:[[AccessToken alloc] initWithDict:(NSDictionary*)jsonData]];
        
        NSLog(@"Got token: %@",[[AccessToken sharedInstance] token]);
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:[NSArray arrayWithObjects:self.usernameTextField.text,[self sha1:self.passwordTextField.text], nil] forKey:USERPASSKEY];
        [userDefaults synchronize];
        
        [self performSegueWithIdentifier:@"loggedIn" sender:nil];
    }
}

+ (void)logoutFrom:(UIViewController *)view
{
    [AccessToken setSharedInstance:nil];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    [Functions deleteAllObjects:BIOMODEL_ENTITY inManagedObjectContext:appDelegate.managedObjectContext withOwner:nil];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:USERPASSKEY];
    [userDefaults synchronize];
    
    LoginViewController *loginViewController = [view.storyboard instantiateInitialViewController];
    
    [view presentViewController:loginViewController animated:YES completion:nil];
}

@end
