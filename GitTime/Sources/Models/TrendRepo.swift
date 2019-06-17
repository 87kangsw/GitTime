//
//  TrendRepo.swift
//  GitTime
//
//  Created by Kanz on 17/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

struct TrendRepo: ModelType {
    let author: String
    let name: String
    let url: String
    let description: String
    let language: String?
    let languageColor: String?
    let stars: Int
    let forks: Int
    let currentPeriodStars: Int
}
