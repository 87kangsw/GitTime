//
//  RealmService.swift
//  GitTime
//
//  Created by Kanz on 05/10/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import RealmSwift
import RxSwift

protocol RealmServiceType {
    // Search History
    func addSearchText(text: String)
    func recentSearchTextList() -> Observable<[SearchHistory]>
    func removeSearchText(text: String)
    
    // Favorite Language
    func addFavoriteLanguage(_ language: Language)
    func removeFavoriteLanguage(_ language: FavoriteLanguage)
    func loadFavoriteLanguages() -> Observable<[FavoriteLanguage]>
}

class RealmService: RealmServiceType {
    
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
    func addFavoriteLanguage(_ language: Language) {
        do {
            let realm = try Realm(configuration: Realm.Configuration.defaultConfiguration)
            try realm.write {
                realm.create(FavoriteLanguage.self,
                             value: [
                                "id": language.id,
                                "name": language.name,
                                "color": language.color,
                                "type": language.type.rawValue
                ], update: Realm.UpdatePolicy.all)
            }
        } catch {
            log.error(error.localizedDescription)
        }
    }
    
    func removeFavoriteLanguage(_ language: FavoriteLanguage) {
        do {
            let realm = try Realm(configuration: Realm.Configuration.defaultConfiguration)
            let predicate = NSPredicate(format: "id == %d", language.id)
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
