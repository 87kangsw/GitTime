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

protocol LanguagesServiceType: AnyObject {
	func searchLanguage(searchText: String) -> Observable<[GithubLanguage]>
	func getLanguageColor(language: String) -> String?
	func getLanguageList() -> Observable<[GithubLanguage]>
}

final class LanguagesService: LanguagesServiceType {
	
	private var allDatas: BehaviorRelay<[GithubLanguage]> = BehaviorRelay(value: [])
	
	init() {
		fetchData()
	}
	
	private func fetchData() {
		guard let url = Bundle.main.url(forResource: "colors", withExtension: "json") else { return }
		do {
			var languages: [GithubLanguage] = []
			let data = try Data(contentsOf: url)
			if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
				for (key, value) in json {
					if let dict = value as? [String: Any] {
						let color = dict["color"] as? String ?? ""
						let githubLanguage = GithubLanguage(name: key, color: color)
						languages.append(githubLanguage)
					}
				}
				allDatas.accept(languages)
			}
		} catch {
			log.error(error)
		}
	}
	
	func searchLanguage(searchText: String) -> Observable<[GithubLanguage]> {
		guard !allDatas.value.isEmpty else { return Observable.empty() }
		guard !searchText.isEmpty else { return self.getLanguageList() }
		return allDatas.map {
			$0.filter({ language -> Bool in
				return language.name.lowercased().contains(searchText.lowercased())
			}).sorted(by: { $0.name < $1.name })
		}
	}
	
	func getLanguageColor(language: String) -> String? {
		let result = allDatas.value.first { $0.name == language }
		return result?.color
	}
	
	func getLanguageList() -> Observable<[GithubLanguage]> {
		guard !allDatas.value.isEmpty else { return Observable.empty() }
		return allDatas
			.map { languages -> [GithubLanguage]in
				languages.sorted(by: { $0.name < $1.name })
			}
	}
}
