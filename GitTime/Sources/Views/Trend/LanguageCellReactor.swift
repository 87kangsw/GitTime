//
//  LanguageCellReactor.swift
//  GitTime
//
//  Created by Kanz on 2021/02/10.
//

import ReactorKit
import RxCocoa
import RxSwift

class LanguageCellReactor: Reactor {
    
	typealias Action = NoAction
	
	struct State {
		var language: GithubLanguage
		var isFavorite: Bool
	}
	
	let initialState: State
	
	init(language: GithubLanguage, isFavorite: Bool) {
		self.initialState = State(language: language, isFavorite: isFavorite)
	}
}
