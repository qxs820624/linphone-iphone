/* UIEditableTableViewCell.m
 *
 * Copyright (C) 2012  Belledonne Comunications, Grenoble, France
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#import "UIContactDetailsCell.h"
#import "PhoneMainView.h"

@implementation UIContactDetailsCell

#pragma mark - Lifecycle Functions

- (id)initWithIdentifier:(NSString *)identifier {
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier]) != nil) {
		NSArray *arrayOfViews =
			[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];

		// resize cell to match .nib size. It is needed when resized the cell to
		// correctly adapt its height too
		UIView *sub = ((UIView *)[arrayOfViews objectAtIndex:0]);
		[self setFrame:CGRectMake(0, 0, sub.frame.size.width, sub.frame.size.height)];
		[self addSubview:sub];
	}
	return self;
}

#pragma mark - UITableViewCell Functions

- (void)hideDeleteButton {
	CGRect newFrame = _editTextfield.frame;
	newFrame.size.width += _deleteButton.frame.size.width;
	_editTextfield.frame = newFrame;

	_deleteButton.hidden = YES;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];

	_defaultView.hidden = editing;
	_editView.hidden = !editing;
}

- (void)setEditing:(BOOL)editing {
	[self setEditing:editing animated:FALSE];
}

- (IBAction)onCallClick:(id)event {
	LinphoneAddress *addr = linphone_core_interpret_url([LinphoneManager getLc], _addressLabel.text.UTF8String);
	if (addr == NULL)
		return;
	char *lAddress = linphone_address_as_string_uri_only(addr);
	NSString *displayName = [FastAddressBook displayNameForAddress:addr];

	DialerView *view = VIEW(DialerView);
	[PhoneMainView.instance changeCurrentView:view.compositeViewDescription];
	[view call:[NSString stringWithUTF8String:lAddress] displayName:displayName];
	ms_free(lAddress);
	linphone_address_destroy(addr);
}

- (IBAction)onChatClick:(id)event {
	LinphoneAddress *addr = linphone_core_interpret_url([LinphoneManager getLc], _addressLabel.text.UTF8String);
	if (addr == NULL)
		return;
	[PhoneMainView.instance changeCurrentView:ChatsListView.compositeViewDescription];
	ChatConversationView *view = VIEW(ChatConversationView);
	[PhoneMainView.instance changeCurrentView:view.compositeViewDescription push:TRUE];
	LinphoneChatRoom *room = linphone_core_get_chat_room([LinphoneManager getLc], addr);
	[view setChatRoom:room];
	linphone_address_destroy(addr);
}

- (IBAction)onDeleteClick:(id)sender {
	UITableView *tableView = VIEW(ContactDetailsView).tableController.tableView;
	NSIndexPath *indexPath = [tableView indexPathForCell:self];
	[tableView.dataSource tableView:tableView
				 commitEditingStyle:UITableViewCellEditingStyleDelete
				  forRowAtIndexPath:indexPath];
}

@end
