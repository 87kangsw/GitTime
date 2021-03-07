//
//  BuddyDailyCellReactor.swift
//  GitTime
//
//  Created by Kanz on 2020/11/04.
//

import ReactorKit
import RxCocoa
import RxSwift

class BuddyDailyCellReactor: Reactor {
    
    typealias Action = NoAction
	
    struct State {
		var contributionInfo: ContributionInfoObject
    }
    
	let initialState: State
	
	init(contributionInfo: ContributionInfoObject) {
		initialState = State(contributionInfo: contributionInfo)
		_ = self.state
	}
}
