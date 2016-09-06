//
//  ChatLogController.swift
//  chatApp
//
//  Created by Anton Starykov on 8/26/16.
//  Copyright © 2016 thestaryaprod. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout
{
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    var messages = [Message]()
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message ..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    func observeMessages() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(uid)
        userMessagesRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            let messageId = snapshot.key
            let messagesRef = FIRDatabase.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                let message = Message()
                message.setValuesForKeysWithDictionary(dictionary)
                if message.chatPartnerId() == self.user?.id {
                    self.messages.append(message)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.collectionView?.reloadData()
                    })
                }
                }, withCancelBlock: nil)
            }, withCancelBlock: nil)
    }

    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.automaticallyAdjustsScrollViewInsets = false;
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.whiteColor()
        collectionView?.registerClass(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        setupInputComponents()
        keyboardObserver()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardObserver() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func handleKeyboardWillShow(notification: NSNotification) {
        let keyBoardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue()
        let keyBoardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue
        containerViewBottomAnchor?.constant = -keyBoardFrame!.height

        UIView.animateWithDuration(keyBoardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func handleKeyboardWillHide(notification: NSNotification) {
        let keyBoardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue
        containerViewBottomAnchor?.constant = 0
        UIView.animateWithDuration(keyBoardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellId, forIndexPath: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        cell.bubbleWidthConstraint?.constant = estimateFrameForText(message.text!).width + 32
        setupCell(cell, message)
        return cell
    }
    
    private func setupCell(cell: ChatMessageCell, _ message: Message) {
        if message.fromId == FIRAuth.auth()?.currentUser?.uid {
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.bubbleRightAnchor?.active = true
            cell.bubbleLeftAnchor?.active = false
        } else {
            cell.bubbleView.backgroundColor = UIColor.lightGrayColor()
            cell.bubbleRightAnchor?.active = false
            cell.bubbleLeftAnchor?.active = true
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var height = CGFloat(80)
        if let text = messages[indexPath.item].text {
            height = estimateFrameForText(text).height + 20
        }
        return CGSize(width: view.frame.width, height: height)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    private func estimateFrameForText (text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.UsesFontLeading.union(.UsesLineFragmentOrigin)
        return NSString(string: text).boundingRectWithSize(size, options: options, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(16)], context: nil)
    }
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    func setupInputComponents() {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.whiteColor()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        // ios 9+ constraints
        
        containerView.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
        containerViewBottomAnchor = containerView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor)
        containerViewBottomAnchor?.active = true
        containerView.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
        containerView.heightAnchor.constraintEqualToConstant(50).active = true
        
        let sendButton = UIButton(type: .System)
            sendButton.setTitle("Send", forState: .Normal)
            sendButton.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(sendButton)
        // send button constrains
        
        sendButton.rightAnchor.constraintEqualToAnchor(containerView.rightAnchor).active = true
        sendButton.centerYAnchor.constraintEqualToAnchor(containerView.centerYAnchor).active = true
        sendButton.widthAnchor.constraintEqualToConstant(80).active = true
        sendButton.heightAnchor.constraintEqualToAnchor(containerView.heightAnchor).active = true
        // send button action
        
        sendButton.addTarget(self, action: #selector(sendMessageHandler), forControlEvents: .TouchUpInside)
        
        containerView.addSubview(inputTextField)
        
        // input constraints
        
        inputTextField.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor, constant: 5).active = true
        inputTextField.centerYAnchor.constraintEqualToAnchor(containerView.centerYAnchor).active = true
        inputTextField.rightAnchor.constraintEqualToAnchor(sendButton.leftAnchor).active = true
        inputTextField.heightAnchor.constraintEqualToAnchor(containerView.heightAnchor).active = true
        
        //bottom separator
        
        let separator = UIView()
            separator.backgroundColor = UIColor.lightGrayColor()
            separator.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(separator)
            //constarints
        
        separator.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor).active = true
        separator.bottomAnchor.constraintEqualToAnchor(containerView.topAnchor).active = true
        separator.widthAnchor.constraintEqualToAnchor(containerView.widthAnchor).active = true
        separator.heightAnchor.constraintEqualToConstant(1).active = true
    }

    func sendMessageHandler() {
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let messageReciever = user!.id!
        let messageSender = FIRAuth.auth()!.currentUser!.uid
        let timestamp: NSNumber = Int(NSDate().timeIntervalSince1970)
        let values = ["text": inputTextField.text!, "toId": messageReciever, "fromId": messageSender, "timestamp": timestamp]
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error)
                return
            }
            let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(messageSender)
            let messageId = childRef.key
            let recipientUserMessageRef = FIRDatabase.database().reference().child("user-messages").child(messageReciever)
            recipientUserMessageRef.updateChildValues([messageId: 1])
            userMessagesRef.updateChildValues([messageId: 1])
            
            self.inputTextField.text = nil
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        sendMessageHandler()
        return true
    }
    
    
    
    
    
    
    
    

}
