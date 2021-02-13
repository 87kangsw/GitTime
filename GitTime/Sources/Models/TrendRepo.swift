//
//  TrendRepo.swift
//  GitTime
//
//  Created by Kanz on 17/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

struct TrendRepo: ModelType {
    var author: String
    var name: String
    var url: String
    var description: String
    var language: String?
    var languageColor: String?
    var stars: Int
    var forks: Int
    var currentPeriodStars: Int
	var contributors: [TrendRepoContributor]
}

struct TrendRepoContributor: ModelType {
	var name: String
	var profileURL: String
	
	var githubURL: String {
		return "\(Constants.URLs.gitHubDomain)/\(self.name)"
	}
}
