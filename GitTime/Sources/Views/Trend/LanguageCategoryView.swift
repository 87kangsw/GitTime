//
//  LanguageCategoryView.swift
//  GitTime
//
//  Created Kanz on 2021/02/10.
//  Copyright © 2021 KanzDevelop. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import Then

final class LanguageCategoryView: BaseView, ReactorKit.View {
	
	typealias Reactor = LanguageCategoryViewReactor
	
	// MARK: Properties
	private let categorySubject = PublishSubject<LanguageTypes>()
	var languageCategoryObservable: Observable<LanguageTypes> {
		return categorySubject.asObservable()
	}
	
	// MARK: UI Views
	static var items: [UIImage] {
		let items = LanguageTypes.allCases.filter { $0.iconName().isNotEmpty }
		return items.compactMap { UIImage(named: $0.iconName()) }
	}
	
	let segmentControl = UISegmentedControl(items: items).then {
		$0.translatesAutoresizingMaskIntoConstraints = true
	}
	
	// MARK: - Initializing
	override init() {
		super.init()
	}
	
	convenience init(reactor: LanguageCategoryViewReactor) {
		defer { self.reactor = reactor }
		self.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - UI Setup
	override func addViews() {
		super.addViews()
		
		self.addSubview(segmentControl)
	}
	
	override func setupConstraints() {
		super.setupConstraints()
		
		segmentControl.snp.makeConstraints { make in
			make.top.leading.equalTo(16.0)
			make.trailing.bottom.equalTo(-16.0)
		}
	}
	
	// MARK: - Binding
	func bind(reactor: LanguageCategoryViewReactor) {
		
		// Action
		segmentControl.rx.controlEvent(.valueChanged)
			.flatMap { [weak self] _ -> Observable<LanguageTypes> in
				guard let self = self else { return Observable.empty() }
				let index = self.segmentControl.selectedSegmentIndex
				return Observable.just(LanguageTypes.indexToType(index))
			}
			.do(onNext: { [weak self] type in
				guard let self = self else { return }
				self.categorySubject.onNext(type)
			})
			.map { type in Reactor.Action.selectCategory(type) }
			.bind(to: reactor.action)
			.disposed(by: self.disposeBag)
		
		// State
		reactor.state.map { $0.languageCategoryType }
			.map { LanguageTypes.typeToIndex($0)}
			.bind(to: segmentControl.rx.selectedSegmentIndex )
			.disposed(by: self.disposeBag)
		
		// View
	}
}
