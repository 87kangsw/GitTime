//
//  UIApplication+Extensions.swift
//  GitTime
//
//  Created by Kanz on 2022/04/26.
//

import UIKit

extension UIApplication {
	static var keyWindow: UIWindow? {
		if #available(iOS 15.0, *) {
			return UIApplication.shared.connectedScenes
				.filter { $0.activationState == .foregroundActive }
				.first(where: { $0 is UIWindowScene })
				.flatMap { $0 as? UIWindowScene }?.windows
				.first(where: \.isKeyWindow)
		} else {
			return UIApplication.shared.windows.first(where: { $0.isKeyWindow })
		}
	}
}
