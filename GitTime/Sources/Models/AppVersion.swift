//
//  AppVersion.swift
//  GitTime
//
//  Created by Kanz on 07/06/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

struct AppVersion: ModelType {
    let result: AppVersionResult
}

struct AppVersionResult: ModelType {
    let version: String
}
