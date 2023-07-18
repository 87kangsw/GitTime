//
//  Event.swift
//  GitTime
//
//  Created by Kanz on 15/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation
import UIKit

// https://developer.github.com/v3/activity/events/types/
enum EventType: String, CaseIterable {
    case createEvent = "CreateEvent"
    case watchEvent = "WatchEvent"
    case pullRequestEvent = "PullRequestEvent"
    case pushEvent = "PushEvent"
    case forkEvent = "ForkEvent"
    case issuesEvent = "IssuesEvent"
    case issueCommentEvent = "IssueCommentEvent"
    case releaseEvent = "ReleaseEvent"
    case pullRequestReviewCommentEvent = "PullRequestReviewCommentEvent"
    case publicEvent = "PublicEvent"
    case none
}

enum EventActionState: String, CaseIterable {
    case opened
    case closed
}

struct Event: ModelType {
    let id: String
    let type: EventType
    let actor: Actor
    let repo: RepositoryInfo
    let payload: PayloadType?
    let isPublic: Bool
    let createdAt: Date
	
	var repositoryURL: String? {
		self.handleRepositoryURL()
	}
	
    var description: String? {
        return self.handleDescription()
    }
    var eventIconImage: UIImage? {
        return self.handleEventIconImage()
    }
    var eventMessage: String? {
        return self.handleEventMessage()
    }
    var openWebURL: String {
        return self.handleOpenWebURL()
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case actor
        case repo
        case payload
        case isPublic = "public"
        case createdAt = "created_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = EventType(rawValue: try container.decode(String.self, forKey: .type)) ?? .none
        actor = try container.decode(Actor.self, forKey: .actor)
        repo = try container.decode(RepositoryInfo.self, forKey: .repo)
		isPublic = try container.decode(Bool.self, forKey: .isPublic)
		let dateString = try container.decode(String.self, forKey: .createdAt)
		let df = ISO8601DateFormatter()
		createdAt = df.date(from: dateString) ?? Date()
		
        switch type {
        case .createEvent:
            payload = try container.decode(CreateEventPayload.self, forKey: .payload)
        case .watchEvent:
            payload = try container.decode(WatchEventPayload.self, forKey: .payload)
        case .pullRequestEvent:
            payload = try container.decode(PullRequestEventPayload.self, forKey: .payload)
        case .pushEvent:
            payload = try container.decode(PushEventPayload.self, forKey: .payload)
        case .forkEvent:
            payload = try container.decode(ForkEventPayload.self, forKey: .payload)
        case .issueCommentEvent:
            payload = try container.decode(IssueCommentEventPayload.self, forKey: .payload)
        case .releaseEvent:
            payload = try container.decode(ReleaseEventPayload.self, forKey: .payload)
        case .issuesEvent:
            payload = try container.decode(IssuesEventPayload.self, forKey: .payload)
        case .pullRequestReviewCommentEvent:
            payload = try container.decode(PullRequestReviewCommentEventPayload.self, forKey: .payload)
        case .publicEvent:
            payload = try container.decode(PublicEventPayload.self, forKey: .payload)
        case .none:
            payload = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type.rawValue, forKey: .type)
        try container.encode(actor, forKey: .actor)
        try container.encode(repo, forKey: .repo)
        try container.encode(isPublic, forKey: .isPublic)
        try container.encode(createdAt, forKey: .createdAt)
    }
}

