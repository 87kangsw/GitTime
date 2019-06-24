//
//  SettingItemCellReactor.swift
//  GitTime
//
//  Created by Kanz on 05/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift

class SettingItemCellReactor: Reactor {
    
    typealias Action = NoAction

    struct State {
        var title: String?
        var subTitle: String?
    }
    
    let initialState: State
    
    init(title: String?, subTitle: String?) {
        self.initialState = State(title: title,
                                  subTitle: subTitle)
        _ = self.state
    }
}
