//
//  ChatMessageCell.swift
//  chatApp
//
//  Created by Anton Starykov on 8/30/16.
//  Copyright © 2016 thestaryaprod. All rights reserved.
//

import UIKit

class ChatMessageCell: UICollectionViewCell {
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFontOfSize(16)
        tv.editable = false
        tv.backgroundColor = UIColor.clearColor()
        tv.textColor = UIColor.whiteColor()
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    static let blueColor = UIColor(red: 0/255, green: 137/255, blue: 249/255, alpha: 1)
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = blueColor
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var bubbleWidthConstraint: NSLayoutConstraint?
    var bubbleLeftAnchor: NSLayoutConstraint?
    var bubbleRightAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubbleView)
        addSubview(textView)
        
        bubbleLeftAnchor = bubbleView.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 8)
        bubbleRightAnchor = bubbleView.rightAnchor.constraintEqualToAnchor(self.rightAnchor, constant: -8)
        bubbleRightAnchor?.active = true
        bubbleView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        bubbleWidthConstraint = bubbleView.widthAnchor.constraintEqualToConstant(200)
        bubbleWidthConstraint?.active = true
        bubbleView.heightAnchor.constraintEqualToAnchor(self.heightAnchor).active = true
        
        textView.leftAnchor.constraintEqualToAnchor(bubbleView.leftAnchor, constant: 8).active = true
        textView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        textView.rightAnchor.constraintEqualToAnchor(bubbleView.rightAnchor).active = true
        textView.heightAnchor.constraintEqualToAnchor(self.heightAnchor).active = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(code:) has not been implemented")
    }
    
}
