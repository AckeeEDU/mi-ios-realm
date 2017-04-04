//
//  Event.swift
//  RealmExample
//
//  Created by Tomas Kohout on 04/04/2017.
//  Copyright © 2017 Ackee. All rights reserved.
//

import Foundation
import RealmSwift


class EventObject: Object {
    dynamic var id = ""
    dynamic var date: Date = Date()
}
