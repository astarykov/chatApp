//
//  TableViewController.swift
//  chatApp
//
//  Created by Anton Starykov on 8/25/16.
//  Copyright © 2016 thestaryaprod. All rights reserved.
//

import UIKit
import Firebase

class TableViewController: UITableViewController {
    let cellId = "cellId"
    var messages = [Message]()
    var messageDictionary = [String: Message]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        tableView.registerClass(UserCell.self, forCellReuseIdentifier: cellId)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "new_message_icon"), style: .Plain, target: self, action: #selector(handleNewMessage))
        getUsersFromDb()
        setUpMessages()
    }
    
    func setUpMessages() {
        messages.removeAll()
        messageDictionary.removeAll()
        tableView.reloadData()
        observeUserMessages()
    }
    
    func observeUserMessages() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
        ref.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            let messageId = snapshot.key
            let messageRefference = FIRDatabase.database().reference().child("messages").child(messageId)
            messageRefference.observeEventType(.Value, withBlock: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let message = Message()
                    message.setValuesForKeysWithDictionary(dictionary)
                    
                    if let chatPartnerId = message.chatPartnerId() {
                        self.messageDictionary[chatPartnerId] = message
                        self.messages = Array(self.messageDictionary.values)
                        self.messages.sortInPlace({ (m1, m2) -> Bool in
                            return m1.timestamp?.intValue > m2.timestamp?.intValue
                        })
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                    })
                }
            }, withCancelBlock: nil)
        }, withCancelBlock: nil)
    }
    
    func handleNewMessage() {
        let newMessageController = MessageController()
        let navController = UINavigationController(rootViewController: newMessageController)
        presentViewController(navController, animated: true, completion: nil)
    }
    
    func getUsersFromDb() {
        if FIRAuth.auth()?.currentUser?.uid == nil {
            performSelector(#selector(handleLogout), withObject: nil, afterDelay: 0)
        } else {
            let uid = FIRAuth.auth()?.currentUser?.uid
            FIRDatabase.database().reference().child("users").child(uid!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.navigationItem.title = dictionary["name"] as? String
                }
            }, withCancelBlock: nil)
        }
        
    }
    
    func handleLogout() {
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logutError {
            print(logutError)
        }
        
        let loginCtrl = self.storyboard?.instantiateViewControllerWithIdentifier("loginCtrl")
        self.navigationController?.pushViewController(loginCtrl!, animated: true)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! UserCell
        let message = messages[indexPath.row]
        cell.message = message
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let message = messages[indexPath.row]
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        let ref = FIRDatabase.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            let user = User()
            user.id = chatPartnerId
            user.setValuesForKeysWithDictionary(dictionary)
            let chatCtrl = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
            chatCtrl.user = user
            self.navigationController?.pushViewController(chatCtrl, animated: true)
        }, withCancelBlock: nil)
    }
    
}