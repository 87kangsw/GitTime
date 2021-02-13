//
//  ContributorCellReactor.swift
//  GitTime
//
//  Created by Kanz on 2020/10/27.
//

import ReactorKit
import RxCocoa
import RxSwift

class ContributorCellReactor: Reactor {
    
    typealias Action = NoAction
	
    struct State {
		var user: User
    }
    
	let initialState: State
	
	init(user: User) {
		self.initialState = State(user: user)
	}
}
