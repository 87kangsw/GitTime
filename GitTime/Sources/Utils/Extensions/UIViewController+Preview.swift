//
//  UIViewController+Preview.swift
//  GitTime
//
//  Created by Kanz on 2020/10/12.
//

//import UIKit
//
//#if DEBUG
//import SwiftUI
//
//@available(iOS 13, *)
//extension UIViewController {
//	private struct Preview: UIViewControllerRepresentable {
//		// this variable is used for injecting the current view controller
//		let viewController: UIViewController
//
//		func makeUIViewController(context: Context) -> UIViewController {
//			return viewController
//		}
//
//		func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
//		}
//	}
//
//	func toPreview() -> some View {
//		// inject self (the current view controller) for the preview
//		Preview(viewController: self)
//	}
//}
//#endif


import UIKit

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct UIViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
	let viewController: ViewController

	init(_ builder: @escaping () -> ViewController) {
		viewController = builder()
	}

	// MARK: - UIViewControllerRepresentable
	func makeUIViewController(context: Context) -> ViewController {
		viewController
	}

	func updateUIViewController(_ uiViewController: ViewController, context: UIViewControllerRepresentableContext<UIViewControllerPreview<ViewController>>) {
		return
	}
}
#endif

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct UIViewPreview<View: UIView>: UIViewRepresentable {
	let view: View

	init(_ builder: @escaping () -> View) {
		view = builder()
	}

	// MARK: - UIViewRepresentable
	func makeUIView(context: Context) -> UIView {
		return view
	}

	func updateUIView(_ view: UIView, context: Context) {
		view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
		view.setContentHuggingPriority(.defaultHigh, for: .vertical)
	}
}
#endif
