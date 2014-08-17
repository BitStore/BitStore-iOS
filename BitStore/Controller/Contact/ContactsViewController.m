//
//  ContactsViewController.m
//  BitStore
//
//  Created by Dylan Marriott on 16.06.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "ContactsViewController.h"
#import "AddContactViewController.h"
#import "ContactListListener.h"
#import "ContactHelper.h"
#import "ContactDetailViewController.h"
#import "Address.h"

@interface ContactsViewController () <ContactListListener>
@end

@implementation ContactsViewController {
    ContactList* _contactList;
}

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    self.title = l10n(@"contacts");
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1.0];
    
    UIBarButtonItem* addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)];
    self.navigationItem.rightBarButtonItem = addItem;
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    [[ContactHelper instance] addContactListListener:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[PiwikTracker sharedInstance] sendViews:@"Contacts", nil];
}

- (void)add:(id)sender {
    AddContactViewController* vc = [[AddContactViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)contactListChanged:(ContactList *)contactList {
    _contactList = contactList;
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _contactList.contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Address* contact = [_contactList.contacts objectAtIndex:indexPath.row];
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@""];
    cell.textLabel.text = contact.label;
    cell.detailTextLabel.text = contact.address;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[ContactHelper instance] removeContactAtIndex:indexPath.row];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Address* contact = [_contactList.contacts objectAtIndex:indexPath.row];
    ContactDetailViewController* vc = [[ContactDetailViewController alloc] initWithAddress:contact];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
