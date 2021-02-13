//
//  BuddyWeeklyCellReactor.swift
//  GitTime
//
//  Created by Kanz on 2020/11/16.
//

import ReactorKit
import RxCocoa
import RxSwift

class BuddyYearlyCellReactor: Reactor {
    
	typealias Action = NoAction
	
	struct State {
		var contributionInfo: ContributionInfoObject
		var items: [ContributionObject] {
			let contributions: [ContributionObject] = contributionInfo.contributions.toArray()
			return contributions.suffix(7)
		}
	}
	
	let initialState: State
	let graphReactor: ContributionGraphViewReactor
	init(contributionInfo: ContributionInfoObject) {
		initialState = State(contributionInfo: contributionInfo)
		self.graphReactor = ContributionGraphViewReactor(contributions: contributionInfo.contributions.toArray())
		_ = self.state
	}
}
