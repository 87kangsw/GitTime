//
//  TrendingHeaderView.swift
//  GitTime
//
//  Created Kanz on 2020/12/05.
//  Copyright © 2020 KanzDevelop. All rights reserved.
//

import UIKit

import ReactorKit
import RxCocoa
import RxSwift
import SnapKit
import Then

final class TrendingHeaderView: BaseView, ReactorKit.View {
    
    typealias Reactor = TrendingHeaderViewReactor
    
    // MARK: UI Views
	let segmentControl = UISegmentedControl(items: TrendTypes.allCases.map { $0.segmentTitle} ).then {
		$0.translatesAutoresizingMaskIntoConstraints = false
		$0.selectedSegmentIndex = 0
	}
	
	let periodButton = UIButton(type: .system).then {
		$0.setTitle("Today", for: .normal)
		$0.titleLabel?.font = .systemFont(ofSize: 14.0)
	}
	let languageButton = UIButton(type: .system).then {
		$0.setTitle("All Languages", for: .normal)
		$0.titleLabel?.font = .systemFont(ofSize: 14.0)
	}
    
	// MARK: Properties
//	override var intrinsicContentSize: CGSize {
//		return CGSize(width: UIScreen.main.bounds.width,
//					  height: 100)
//	}
	
    // MARK: - Initializing
    override init() {
        super.init()
    }
    
    convenience init(reactor: TrendingHeaderViewReactor) {
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
		self.addSubview(periodButton)
		self.addSubview(languageButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
		segmentControl.snp.makeConstraints { make in
			make.leading.equalTo(16.0)
			make.trailing.equalTo(-16.0)
			make.top.equalTo(8.0)
		}
		
		periodButton.snp.makeConstraints { make in
			make.leading.equalTo(16.0)
			make.top.equalTo(segmentControl.snp.bottom).offset(12.0)
		}
		
		languageButton.snp.makeConstraints { make in
			make.trailing.equalTo(-16.0)
			make.top.equalTo(segmentControl.snp.bottom).offset(12.0)
		}
    }
    
    // MARK: - Binding
    func bind(reactor: TrendingHeaderViewReactor) {

		reactor.state.map { $0.period }
			.map { $0.buttonTitle() }
			.bind(to: periodButton.rx.title())
			.disposed(by: self.disposeBag)
		
		reactor.state.map { $0.language }
			.map { language -> String in
				return language?.name ?? LanguageTypes.all.buttonTitle()
			}
			.bind(to: languageButton.rx.title())
			.disposed(by: self.disposeBag)
    }
}

// MARK: - Reactive Extension
extension Reactive where Base: TrendingHeaderView {
	
	var periodButtonTapped: ControlEvent<Void> {
		return base.periodButton.rx.tap
	}
	
	var languageButtonTapped: ControlEvent<Void> {
		return base.languageButton.rx.tap
	}
	
	var segmentValueChanged: ControlEvent<Void> {
		return base.segmentControl.rx.controlEvent(.valueChanged)
	}
}
