//
//  ReactiveExtensions.swift
//  RealmExample
//
//  Created by Tomas Kohout on 04/04/2017.
//  Copyright © 2017 Ackee. All rights reserved.
//

import Foundation
import ReactiveSwift
import RealmSwift

public enum Change<T> {
    typealias Element = T
    
    /// Initial value
    case initial(T)
    
    /// RealmCollection was updated
    case update(T, deletions: [Int], insertions: [Int], modifications: [Int])
}

/// Error return in case of Realm operation failure
public struct RealmError : Error {
    public let underlyingError: NSError
    public init(underlyingError: NSError){
        self.underlyingError = underlyingError
    }
}

extension Reactive where Base: RealmCollection {
    var changes: SignalProducer<Change<Base>, RealmError> {
        var notificationToken: NotificationToken? = nil
        
        return SignalProducer { sink, d in
            notificationToken = self.base.addNotificationBlock({ (changes) in
                switch changes {
                case .initial(let initial):
                    sink.send(value: Change.initial(initial))
                case .update(let updates, let deletions, let insertions, let modifications):
                    sink.send(value: Change.update(updates, deletions: deletions, insertions: insertions, modifications: modifications))
                case .error(let e):
                    sink.send(error: RealmError(underlyingError: e as NSError))
                }
            })
            }.on(disposed: {
                notificationToken?.stop()
            })
    }
    
    public var values: SignalProducer<Base, RealmError> {
        return self.changes.map { changes -> Base in
            switch changes {
            case .initial(let initial):
                return initial
            case .update(let updates, _, _, _):
                return updates
            }
        }
    }
}

/// Protocol which allows UITableView to be reloaded automatically when database changes happen
public protocol RealmTableViewReloading {
    associatedtype Element: Object
    var tableView: UITableView! { get set }
}

public extension Reactive where Base: UIViewController, Base: RealmTableViewReloading {
    
    /// Binding target which updates tableView according to received changes
    public var changes: BindingTarget<Change<Results<Base.Element>>> {
        return makeBindingTarget { vc, changes in
            guard let tableView = vc.tableView else { return }
            switch changes {
            case .initial:
                tableView.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.endUpdates()
                break
            }
        }
    }
}
