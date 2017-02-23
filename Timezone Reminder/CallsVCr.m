//
//  CallsTVCr.m
//  Timezone Reminder
//
//  Created by Alexander on 17.02.17.
//  Copyright © 2017 AlexanderStepanishin. All rights reserved.
//

#import "CallsVCr.h"
#import "AppDelegate.h"

@interface CallsVCr ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

-(void) configureCell: (UITableViewCell*) cell atIndexPath: (NSIndexPath*) indexPath;

@end

@implementation CallsVCr
{
    NSFetchedResultsController *frController;
}

- (void)viewDidLoad {
    NSLog(@"[CallsVCr viewDidLoad:]");
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    AppDelegate *delegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    NSManagedObjectContext* viewContext = delegate.persistentContainer.viewContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Call"];
    request.predicate = nil;
    NSSortDescriptor *dateSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"userDate" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:dateSortDescriptor]];
    frController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                       managedObjectContext:viewContext
                                                         sectionNameKeyPath:nil
                                                                  cacheName:nil];
    frController.delegate = self;
    NSError *fetchError;
    if (![frController performFetch:&fetchError]){
        NSLog(@"Error while fetching by frController: %@", fetchError.userInfo);
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = 0;
    NSLog(@"sections: %lu", [[frController sections] count]);
    sections = [[frController sections] count];
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[frController sections] objectAtIndex:section];
    NSInteger rows = [sectionInfo numberOfObjects];
    NSLog(@"rows: %lu", rows);
    return rows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"call cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


-(void) configureCell: (UITableViewCell*) cell atIndexPath: (NSIndexPath*) indexPath
{
    Call *call = [frController objectAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:@"call cell"]){
#warning make outputs look convinient
        ((CallTVCell*) cell).titleLabel.text = call.textInfo;
        ((CallTVCell*) cell).dateLabel.text = [call.userDate description];
        ((CallTVCell*) cell).timeLabel.text = [call.userDate description];
    }
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"add call"]){
        CallVCr *callVCr = (CallVCr*)[segue destinationViewController];
        callVCr.isNewCall = YES;
        
    } else if ([segue.identifier isEqualToString:@"show call"]) {
        CallVCr *callVCr = (CallVCr*)[segue destinationViewController];
        callVCr.isNewCall = NO;
        CallTVCell *chosenCell = (CallTVCell*) sender;
        callVCr.callToEdit = [frController objectAtIndexPath:[self.tableView indexPathForCell:chosenCell]];
    }
}


#pragma mark NSFetchedResultsController delegate
/*
 Assume self has a property 'tableView' -- as is the case for an instance of a UITableViewController
 subclass -- and a method configureCell:atIndexPath: which updates the contents of a given cell
 with information from a managed object at the given index path in the fetched results controller.
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end
