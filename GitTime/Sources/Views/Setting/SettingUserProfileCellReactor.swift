//
//  SettingUserProfileCellReactor.swift
//  GitTime
//
//  Created by Kanz on 05/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

import ReactorKit

class SettingUserProfileCellReactor: Reactor {
    
    typealias Action = NoAction
    
    struct State {
        var profileURL: String
        var name: String
        var followerCount: Int
        var follwingCount: Int
    }
    
    let initialState: State
    
    init(me: User) {
        self.initialState = State(profileURL: me.profileURL,
                                  name: me.name,
                                  followerCount: me.followers ?? 0,
                                  follwingCount: me.following ?? 0)
        _ = self.state
    }
}
