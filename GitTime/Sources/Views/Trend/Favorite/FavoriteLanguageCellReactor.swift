//
//  FavoriteLanguageCellReactor.swift
//  GitTime
//
//  Created by Kanz on 2021/02/10.
//

import ReactorKit
import RxCocoa
import RxSwift

class FavoriteLanguageCellReactor: Reactor {
    
	typealias Action = NoAction
	
	struct State {
		var favoriteLanguage: FavoriteLanguage
	}
	
	let initialState: State
	
	init(favoriteLanguage: FavoriteLanguage) {
		initialState = State(favoriteLanguage: favoriteLanguage)
	}
}
