//
//  PusherExampleMenuViewController.m
//  libPusher
//
//  Created by Luke Redpath on 14/08/2011.
//  Copyright 2011 LJR Software Limited. All rights reserved.
//

#import "PusherExampleMenuViewController.h"

@implementation PusherExampleMenuViewController

@synthesize pusher;

- (id)init
{
  if ((self = [super init])) {
    NSMutableArray *options = [NSMutableArray array];
    
    NSMutableDictionary *exampleOne = [NSMutableDictionary dictionary];
    [exampleOne setObject:@"Subscribe and trigger" forKey:@"name"];
    [exampleOne setObject:@"Subscribe to and trigger client events" forKey:@"description"];
    [exampleOne setObject:@"PusherEventsViewController" forKey:@"controllerClass"];
    [options addObject:exampleOne];
    
    menuOptions = [options copy];
  }
  return self;
}

- (void)dealloc 
{
  [menuOptions release];
  [super dealloc];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [menuOptions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"CellIdentifier";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
  }
  
  NSDictionary *example = [menuOptions objectAtIndex:indexPath.row];
  cell.textLabel.text = [example objectForKey:@"name"];
  cell.detailTextLabel.text = [example objectForKey:@"description"];
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSDictionary *example = [menuOptions objectAtIndex:indexPath.row];
  
  Class controllerClass = NSClassFromString([example objectForKey:@"controllerClass"]);
  NSAssert1(controllerClass, @"Controller class %@ does not exist! Typo?", [example objectForKey:@"controllerClass"]);
  
  UIViewController *viewController = [[controllerClass alloc] init];
  [self.navigationController pushViewController:viewController animated:YES];
  [viewController release];
}

@end
