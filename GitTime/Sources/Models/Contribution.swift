//
//  Contribution.swift
//  GitTime
//
//  Created by Kanz on 13/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

import Realm
import RealmSwift

struct Contribution: ModelType {
    let date: String
    let contribution: Int
    let hexColor: String
    
    enum CodingKeys: String, CodingKey {
        case date
        case contribution
        case hexColor
    }
}

class ContributionObject: RealmSwift.Object {
	@objc dynamic var _id = ObjectId.generate()
	@objc dynamic var date: String = ""
	@objc dynamic var contribution: Int = 0
	@objc dynamic var hexColor: String = ""
	
	override class func primaryKey() -> String? {
		return "_id"
	}
}

extension Contribution: RealmPersistable {
	public init(managedObject: ContributionObject) {
		date = managedObject.date
		contribution = managedObject.contribution
		hexColor = managedObject.hexColor
	}

	public func managedObject() -> ContributionObject {
		let contribution = ContributionObject()
		contribution.date = self.date
		contribution.contribution = self.contribution
		contribution.hexColor = self.hexColor
		return contribution
	}
}

// MARK: - ContributionInfo

struct ContributionInfo: ModelType {
    let count: Int
    let contributions: [Contribution]
	let userName: String
	let additionalName: String
	let profileImageURL: String
    
    enum CodingKeys: String, CodingKey {
        case count
        case contributions
		case userName
		case additionalName
		case profileImageURL
    }
}

class ContributionInfoObject: RealmSwift.Object {
	@objc dynamic var count: Int = 0
	@objc dynamic var userName: String = ""
	@objc dynamic var createdAt: Date = Date()
	@objc dynamic var additionalName: String = ""
	@objc dynamic var profileImageURL: String = ""
	@objc dynamic var updatedAt: Date?
	var contributions = List<ContributionObject>()
	
	override class func primaryKey() -> String? {
		return "additionalName"
	}
}

extension ContributionInfo: RealmPersistable {
	init(managedObject: ContributionInfoObject) {
		count = managedObject.count
		userName = managedObject.userName
		additionalName = managedObject.additionalName
		profileImageURL = managedObject.profileImageURL
		contributions = managedObject.contributions.toArray()
	}
	
	func managedObject() -> ContributionInfoObject {
		log.debug(#function)
		let contributionInfo = ContributionInfoObject()
		contributionInfo.count = self.count
		contributionInfo.userName = self.userName
		contributionInfo.additionalName = self.additionalName ?? ""
//		contributionInfo.contributions = self.contributions.map { $0.managedObject() }
		contributionInfo.createdAt = Date()
		return contributionInfo
	}
}
