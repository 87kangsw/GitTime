//
//  UICollectionView+Rx.swift
//  GitTime
//
//  Created by 강성욱 on 2023/07/16.
//

import UIKit

import RxCocoa
import RxDataSources
import RxSwift

extension Reactive where Base: UICollectionView {
	func itemSelected<S>(dataSource: CollectionViewSectionedDataSource<S>) -> ControlEvent<S.Item> {
		let source = self.itemSelected.map { indexPath in
			dataSource[indexPath]
		}
		return ControlEvent(events: source)
	}
}

