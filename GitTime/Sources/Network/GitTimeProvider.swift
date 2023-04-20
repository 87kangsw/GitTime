//
//  GitTimeProvider.swift
//  GitTime
//
//  Created by Kanz on 20/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Moya
import RxMoya
import RxSwift
import Toaster

class GitTimeProvider<Target: TargetType>: MoyaProvider<Target> {
    
    init(plugins: [PluginType]? = nil) {
		let finalPlugins: [PluginType] = plugins ?? [PluginType]()
        // finalPlugins.append(NetworkLoggerPlugin(verbose: true))
        super.init(plugins: finalPlugins)
    }
    
    // MARK: - Request
    func request(_ token: Target, callbackQueue: DispatchQueue? = .none) -> Observable<Response> {
        let requestString = "\(token.method) \(token.path)"
        return self.rx.request(token, callbackQueue: callbackQueue)
            .filterSuccessfulStatusCodes()
            .asObservable()
            .do(onNext: { value in
                let message = "SUCCESS: \(requestString) (\(value))"
                log.debug(message, #file, #function, line: #line)
            }, onError: { [weak self] error in
                if let response = (error as? MoyaError)?.response {
                  if let jsonObject = try? response.mapJSON(failsOnEmptyData: false) {
                    let message = "FAILURE: \(requestString) (\(response.statusCode))\n\(jsonObject)"
                    log.warning(message, #file, #function, line: #line)
                    if response.statusCode == 403 {
                        self?.showErrorMessageToast("API rate limit exceeded..\nPlease wait a moment. 🙏")
                    } else {
                        self?.showErrorMessageToast(error.localizedDescription)
                    }
                  } else if let rawString = String(data: response.data, encoding: .utf8) {
                    let message = "FAILURE: \(requestString) (\(response.statusCode))\n\(rawString)"
                    log.warning(message, #file, #function, line: #line)
                  } else {
                    let message = "FAILURE: \(requestString) (\(response.statusCode))"
                    log.warning(message, #file, #function, line: #line)
                  }
                } else {
                  let message = "FAILURE: \(requestString)\n\(error)"
                  log.warning(message, #file, #function, line: #line)
                }
            }, onSubscribed: {
                let message = "REQUEST: \(requestString)"
                log.debug(message, #file, #function, line: #line)
            })
    }
    
    private func showErrorMessageToast(_ message: String) {
        Toast(text: message, duration: Delay.short).show()
    }
}
