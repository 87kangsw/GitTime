//
//  GlobalStates.swift
//  GitTime
//
//  Created by Kanz on 2020/09/30.
//

import Foundation

import RxCocoa
import RxSwift

final class GlobalStates {
	static let shared = GlobalStates()
	
	var currentUser: BehaviorRelay<Me?> = BehaviorRelay(value: nil)
}
