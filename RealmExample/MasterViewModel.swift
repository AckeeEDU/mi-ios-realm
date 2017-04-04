//
//  MasterViewModel.swift
//  RealmExample
//
//  Created by Tomas Kohout on 03/04/2017.
//  Copyright © 2017 Ackee. All rights reserved.
//

import Foundation
import RealmSwift
import Result
import class ReactiveSwift.Property
import class ReactiveSwift.Action
import struct ReactiveSwift.SignalProducer


class MasterViewModel {
    
    let realm = try! Realm()
    
    lazy var events: Property<Results<EventObject>?> = Property(initial: nil, then: self.realm.objects(EventObject.self).reactive.values.flatMapError { _ -> SignalProducer<Results<EventObject>, NoError> in .empty }.map { $0 })
    
    lazy var addStuff: ReactiveSwift.Action<Void, Void, NoError> = Action { [unowned self] _ in
        SignalProducer { sink, d in
            let event = EventObject()
            event.id = UUID().uuidString
            try! self.realm.write {
                self.realm.add(event)
            }
            sink.send(value: ())
            sink.sendCompleted()
        }
    }
    
    lazy var deleteStuff: Action<String, Void, NoError> = Action { [unowned self] id in
        SignalProducer { sink, d in
            if let event = self.realm.objects(EventObject.self).filter("id=%@", id).first {
                try! self.realm.write {
                    self.realm.delete(event)
                }
            }
            
            sink.send(value: ())
            sink.sendCompleted()
        }
    }
}
