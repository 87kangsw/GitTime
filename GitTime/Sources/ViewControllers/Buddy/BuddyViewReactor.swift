//
//  BuddyViewReactor.swift
//  GitTime
//
//  Created Kanz on 2020/10/31.
//  Copyright © 2020 KanzDevelop. All rights reserved.
//

import Foundation

import GitHubKit

import ReactorKit
import RxCocoa
import RxSwift
import Moya
import Kanna

enum BuddyViewMode: String, CaseIterable {
	case yearly
	case daily
	
	var systemIconName: String {
		switch self {
		case .daily:
			return "square.grid.2x2"
		case .yearly:
			return "calendar"
		}
	}
	
	var buttonTitle: String {
		switch self {
		case .daily:
			return "Daily"
		case .yearly:
			return "Yearly"
		}
	}
}

final class BuddyViewReactor: Reactor {
	
	enum Action {
		case firstLoad
		case checkUserExist(String?)
		case clearCheckExist
		case addGitHubUsername(String?)
		case removeGitHubUsername(String?)
		case toastMessage(String?)
		case checkUpdate
		case refresh
		case checkGitHubUser(String?)
	}
	
	enum Mutation {
		case setBuddys([ContributionInfoObject])
		case addBuddy(ContributionInfoObject)
		case removeBuddy(Int)
		case setAlreadyExistUser((Bool, String)?)
		case setToastMessage(String?)
		case setLoading(Bool)
		case setRefreshing(Bool)
	}
	
	struct State {
		var isLoading: Bool = false
		var isRefreshing: Bool = false
		var viewMode: BuddyViewMode = .daily
		var buddys: [ContributionInfoObject] = []
		var sections: [BuddySection] {
			var sectionItems: [BuddySectionItem] = []
			switch viewMode {
			case .daily:
				sectionItems = buddys.map { BuddyDailyCellReactor(contributionInfo: $0) }.map(BuddySectionItem.daily)
				return [.buddys(sectionItems)]
			case .yearly:
				return buddys.map { BuddyYearlyCellReactor(contributionInfo: $0) }
					.map(BuddySectionItem.weekly)
					.map { sectionItem -> BuddySection in
						BuddySection.buddys([sectionItem])
					}
			}
		}
		var alreadyExistUser: (Bool, String)?
		var toastMessage: String?
	}
	
	private let crawlerService: GitTimeCrawlerServiceType
	private let realmService: RealmServiceType
	private let githubService: GitHubServiceType
	fileprivate let keychainService: KeychainServiceType
	
	let initialState: State
	
	// MARK: Initializing
	init(
		crawlerService: GitTimeCrawlerServiceType,
		realmService: RealmServiceType,
		githubService: GitHubServiceType,
		keychainService: KeychainServiceType
	) {
		self.crawlerService = crawlerService
		self.realmService = realmService
		self.githubService = githubService
		self.keychainService = keychainService
		
		initialState = State()
	}
	
	// MARK: Mutate
	
	func mutate(action: Action) -> Observable<Mutation> {
		switch action {
		case .firstLoad:
			return self.fetchBuddys()
		case .checkUserExist(let userName):
			guard let userName = userName, userName.isNotEmpty else { return .empty() }
			return self.checkIfExist(userName: userName)
		case .clearCheckExist:
			return .just(.setAlreadyExistUser(nil))
		case .addGitHubUsername(let userName):
			guard !self.currentState.isLoading else { return .empty() }
			guard let userName = userName, userName.isNotEmpty else { return .empty() }
			let startLoading: Observable<Mutation> = .just(.setLoading(true))
			let endLoading: Observable<Mutation> = .just(.setLoading(false))
			let request = self.requestContribution(userName: userName)
			return .concat(startLoading, request, endLoading)
		case .removeGitHubUsername(let userName):
			guard let userName = userName else { return .empty() }
			
			let buddys = self.currentState.buddys
			guard let buddyItem = buddys.enumerated().first(where: { $0.element.additionalName == userName }) else {
				return .empty()
			}
			
			self.realmService.removeBuddy(buddyItem.element)
			let removeBuddy: Observable<Mutation> = .just(.removeBuddy(buddyItem.offset))
			let toastMessage: Observable<Mutation> = .just(.setToastMessage("Removed buddy."))
			return .concat(removeBuddy, toastMessage)
		case .toastMessage(let message):
			return Observable.just(.setToastMessage(message))
		case .checkUpdate:
			guard self.currentState.buddys.isNotEmpty else { return .empty() }
			
			let needUpdateBuddys = self.currentState.buddys.filter { buddy in
				return buddy.updatedAt == nil || (buddy.updatedAt?.anHourAfater() == true)
			}
			let requests = needUpdateBuddys.map { item in
				return self.requestContribution(userName: item.additionalName)
			}
			return .concat(requests)
		case .refresh:
			guard !self.currentState.isRefreshing else { return .empty() }
			let startRefreshing: Observable<Mutation> = .just(.setRefreshing(true))
			let endRefreshing: Observable<Mutation> = .just(.setRefreshing(false))
			
			let requests = self.currentState.buddys.map { item in
				return self.requestContribution(userName: item.additionalName)
			}
			
			let mergedRequests = Observable.merge(requests)
			
			return .concat(startRefreshing, mergedRequests, endRefreshing)
			
		case .checkGitHubUser(let userName):
			guard let userName = userName, userName.isNotEmpty else { return .empty() }
			return self.checkGitHubUser(userName: userName)
		}
	}
	
	// MARK: Reduce
	
