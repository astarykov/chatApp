//
//  MessageController.swift
//  chatApp
//
//  Created by Anton Starykov on 8/26/16.
//  Copyright © 2016 thestaryaprod. All rights reserved.
//

import UIKit
import Firebase

class MessageController: UITableViewController {
    let cellId = "cellId"
    var users = [User]()
    var messages = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(cancelMessageHandler))
        tableView.registerClass(UserCell.self, forCellReuseIdentifier: cellId)
        fetchUser()
    }

    func fetchUser() {
        FIRDatabase.database().reference().child("users").observeEventType(.ChildAdded, withBlock: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                user.email = dictionary["email"] as? String
                user.name = dictionary["name"] as? String
                user.id = snapshot.key
                self.users.append(user)
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            }
        }, withCancelBlock: nil)
    }
    
    func cancelMessageHandler() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //dismissViewControllerAnimated(true) {
            let user = self.users[indexPath.row]
            self.showChatCtrlForUser(user)
        //}
    }
    
    func showChatCtrlForUser(user: User) {
        let chatCtrl = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
            chatCtrl.user = user
        self.navigationController?.pushViewController(chatCtrl, animated: true)
    }
}