extension Event {
	/// Activity Event Icon 처리용
    private func handleEventIconImage() -> UIImage? {
        var imageName: ImageNames
        switch self.type {
        case .createEvent:
            guard let payload = self.payload as? CreateEventPayload,
                let eventType = payload.type else { return nil }
			switch eventType {
			case .repository:
				imageName = EventImages.createEventRepo
			case .branch:
				imageName = EventImages.createEventBranch
			case .tag:
				imageName = EventImages.createEventTag
			}
        case .watchEvent:
            imageName = EventImages.watchEvent
        case .pullRequestEvent:
			guard let payload = self.payload as? PullRequestEventPayload else { return nil }
			let eventType = payload.action
			switch eventType {
			case .opened:
				imageName = EventImages.pullRequestOpened
			case .closed:
				imageName = EventImages.pullRequestClosed
			}
        case .pushEvent:
            imageName = EventImages.pushEvent
        case .forkEvent:
            imageName = EventImages.forkEvent
        case .issuesEvent:
			guard let payload = self.payload as? IssuesEventPayload else { return nil }
			let eventType = payload.action
			switch eventType {
			case .opened:
				imageName = EventImages.issuesEventOpened
			case .closed:
				imageName = EventImages.issuesEventClosed
			default:
				return nil
			}
        case .issueCommentEvent:
            imageName = EventImages.issueCommentEvent
        case .releaseEvent:
            imageName = EventImages.releaseEvent
        case .none:
            return nil
        case .pullRequestReviewCommentEvent:
            imageName = EventImages.issueCommentEvent
        case .publicEvent:
            imageName = EventImages.publicEvent
        }
        return UIImage.assetImage(name: imageName)
    }
	/// TitleLabel 표시용
    private func handleEventMessage() -> String? {
        switch self.type {
        case .createEvent:
            guard let payload = self.payload as? CreateEventPayload,
                let eventType = payload.type else { return nil }
            if eventType == .repository {
                return "created a repository"
            } else if eventType == .branch {
                let ref = payload.ref ?? ""
                return "created a branch '\(ref)'"
            } else {
                let ref = payload.ref ?? ""
                return "created a tag '\(ref)'"
            }
        case .watchEvent:
            return "starred"
        case .pullRequestEvent:
            guard let payload = self.payload as? PullRequestEventPayload else { return nil }
            let action = payload.action
            return "\(action) PR"
        case .pushEvent:
            return "pushed"
        case .forkEvent:
            let from = self.repo.name
            return "forked from \(from)"
        case .issuesEvent:
            guard let payload = self.payload as? IssuesEventPayload else { return nil }
            return "\(payload.action) #\(payload.issue.number)"
        case .issueCommentEvent:
            guard let payload = self.payload as? IssueCommentEventPayload else { return nil }
            return "commented on issue #\(payload.issue.number)"
        case .releaseEvent:
            guard let payload = self.payload as? ReleaseEventPayload else { return nil }
            let action = payload.action
            return "\(action) released"
        case .pullRequestReviewCommentEvent:
            guard let payload = self.payload as? PullRequestReviewCommentEventPayload else { return nil }
            return "comment on PR #\(payload.pullRequest.number)"
        case .publicEvent:
            return "made public"
        case .none:
            return nil
        }
    }
	
    /// SummaryLabel 표시용
    private func handleDescription() -> String? {
        switch self.type {
        case .createEvent:
            guard let payload = self.payload as? CreateEventPayload else { return nil }
            return payload.description
        case .watchEvent:
            return nil
        case .pullRequestEvent:
            guard let payload = self.payload as? PullRequestEventPayload else { return nil }
            return payload.pullRequest.title
        case .pushEvent:
            guard let payload = self.payload as? PushEventPayload else { return nil }
//			if payload.commits.count == 1 {
//				return "committed"
//			} else {
//				return "\(payload.commits.count) commits"
//			}
			return payload.commits.reduce("") { (s1, s2) -> String in
				return s1 + "\(s2.message ?? "")\n"
			}
        case .forkEvent:
            return nil
        case .issuesEvent:
            guard let payload = self.payload as? IssuesEventPayload else { return nil }
			return payload.issue.title
        case .issueCommentEvent:
            guard let payload = self.payload as? IssueCommentEventPayload else { return nil }
            return payload.issue.title
        case .releaseEvent:
            guard let payload = self.payload as? ReleaseEventPayload else { return nil }
            return payload.release.body
        case .pullRequestReviewCommentEvent:
            guard let payload = self.payload as? PullRequestReviewCommentEventPayload else { return nil }
            return payload.pullRequest.title
        case .publicEvent:
            return nil
        case .none:
            return nil
        }
    }
    
    private func handleOpenWebURL() -> String {
        switch self.type {
        case .createEvent:
            return self.repo.url
        case .watchEvent:
            return self.repo.url
        case .pullRequestEvent:
            guard let payload = self.payload as? PullRequestEventPayload else { return "" }
            return payload.pullRequest.url
        case .pushEvent:
			return "\(Constants.URLs.gitHubDomain)/\(self.repo.name)/commits"
        case .forkEvent:
            guard let payload = self.payload as? ForkEventPayload else { return "" }
            return payload.forkee.url
        case .issuesEvent:
            guard let payload = self.payload as? IssuesEventPayload else { return "" }
            return payload.issue.url
        case .issueCommentEvent:
            guard let payload = self.payload as? IssueCommentEventPayload else { return "" }
            return payload.comment.url
        case .releaseEvent:
            guard let payload = self.payload as? ReleaseEventPayload else { return "" }
            return payload.release.url
        case .pullRequestReviewCommentEvent:
            guard let payload = self.payload as? PullRequestReviewCommentEventPayload else { return "" }
            return payload.comment.url
        case .publicEvent:
            return self.repo.url
        case .none:
            return ""
        }
    }
	
	private func handleRepositoryURL() -> String? {
		switch self.type {
		case .forkEvent:
			guard let payload = self.payload as? ForkEventPayload else { return nil }
			return payload.forkee.name
		default:
			return self.repo.name
		}
	}
}

// MARK: Actor
struct Actor: ModelType {
    let id: Int
    let name: String
    let apiURL: String
    let profileURL: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "display_login"
        case apiURL = "url"
        case profileURL = "avatar_url"
    }
}

// MARK: Repository
struct RepositoryInfo: ModelType {
    let id: Int
    let name: String
    var url: String {
        return "\(Constants.URLs.gitHubDomain)/\(self.name)"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}
