//
//  Bundle+Extensions.swift
//  GitTime
//
//  Created by Kanz on 09/11/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

extension Bundle {
    class func resource<T>(name: String?, extensionType: String?) -> T? where T: Decodable {
        guard let resourceName = name, !resourceName.isEmpty,
            let extensionType = extensionType, !extensionType.isEmpty else { return nil }
        
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: extensionType) else { return nil }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let resource = try decoder.decode(T.self, from: data)
            return resource
        } catch {
            log.error(error.localizedDescription)
            return nil
        }
    }
}
