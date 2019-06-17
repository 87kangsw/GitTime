//
//  LanguagesService.swift
//  GitTime
//
//  Created by Kanz on 24/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

import RxCocoa
import RxSwift

protocol LanguagesServiceType: class {
    func languageListByType(_ type: LanguageTypes) -> Observable<[Language]>
    func searchLanguage(searchText: String) -> Observable<[Language]>
}

final class LanguagesService: LanguagesServiceType {
    
    private var info: [String: String] {
        guard let plistPath = Bundle.main.path(forResource: "Languages", ofType: "plist"),
            let plist = NSDictionary(contentsOfFile: plistPath) as? [String: String] else {
                return [:]
        }
        return plist
    }
    
    private var allDatas: BehaviorRelay<[Language]> = BehaviorRelay(value: [])
    
    init() {
        fetchData()
    }
    
    fileprivate func fetchData() {
        
        guard let plistPath = Bundle.main.path(forResource: "Languages", ofType: "plist"),
            let data = FileManager.default.contents(atPath: plistPath) else { return }
        
        let decoder = PropertyListDecoder()
        let languages = try? decoder.decode([Language].self, from: data)
        allDatas.accept(languages ?? [])
    }
    
    func languageListByType(_ type: LanguageTypes) -> Observable<[Language]> {
        guard !allDatas.value.isEmpty else { return Observable.empty() }
        return allDatas.map {
            $0.filter { $0.type == type }
        }
    }
    
    func searchLanguage(searchText: String) -> Observable<[Language]> {
        guard !allDatas.value.isEmpty else { return Observable.empty() }
        guard !searchText.isEmpty else { return allDatas.asObservable() }
        return allDatas.map {
            $0.filter({ language -> Bool in
                return language.name.lowercased().contains(searchText) || language.name.uppercased().contains(searchText)
            })
        }
    }
}