	func reduce(state: State, mutation: Mutation) -> State {
		var state = state
		switch mutation {
		case .addBuddy(let buddy):
			var addedBuddys = state.buddys
			if let index = addedBuddys.firstIndex(where: { $0.additionalName == buddy.additionalName }) {
				addedBuddys[index] = buddy
			} else {
				addedBuddys.append(buddy)
			}
			state.buddys = addedBuddys
		case .setBuddys(let buddys):
			state.buddys = buddys
		case .removeBuddy(let index):
			var buddys = state.buddys
			buddys.remove(at: index)
			state.buddys = buddys
		case .setAlreadyExistUser(let notExist):
			state.alreadyExistUser = notExist
		case .setToastMessage(let message):
			state.toastMessage = message
		case .setLoading(let isLoading):
			state.isLoading = isLoading
		case let .setRefreshing(isRefreshing):
			state.isRefreshing = isRefreshing
		}
		return state
	}
	
	private func fetchBuddys() -> Observable<Mutation> {
		return self.realmService.loadBuddys()
			.map { buddys -> Mutation in
				return .setBuddys(buddys)
			}
			.catchAndReturn(.setBuddys([]))
	}
	
	private func checkIfExist(userName: String) -> Observable<Mutation> {
		return self.realmService.checkIfExist(additionalName: userName)
			.map { notExist -> Mutation in
				return .setAlreadyExistUser((notExist, userName))
			}
	}
	
	private func fetchContributions(userName: String) -> Observable<GraphQLResponse.UserContribution> {
		guard let accessToken = keychainService.getAccessToken() else { return .empty() }
		
		let githubKit = GitHubKit(config: .init(token: accessToken))

		return Observable.create { observer -> Disposable in
			async {
				do {
					let contribution = try await githubKit.contributions(
						userName: userName,
						from: Date.todayStringFormatted(),
						to: Date.todayStringFormatted()
					)
					observer.onNext(contribution)
					observer.onCompleted()
				} catch {
					observer.onError(error)
				}
			}
			
			return Disposables.create {}
		}
	}
	
	private func requestContribution(userName: String) -> Observable<Mutation> {
		
		return self.fetchContributions(userName: userName)
			.observe(on: MainScheduler.asyncInstance)
			.flatMap { [weak self] contributionInfo -> Observable<Mutation> in
				guard let self = self else { return .empty() }
				
				return self.realmService.addBuddy(
					userName: contributionInfo.profile.userName ?? "",
					additionalName: contributionInfo.profile.login,
					profileURL: contributionInfo.profile.profileURL ?? "",
					contribution: contributionInfo.contributions.map {
						Contribution(
							date: $0.date,
							contribution: $0.contributionCount,
							hexColor: $0.color
						)
					}
				)
				.map { buddy -> Mutation in
						.addBuddy(buddy)
				}
			}
			.catch { error -> Observable<Mutation> in
				log.error(error.localizedDescription)
				return .empty()
			}
	}
	
	private func parseContribution(response: Response) -> ContributionInfo {
		var contributionCount: Int = 0
		var contributions: [Contribution] = .init()
		var userName: String = ""
		var additionalName: String = ""
		var profileURL: String = ""
		
		if let doc = try? HTML(html: response.data, encoding: .utf8) {
			for rect in doc.css("td") {
				if var date = rect["data-date"],
				   let dataLevel = rect["data-level"] {
					
					date = date.replacingOccurrences(of: "\\", with: "")
						.replacingOccurrences(of: "/", with: "")
						.replacingOccurrences(of: "\"", with: "")
					
					let colorType = ContributionHexColorTypes.allCases.first { $0.rawValue == Int(dataLevel) }
					if let hexString = colorType?.hexString {
						contributions.append(Contribution(date: date, contribution: Int(dataLevel)!, hexColor: hexString))
					}
				}
			}
			
			for count in doc.css("h2, f4 text-normal mb-2") {
				let decimalCharacters = CharacterSet.decimalDigits
				let decimalRange = count.text?.rangeOfCharacter(from: decimalCharacters)
				
				if decimalRange != nil {
					if var countText = count.text {
						countText = countText.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
						contributionCount = Int(countText)!
					}
				}
			}
			
			for link in doc.css("img") {
				if let imgClass = link["class"], imgClass == "avatar avatar-user width-full border color-bg-default" {
					profileURL = link["src"] ?? ""
				}
			}
			
			for span in doc.css("span") {
				if let itemProp = span["itemprop"], itemProp.isNotEmpty {
					if itemProp == "name" {
						userName = span.content?.trimmed ?? ""
					} else if itemProp == "additionalName" {
						additionalName = span.content?.trimmed ?? ""
					}
				}
			}
		}
		
		return ContributionInfo(count: contributionCount,
								contributions: contributions,
								userName: userName,
								additionalName: additionalName,
								profileImageURL: profileURL)
	}
	
	private func checkGitHubUser(userName: String) -> Observable<Mutation> {
		return self.githubService.userInfo(userName: userName)
			.flatMap { [weak self] _ -> Observable<Mutation> in
				guard let self = self else { return .empty() }
				return self.checkIfExist(userName: userName)
			}
			.catchAndReturn(.setToastMessage("User does not exist. Please check User's ID."))
	}
	
	/**
	사용자가 등록한 userName으로 파싱을 하는데, hotfix 2.0.2 처럼 \n UserName \n 이런식으로
	포맷이 변경되서 Realm에 잘못되는 경우를 방지
	*/
	private func checkUserNameIsValid(originalName: String, userName: String?, additionalName: String?) -> Bool {
		var isValid = false
		
		if originalName == userName {
			isValid = true
		} else if originalName == additionalName {
			isValid = true
		}
		
		return isValid
	}
}
