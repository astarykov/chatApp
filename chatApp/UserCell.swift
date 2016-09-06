//
//  UserCell.swift
//  chatApp
//
//  Created by Anton Starykov on 8/29/16.
//  Copyright © 2016 thestaryaprod. All rights reserved.
//

import UIKit
import Firebase

class UserCell : UITableViewCell {
    
    var message: Message? {
        didSet {
            setName()
            detailTextLabel?.text = message?.text
            if let seconds = message?.timestamp?.doubleValue {
                let timestampDate = NSDate(timeIntervalSince1970: seconds)
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                timeLabel.text = dateFormatter.stringFromDate(timestampDate)
            }
        }
    }
    
    private func setName() {
        if let id = message?.chatPartnerId() {
            let ref = FIRDatabase.database().reference().child("users").child(id)
            ref.observeEventType(.Value, withBlock: { (snapshot) in
                if let dicrionary = snapshot.value as? [String: AnyObject] {
                    self.textLabel?.text = dicrionary["name"] as? String
                }
                }, withCancelBlock: nil)
        }
    }
    var timeLabel: UILabel = {
        let label = UILabel()
            label.font = UIFont.systemFontOfSize(12)
            label.textColor = UIColor.lightGrayColor()
            label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(timeLabel)
        
        timeLabel.rightAnchor.constraintEqualToAnchor(self.rightAnchor, constant: 10).active = true
        timeLabel.centerYAnchor.constraintEqualToAnchor(self.topAnchor, constant: 20).active = true
        timeLabel.widthAnchor.constraintEqualToConstant(100).active = true
        timeLabel.heightAnchor.constraintEqualToAnchor(textLabel?.heightAnchor).active = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}