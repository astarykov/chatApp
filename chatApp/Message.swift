//
//  Message.swift
//  chatApp
//
//  Created by Anton Starykov on 8/26/16.
//  Copyright © 2016 thestaryaprod. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    var text: String?
    var toId: String?
    var fromId: String?
    var timestamp: NSNumber?
    
    func chatPartnerId() -> String? {
        return fromId == FIRAuth.auth()?.currentUser?.uid ? toId: fromId
    }
}
