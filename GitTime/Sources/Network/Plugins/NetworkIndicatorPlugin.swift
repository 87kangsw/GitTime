//
//  NetworkIndicatorPlugin.swift
//  GitTime
//
//  Created by Kanz on 22/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Moya

struct NetworkIndicatorPlugin: PluginType {
    
    static func indicatorPlugin() -> NetworkActivityPlugin {
        return NetworkActivityPlugin(networkActivityClosure: { (change, _) in
            DispatchQueue.main.async {
                switch change {
                case .began:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                case .ended:
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
        })
    }
}
