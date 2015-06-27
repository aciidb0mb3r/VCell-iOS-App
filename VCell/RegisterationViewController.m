/*
 * Copyright (C) 1999-2011 University of Connecticut Health Center
 *
 * Licensed under the MIT License (the "License").
 * You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *
 *  http://www.opensource.org/licenses/mit-license.php
 */

#import "RegisterationViewController.h"

@interface RegisterationViewController ()

@property UITapGestureRecognizer *tapToHide;

@end

@implementation RegisterationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tapToHide = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    _tapToHide.cancelsTouchesInView = NO; // Will ensure that cell selection takes place when tapped
    [self.tableView addGestureRecognizer:_tapToHide];

}

- (void)hideKeyboard
{
    [_usernameTF resignFirstResponder];
    [_passwordTF resignFirstResponder];
    [_rePasswordTF resignFirstResponder];
    [_firstNameTF resignFirstResponder];
    [_lastNameTF resignFirstResponder];
    [_emailTF resignFirstResponder];
    [_institutionTF resignFirstResponder];
    [_countryTF resignFirstResponder];
}
//-(void)tableClicked
//{
//    [self.usernameTF resignFirstResponder];
//    [self.passwordTF resignFirstResponder];
//    [self.rePasswordTF resignFirstResponder];
//    [self.firstNameTF resignFirstResponder];
//    [self.lastNameTF resignFirstResponder];
//    [self.emailTF resignFirstResponder];
//    [self.institutionTF resignFirstResponder];
//    [self.countryTF resignFirstResponder];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkFieldsWithError:(NSError**)error
{
    NSMutableDictionary *details = [NSMutableDictionary dictionary];
    NSArray *requiredFields = [NSArray arrayWithObjects:self.usernameTF,
                               self.passwordTF,
                               self.rePasswordTF,
                               self.firstNameTF,
                               self.lastNameTF,
                               self.emailTF, nil];
    
    if(self.usernameTF.text.length < 4)
    {
        [details setValue:@"User id must be at least 4 characters." forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:ERRORDOMAIN code:200 userInfo:details];
        return;
    }
    
    NSCharacterSet *alphaSet = [NSCharacterSet alphanumericCharacterSet];
    if(![[self.usernameTF.text stringByTrimmingCharactersInSet:alphaSet] isEqualToString:@""])
    {
        [details setValue:@"User id must be only alpha-numeric characters." forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:ERRORDOMAIN code:200 userInfo:details];
        return;
    }
    
    if(self.passwordTF.text.length < 5)
    {
        [details setValue:@"Password must be at least 5 characters and must not contains spaces, commas, or quotes" forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:ERRORDOMAIN code:200 userInfo:details];
        return;
    }
    
    if(![[self.passwordTF.text stringByTrimmingCharactersInSet:alphaSet] isEqualToString:@""])
    {
        [details setValue:@"Password must not contains spaces, commas, or quotes." forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:ERRORDOMAIN code:200 userInfo:details];
        return;
    }
    
    for(NSInteger i=0;i< requiredFields.count;i++)
        if([[[requiredFields objectAtIndex:i] text] length] == 0)
        {
            [details setValue:@"Please Fill All Required Fields." forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:ERRORDOMAIN code:200 userInfo:details];
            return;
        }
    
    if(![self.passwordTF.text isEqualToString:self.rePasswordTF.text])
    {
        [details setValue:@"Please enter same value for password in both fields." forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:ERRORDOMAIN code:200 userInfo:details];
        return;
    }
    
    if(![self validateEmail:self.emailTF.text])
    {
        [details setValue:@"Please enter a valid email address." forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:ERRORDOMAIN code:200 userInfo:details];
        return;
    }
}

- (BOOL)validateEmail:(NSString *)candidate
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:candidate];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
    [[tableView cellForRowAtIndexPath:indexPath] setHighlighted:NO animated:YES];
    if(indexPath.section == REGISTER_BTN_SECTION && indexPath.row == REGISTER_BTN_ROW) //Register Btn Pressed
    {
        NSError *error = nil;
        [self checkFieldsWithError:&error];
        if(error)
        {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            return;
        }
        [self performRegisterRequest];
    }
    else if(indexPath.section == NOTIFY_BTN_SECTION && indexPath.row == NOTIFY_BTN_ROW) //Notify Btn Pressed
        self.NotifyTF.accessoryType = (self.NotifyTF.accessoryType == UITableViewCellAccessoryCheckmark) ? UITableViewCellAccessoryNone:UITableViewCellAccessoryCheckmark;
}

- (void)performRegisterRequest
{
    NSMutableString *postBody = [NSMutableString string];

    NSString *appendFormat = @"%@=%@&";
    
    [postBody appendFormat:appendFormat,@"newuserid",self.usernameTF.text];
    
    [postBody appendFormat:appendFormat,@"newpassword1",self.passwordTF.text];
    
    [postBody appendFormat:appendFormat,@"newpassword2",self.rePasswordTF.text];
    
    [postBody appendFormat:appendFormat,@"newfirstname",self.firstNameTF.text];
    
    [postBody appendFormat:appendFormat,@"newlastname",self.lastNameTF.text];
    
    [postBody appendFormat:appendFormat,@"newemail",self.emailTF.text];
    
    [postBody appendFormat:appendFormat,@"newinstitute",self.institutionTF.text];
    
    [postBody appendFormat:appendFormat,@"newcountry",self.countryTF.text];
    
    [postBody appendFormat:appendFormat,@"newnotify", self.NotifyTF.accessoryType == UITableViewCellAccessoryCheckmark ? @"on":@"off" ];
    
    [postBody appendFormat:appendFormat,@"newform",@"yes"];
       
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?client_id=%@",REGISTER_URL,CLIENT_ID]];
        
    NSMutableURLRequest *urlReq = [NSMutableURLRequest requestWithURL:url];
    [urlReq setHTTPMethod:@"POST"];
    [urlReq setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
    [NSURLConnection sendAsynchronousRequest:urlReq queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if(response)
         {
             
             NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
             
             if([httpResponse statusCode] != 201)
                 [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Server Side Error, Try resgistering from VCell desktop client" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            else
            {    [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Please click the link in your email id." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                
                [self.navigationController popViewControllerAnimated:YES];
        
            }
         }
     }];
}

- (void)viewDidUnload {
    [self setUsernameTF:nil];
    [self setPasswordTF:nil];
    [self setRePasswordTF:nil];
    [self setFirstNameTF:nil];
    [self setLastNameTF:nil];
    [self setEmailTF:nil];
    [self setInstitutionTF:nil];
    [self setCountryTF:nil];
    [self setNotifyTF:nil];
    [super viewDidUnload];
}

@end
