//
//  ActivityViewReactor.swift
//  GitTime
//
//  Created by Kanz on 16/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit

import GitHubKit
import Moya
import ReactorKit
import RxCocoa
import RxMoya
import RxSwift
import Kingfisher

final class ActivityViewReactor: ReactorKit.Reactor {
	
	static let INITIAL_PAGE = 1
	static let PER_PAGE = 30
	
	enum Action {
		case firstLoad
		case loadMoreActivities
		case refresh
	}
	
	enum Mutation {
		case setLoading(Bool)
		case setContributionInfo(ContributionInfo)
		case fetchActivity([Event], nextPage: Int, canLoadMore: Bool)
		case fetchActivityMore([Event], nextPage: Int, canLoadMore: Bool)
		case setPage(Int)
		case setLoadMore(Bool)
		case setRefreshing(Bool)
		case loadProfileImage(UIImage?)
	}
	
	struct State {
		var isLoading: Bool = false
		var isRefreshing: Bool = false
		var page: Int = 1
		var canLoadMore: Bool = true
		var contributionInfo: ContributionInfo?
		var contribution: [ActivitySectionItem]
		var activities: [ActivitySectionItem]
		var sectionItems: [ActivitySection] {
			return [
				.activities(self.activities)
			]
		}
		var user: Me?
		var currentProfileImage: UIImage?
	}
	
	let initialState: ActivityViewReactor.State
	
	fileprivate let activityService: ActivityServiceType
	fileprivate let userService: UserServiceType
	fileprivate let crawlerService: GitTimeCrawlerServiceType
	fileprivate let keychainService: KeychainServiceType
	
	private let imageDownloder = ImageDownloader(name: "profileImageDownloder")
	
	init(
		activityService: ActivityServiceType,
		userService: UserServiceType,
		crawlerService: GitTimeCrawlerServiceType,
		keychainService: KeychainServiceType
	) {
		self.activityService = activityService
		self.userService = userService
		self.crawlerService = crawlerService
		self.keychainService = keychainService
		
		self.initialState = State(isLoading: false,
								  page: ActivityViewReactor.INITIAL_PAGE,
								  canLoadMore: true,
								  contributionInfo: nil,
								  contribution: [],
								  activities: [],
								  user: GlobalStates.shared.currentUser.value)
	}
	
	// MARK: Mutation
	func mutate(action: Action) -> Observable<Mutation> {
		switch action {
		case .firstLoad:
			guard !self.currentState.isLoading else { return .empty() }
			let clearPagingMutation = self.clearPaging()
			let startLoading: Observable<Mutation> = .just(.setLoading(true))
			let endLoading: Observable<Mutation> = .just(.setLoading(false))
			let requestContributionMutation = self.requestContributions()
			let requestActivityMutation = self.requestActivities()
			let downloadProfileImage = self.downloadProfileImage()
			return .concat([clearPagingMutation, startLoading, downloadProfileImage, requestContributionMutation, requestActivityMutation, endLoading])
		case .loadMoreActivities:
			guard !self.currentState.isLoading else { return .empty() }
			guard self.currentState.canLoadMore else { return .empty() }
			let disableLoadMore: Observable<Mutation> = .just(.setLoadMore(false))
			let startLoading: Observable<Mutation> = .just(.setLoading(true))
			let endLoading: Observable<Mutation> = .just(.setLoading(false))
			let requestMoreActivityMuation: Observable<Mutation> = self.requestMoreActivities()
			return .concat([disableLoadMore, startLoading, requestMoreActivityMuation, endLoading])
		case .refresh:
			guard !self.currentState.isLoading else { return .empty() }
			guard !self.currentState.isRefreshing else { return .empty() }
			let clearPagingMutation = self.clearPaging()
			let startRefreshing: Observable<Mutation> = .just(.setRefreshing(true))
			let endRefreshing: Observable<Mutation> = .just(.setRefreshing(false))
			let requestContributionMutation = self.requestContributions()
			let requestActivityMutation = self.requestActivities()
			return .concat([clearPagingMutation, startRefreshing, requestContributionMutation, requestActivityMutation, endRefreshing])
		}
	}
	
