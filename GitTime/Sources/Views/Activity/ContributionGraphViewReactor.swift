//
//  ContributionGraphViewReactor.swift
//  GitTime
//
//  Created Kanz on 2020/11/04.
//  Copyright © 2020 KanzDevelop. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift

class ContributionGraphViewReactor: Reactor {
    
    typealias Action = NoAction
	
    struct State {
		var contributions: [ContributionObject]
		var sections: [ContributionSection] {
			let items = contributions.map { contributionObject -> ContributionSectionItem in
				let contribution = Contribution(managedObject: contributionObject)
				let reactor = ContributionCellReactor(contribution: contribution)
				return ContributionSectionItem.contribution(reactor)
			}
			return [.contribution(items)]
		}
    }
    
	let initialState: State
	
	init(contributions: [ContributionObject]) {
		initialState = State(contributions: contributions)
		_ = self.state
	}
    
}
