//
//  Functions.h
//  VCell
//
//  Created by Aciid on 12/07/13.
//  Copyright (c) 2013 vcell. All rights reserved.
//


@protocol FetchJSONDelegate

- (void)fetchJSONDidCompleteWithJSONArray:(NSArray *)jsonData;

@end

#import <Foundation/Foundation.h>
#import "BiomodelViewController.h"
#import "MBProgressHUD.h"

@interface Functions : NSObject <MBProgressHUDDelegate>

//Construct a URL appending '&' on dict keys and objects
+ (NSString*)contructUrlParamsOnDict:(NSDictionary*)dict;

//Returns URL Parameter Dict from disk or save it to disk if it doesnt already
+ (NSMutableDictionary*)initURLParamDictWithFileName:(NSString*)fileName Keys:(NSArray*)keys AndObjects:(NSArray*)objects;

+ (void)scrollToFirstRowOfNewSectionsWithOldNumberOfSections:(NSIndexPath*)firstCellOfNewData tableView:(UITableView*)tableView;

@property (weak, nonatomic) id <FetchJSONDelegate> delegate;

//Makes a NSURLConnection request fetches data and shows HUD
- (void)fetchJSONFromURL:(NSURL*)url WithrowNum:(NSUInteger)rownum AddHUDToView:(UIView*)view delegate:(id)delegate;

//Delete all objects from Coredata
+ (void)deleteAllObjects:(NSString *) entityDescription inManagedObjectContext:(NSManagedObjectContext *) context;

@end
