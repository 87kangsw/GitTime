//
//  SettingCellReactor.swift
//  GitTime
//
//  Created by Kanz on 2020/10/26.
//

import ReactorKit
import RxCocoa
import RxSwift

class SettingCellReactor: Reactor {
    
    typealias Action = NoAction
	
    struct State {
		var settingType: SettingMenuTypes
    }
    
	let initialState: State
	
	init(settingType: SettingMenuTypes) {
		self.initialState = State(settingType: settingType)
	}

}
