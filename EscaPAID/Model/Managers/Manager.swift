//
//  Manager.swift
//  EscaPAID
//
//  Created by Michael Miller on 6/19/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit
import FirebaseDatabase

class Manager: NSObject {
    static let databaseRef = Database.database().reference().child(Config.databasePrefix);
}
