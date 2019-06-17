//
//  UIAlertController+Rx.swift
//  GitTime
//
//  Created by Kanz on 28/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

// https://gist.github.com/RyogaK/41f55c88250d5882f0e7d10240c4c866

import Foundation
import RxSwift

protocol RxAlertActionType {
    associatedtype Result
    
    var title: String? { get }
    var style: UIAlertAction.Style { get }
    var result: Result { get }
}

struct RxAlertAction<R>: RxAlertActionType {
    typealias Result = R
    
    let title: String?
    let style: UIAlertAction.Style
    let result: R
}

struct RxDefaultAlertAction: RxAlertActionType {
    typealias Result = RxAlertControllerResult
    
    let title: String?
    let style: UIAlertAction.Style
    let result: Result
}

enum RxAlertControllerResult {
    case Ok
}

extension UIAlertController {
    static func rx_presentAlert<Action: RxAlertActionType, Result>(viewController: UIViewController,
                                                                   title: String? = nil,
                                                                   message: String? = nil,
                                                                   preferredStyle: UIAlertController.Style = .alert,
                                                                   animated: Bool = true,
                                                                   actions: [Action]) -> Observable<Result> where Action.Result == Result {
        return Observable.create { observer -> Disposable in
            let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
            
            actions.map { rxAction in
                UIAlertAction(title: rxAction.title, style: rxAction.style, handler: { _ in
                    observer.onNext(rxAction.result)
                    observer.onCompleted()
                })
                }
                .forEach(alertController.addAction)
            
            viewController.present(alertController, animated: animated, completion: nil)
            
            return Disposables.create {
                alertController.dismiss(animated: true, completion: nil)
            }
        }
    }
}
