//
//  MasterViewModel.swift
//  RealmExample
//
//  Created by Tomas Kohout on 03/04/2017.
//  Copyright © 2017 Ackee. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

class MasterViewModel {
    
    lazy var addStuff: Action<Void, Void, NoError> = Action { [unowned self] _ in
        return .empty
    }
    
    lazy var deleteStuff: Action<Int, Void, NoError> = Action { [unowned self] index in
        return .empty
    }
}
