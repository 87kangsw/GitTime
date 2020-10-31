//
//  AppIconCellReactor.swift
//  GitTime
//
//  Created by Kanz on 2020/10/28.
//

import ReactorKit
import RxCocoa
import RxSwift

class AppIconCellReactor: Reactor {
    
    typealias Action = NoAction
    struct State {
		var icon: AppIconTypes
		var selectedIcon: String
    }
    
	let initialState: State
	
	init(icon: AppIconTypes, selectedIcon: String) {
		self.initialState = State(icon: icon,
								  selectedIcon: selectedIcon)
	}
}
