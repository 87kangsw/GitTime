//
//  ActivityContributionCellReactor.swift
//  GitTime
//
//  Created by Kanz on 07/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift

class ActivityContributionCellReactor: Reactor {
    
    typealias Action = NoAction
    
    enum Mutation { }
    
    struct State {
        var contributionInfo: ContributionInfo
        var sections: [ContributionSection] {
            let items = contributionInfo.contributions.map { contribution -> ContributionSectionItem in
                let reactor = ContributionCellReactor(contribution: contribution)
                return ContributionSectionItem.contribution(reactor)
            }
            return [.contribution(items)]
        }
    }
    
    let initialState: State
    
    init(contributionInfo: ContributionInfo) {
        self.initialState = State(contributionInfo: contributionInfo)
         _ = self.state
    }
}