	// MARK: Reduce
	func reduce(state: State, mutation: Mutation) -> State {
		var state = state
		switch mutation {
		case let .setLoading(isLoading):
			state.isLoading = isLoading
		case let .setRefreshing(isRefreshing):
			state.isRefreshing = isRefreshing
		case let .setPage(page):
			state.page = page
		case let .setLoadMore(canLoadMore):
			state.canLoadMore = canLoadMore
		case let .setContributionInfo(contributionInfo):
			state.contributionInfo = contributionInfo
		case let .fetchActivity(activities, nextPage, canLoadMore):
			state.canLoadMore = canLoadMore
			state.page = nextPage
			state.activities = self.activitiesToSectionItem(activities.filter { $0.type != .none })
		//            state.activities = self.activitiesToSectionItem(activities)
		case let .fetchActivityMore(activities, nextPage, canLoadMore):
			state.canLoadMore = canLoadMore
			state.page = nextPage
			let sectionItems = state.sectionItems[0].items
				+ self.activitiesToSectionItem(activities.filter { $0.type != .none })
			//                + self.activitiesToSectionItem(activities)
			state.activities = sectionItems
		case .loadProfileImage(let image):
			state.currentProfileImage = image
		}
		return state
	}
	
	private func clearPaging() -> Observable<Mutation> {
		return .concat([.just(.setPage(1)), .just(.setLoadMore(true))])
	}
	
	private func activitiesToSectionItem(_ activities: [Event]) -> [ActivitySectionItem] {
		guard !activities.isEmpty else {
			let reactor = EmptyTableViewCellReactor(type: .activity)
			return [ActivitySectionItem.empty(reactor)]
		}
		return activities
			.map { event -> ActivitySectionItem in
				let reactor = ActivityItemCellReactor(event: event)
				let eventType = event.type
				switch eventType {
				case .createEvent:
					return ActivitySectionItem.createEvent(reactor)
				case .watchEvent:
					return ActivitySectionItem.watchEvent(reactor)
				case .pullRequestEvent:
					return ActivitySectionItem.pullRequestEvent(reactor)
				case .pushEvent:
					return ActivitySectionItem.pushEvent(reactor)
				case .forkEvent:
					return ActivitySectionItem.forkEvent(reactor)
				case .issuesEvent:
					return ActivitySectionItem.issuesEvent(reactor)
				case .issueCommentEvent:
					return ActivitySectionItem.issueCommentEvent(reactor)
				case .releaseEvent:
					return ActivitySectionItem.releaseEvent(reactor)
				case .pullRequestReviewCommentEvent:
					return ActivitySectionItem.pullRequestReviewCommentEvent(reactor)
				case .publicEvent:
					return ActivitySectionItem.publicEvent(reactor)
				case .none:
					return ActivitySectionItem.createEvent(reactor)
				}
			}
	}
	
	private func requestContributions() -> Observable<Mutation> {
		
		if GlobalStates.shared.isTrial.value == true {
			return self.requestTrialContributions()
		}
		
		guard let me = GlobalStates.shared.currentUser.value else { return .empty() }
		
		return self.fetchContributions()
			.observe(on: MainScheduler.instance)
			.map { userContribution -> ContributionInfo in
				return ContributionInfo(
					count: userContribution.totalContributions,
					contributions: userContribution.contributions.map {
						Contribution(
							date: $0.date,
							contribution: $0.contributionCount,
							hexColor: $0.color
						)
					},
					userName: me.name,
					additionalName: me.additionalName,
					profileImageURL: me.profileURL
				)
			}
			.flatMap { response -> Observable<Mutation> in
				return .just(.setContributionInfo(response))
			}
		/*
		return self.crawlerService.fetchContributionsRawdata(userName: me.name)
			.map { response ->  Mutation in
				let contributionInfo = self.parseContribution(response: response)
				return .setContributionInfo(contributionInfo)
			}
			.catch { error -> Observable<ActivityViewReactor.Mutation> in
				log.error(error.localizedDescription)
				return self.crawlerService.fetchContributions(userName: me.name)
					.map { contributionInfo -> Mutation in
						return .setContributionInfo(contributionInfo)}
			}
		 */
	}
	
