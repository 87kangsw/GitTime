//
//  RealmPersistable.swift
//  GitTime
//
//  Created by Kanz on 2020/11/01.
//

import Realm
import RealmSwift

public protocol RealmPersistable {
	associatedtype ManagedObject: RealmSwift.Object
	init(managedObject: ManagedObject)
	func managedObject() -> ManagedObject
}
