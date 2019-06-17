//
//  GitTimeProvider.swift
//  GitTime
//
//  Created by Kanz on 20/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Moya
import RxSwift

class GitTimeProvider<Target: TargetType>: MoyaProvider<Target> {
    
    init(plugins: [PluginType]? = nil) {
        var finalPlugins: [PluginType] = plugins ?? [PluginType]()
        finalPlugins.append(NetworkActivityPlugin(networkActivityClosure: { (change, _) in
            DispatchQueue.main.async {
                switch change {
                case .began:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
        }))
        // finalPlugins.append(NetworkLoggerPlugin(verbose: true))
        super.init(plugins: finalPlugins)
    }
}