	private func fetchContributions() -> Observable<GraphQLResponse.UserContribution> {
		guard let accessToken = keychainService.getAccessToken() else { return .empty() }
		guard let me = GlobalStates.shared.currentUser.value else { return .empty() }
		
		let githubKit = GitHubKit(config: .init(token: accessToken))

		return Observable.create { observer -> Disposable in
			async {
				do {
					let contribution = try await githubKit.contributions(userName: me.name)
					observer.onNext(contribution)
					observer.onCompleted()
				} catch {
					observer.onError(error)
				}
			}
			
			return Disposables.create {
				
			}
		}
	}
	
	private func requestTrialContributions() -> Observable<Mutation> {
		return self.crawlerService.fetchTrialContributions()
			.delay(.milliseconds(300), scheduler: MainScheduler.asyncInstance)
			.map { contributionInfo -> Mutation in
				return .setContributionInfo(contributionInfo)
			}
	}
	
	private func requestActivities(page: Int? = 1) -> Observable<Mutation> {
		
		if GlobalStates.shared.isTrial.value == true {
			return self.requestTrialActivities()
		}
		
		guard let me = GlobalStates.shared.currentUser.value else { return .empty() }
		
		let currentPage = page ?? self.currentState.page
		
		return self.activityService.fetchActivities(userName: me.name, page: currentPage)
			.map { events -> Mutation in
				let newPage = events.count < ActivityViewReactor.PER_PAGE ? currentPage : currentPage + 1
				let canLoadMore = events.count == ActivityViewReactor.PER_PAGE
				return .fetchActivity(events, nextPage: newPage, canLoadMore: canLoadMore)
			}.catchAndReturn(.fetchActivity([], nextPage: currentPage, canLoadMore: false))
	}
	
	private func requestMoreActivities(page: Int? = 1) -> Observable<Mutation> {
		
		guard let me = GlobalStates.shared.currentUser.value else { return .empty() }
		
		let currentPage = self.currentState.page
		
		log.info("\(#function) \(currentPage)")
		
		return self.activityService.fetchActivities(userName: me.name, page: currentPage)
			.map { events -> Mutation in
				let newPage = events.count < ActivityViewReactor.PER_PAGE ? currentPage : currentPage + 1
				let canLoadMore = events.count == ActivityViewReactor.PER_PAGE
				return .fetchActivityMore(events, nextPage: newPage, canLoadMore: canLoadMore)
			}.catchAndReturn(.fetchActivityMore([], nextPage: currentPage, canLoadMore: false))
	}
	
	private func requestTrialActivities() -> Observable<Mutation> {
		return self.activityService.trialActivities()
			.delay(.milliseconds(300), scheduler: MainScheduler.asyncInstance)
			.map { events -> Mutation in
				return .fetchActivity(events, nextPage: 0, canLoadMore: false)
			}
	}
		
	private func downloadProfileImage() -> Observable<Mutation> {
		return self.profileImageDownload()
			.map { image -> Mutation in
				return .loadProfileImage(image)
			}
	}
	
	private func profileImageDownload() -> Observable<UIImage?> {
		guard let me = self.currentState.user else { return .empty() }
		guard let profileURL = URL(string: me.profileURL) else { return .empty() }
		
		return Observable.create { [weak self] observer -> Disposable in
			self?.imageDownloder.downloadImage(with: profileURL) { result in
				switch result {
				case .success(let imageResult):
					log.debug(imageResult)
					observer.onNext(imageResult.image)
					observer.onCompleted()
				case .failure(let error):
					log.error(error)
					observer.onNext(nil)
					observer.onCompleted()
				}
			}
			
			return Disposables.create {
				
			}
		}
	}
}
