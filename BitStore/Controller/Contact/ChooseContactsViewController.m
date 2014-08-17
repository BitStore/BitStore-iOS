//
//  ChooseContactsViewController.m
//  BitStore
//
//  Created by Dylan Marriott on 17.06.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "ChooseContactsViewController.h"
#import "AddContactViewController.h"
#import "ContactListListener.h"
#import "ContactHelper.h"
#import "ChooseContactDelegate.h"
#import "Address.h"

@interface ChooseContactsViewController () <ContactListListener>
@end

@implementation ChooseContactsViewController {
    ContactList* _contactList;
}

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    self.title = l10n(@"choose_contact");
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1.0];
    [[ContactHelper instance] addContactListListener:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[PiwikTracker sharedInstance] sendViews:@"ContactsChoose", nil];
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = contact.label;
    cell.detailTextLabel.text = contact.address;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_delegate choseContact:[_contactList.contacts objectAtIndex:indexPath.row]];
}

@end
