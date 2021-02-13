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
		var language: Language
		var isFavorite: Bool
	}
	
	let initialState: State
	
	init(language: Language, isFavorite: Bool) {
		self.initialState = State(language: language, isFavorite: isFavorite)
	}
}
