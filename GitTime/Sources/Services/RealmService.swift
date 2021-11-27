//
//  RealmService.swift
//  GitTime
//
//  Created by Kanz on 05/10/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import RealmSwift
import RxSwift
import SwiftUI

protocol RealmServiceType {
    // Search History
    func addSearchText(text: String)
    func recentSearchTextList() -> Observable<[SearchHistory]>
    func removeSearchText(text: String)
    
    // Favorite Language
    func addFavoriteLanguage(_ language: GithubLanguage)
    func removeFavoriteLanguage(_ language: FavoriteLanguage)
    func loadFavoriteLanguages() -> Observable<[FavoriteLanguage]>
	
	// Buddys
	func checkIfExist(additionalName: String) -> Observable<Bool>
	func addBuddy(userName: String, additionalName: String?, profileURL: String, contribution: [Contribution]) -> Observable<ContributionInfoObject>
	func removeBuddy(_ buddy: ContributionInfoObject)
	func loadBuddys() -> Observable<[ContributionInfoObject]>
}

class RealmService: RealmServiceType {
	
	var disposeBag = DisposeBag()
	
	static let schemaVersion: UInt64 = 1
	
	init() {
		migration()
	}
	
	func migration() {
		let config = Realm.Configuration(schemaVersion: RealmService.schemaVersion, migrationBlock: { migration, oldSchemaVersion in
			if oldSchemaVersion < RealmService.schemaVersion {
				
				let languageService = LanguagesService()
				languageService.getLanguageList()
					.subscribe(onNext: { languages in
						migration.enumerateObjects(ofType: FavoriteLanguage.className()) { oldObject, newObject in
							if let filterLanguage = languages.first(where: { $0.name == oldObject!["name"] as? String}) {
								newObject!["color"] = filterLanguage.color
							}
						}
					})
					.disposed(by: self.disposeBag)
			}
		})

		Realm.Configuration.defaultConfiguration = config
	}
	
    // MARK: - Search History
    func addSearchText(text: String) {
        do {
            let realm = try Realm()
            try realm.write {
                //                realm.add(newItem)
                realm.create(SearchHistory.self,
                             value: [
                                "text": text,
                                "createdAt": Date()
                    ],
                             update: Realm.UpdatePolicy.all)
            }
        } catch {
            log.error(error.localizedDescription)
        }
    }
    
    func recentSearchTextList() -> Observable<[SearchHistory]> {
        do {
            let realm = try Realm()
            let lists = realm.objects(SearchHistory.self)
                .sorted(byKeyPath: "createdAt", ascending: false)
                .toArray(ofType: SearchHistory.self)
            return Observable.just(lists)
        } catch {
            log.error(error.localizedDescription)
            return .empty()
        }
    }
    
    func removeSearchText(text: String) {
        do {
            let realm = try Realm()
            let predicate = NSPredicate(format: "text == %@", text)
            let results = realm.objects(SearchHistory.self).filter(predicate)
            
            try realm.write {
                realm.delete(results)
            }
        } catch {
            log.error(error.localizedDescription)
        }
    }
    
    // MARK: Favorite Lanuages
    func addFavoriteLanguage(_ language: GithubLanguage) {
        do {
            let realm = try Realm(configuration: Realm.Configuration.defaultConfiguration)
            try realm.write {
                realm.create(FavoriteLanguage.self,
                             value: [
                                "name": language.name,
                                "color": language.color
                ], update: Realm.UpdatePolicy.all)
            }
        } catch {
            log.error(error.localizedDescription)
        }
    }
    
    func removeFavoriteLanguage(_ language: FavoriteLanguage) {
        do {
            let realm = try Realm(configuration: Realm.Configuration.defaultConfiguration)
            let predicate = NSPredicate(format: "name == %@", language.name)
            let results = realm.objects(FavoriteLanguage.self).filter(predicate)
            
            try realm.write {
                realm.delete(results)
            }
        } catch {
            log.error(error.localizedDescription)
        }
    }
    
    func loadFavoriteLanguages() -> Observable<[FavoriteLanguage]> {
        do {
            let realm = try Realm(configuration: Realm.Configuration.defaultConfiguration)
            let result = realm.objects(FavoriteLanguage.self)
                .toArray(ofType: FavoriteLanguage.self)
            return Observable.just(result)
        } catch {
            log.error(error.localizedDescription)
            return .empty()
        }
    }
	
	// MARK: Buddy
	func checkIfExist(additionalName: String) -> Observable<Bool> {
		return Observable.create { observer -> Disposable in
			
			do {
				let realm = try Realm(configuration: Realm.Configuration.defaultConfiguration)
				let predicate = NSPredicate(format: "additionalName == %@", additionalName)
				let results = realm.objects(ContributionInfoObject.self).filter(predicate)
				
				observer.onNext(results.isEmpty == false)
				observer.onCompleted()
				
			} catch {
				log.error(error.localizedDescription)
				observer.onError(RealmError.insertError)
			}
			
			return Disposables.create {
				
			}
		}
	}
	
	func addBuddy(userName: String, additionalName: String?, profileURL: String, contribution: [Contribution]) -> Observable<ContributionInfoObject> {
		return Observable.create { observer -> Disposable in
			
			do {
				let realm = try Realm(configuration: Realm.Configuration.defaultConfiguration)
				try realm.write {
					/*
					let count: Int
					let contributions: [Contribution]
					let userName: String
					let additionalName: String?
					let profileImageURL: String
					*/
					
					let managedObjects = contribution.map { $0.managedObject() }
					let result = realm.create(ContributionInfoObject.self,
											  value: [
												"count": 0,
												"userName": userName,
												"additionalName": additionalName ?? "",
												"profileImageURL": profileURL,
												"contributions": managedObjects,
												"updatedAt": Date()
											  ], update: .all)
					observer.onNext(result)
					observer.onCompleted()
				}
			} catch {
				log.error(error.localizedDescription)
				observer.onError(RealmError.insertError)
			}
			
			return Disposables.create { }
		}
	}
	
	func removeBuddy(_ buddy: ContributionInfoObject) {
		do {
			let realm = try Realm(configuration: Realm.Configuration.defaultConfiguration)
			let predicate = NSPredicate(format: "additionalName == %@", buddy.additionalName)
			let results = realm.objects(ContributionInfoObject.self).filter(predicate)
			
			try realm.write {
				realm.delete(results)
			}
		} catch {
			log.error(error.localizedDescription)
		}
	}
	
	func loadBuddys() -> Observable<[ContributionInfoObject]> {
		do {
			let realm = try Realm(configuration: Realm.Configuration.defaultConfiguration)
			let result = realm.objects(ContributionInfoObject.self)
				.sorted(byKeyPath: "createdAt", ascending: true)
				.toArray(ofType: ContributionInfoObject.self)
			return .just(result)
		} catch {
			log.error(error.localizedDescription)
			return .empty()
		}
	}
}

extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        var array = [T]()
        for i in 0 ..< count {
            if let result = self[i] as? T {
                array.append(result)
            }
        }
        return array
    }
}

enum RealmError: Error {
	case insertError
}

extension RealmCollection {
	func toArray<T>() -> [T] {
		return self.compactMap { $0 as? T }
	}
}
