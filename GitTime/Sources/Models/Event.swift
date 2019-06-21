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
enum EventType: String {
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

enum EventActionState: String {
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
        isPublic = try container.decode(Bool.self, forKey: .isPublic)
        let dateString = try container.decode(String.self, forKey: .createdAt)
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        createdAt = df.date(from: dateString) ?? Date()
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
    
    private func handleEventIconImage() -> UIImage? {
        var imageName: ImageNames
        switch self.type {
        case .createEvent:
            guard let payload = self.payload as? CreateEventPayload,
                let eventType = payload.type else { return nil }
            if eventType == .repository {
                imageName = EventImages.createEventRepo
            } else if eventType == .branch {
                imageName = EventImages.createEventBranch
            } else {
                imageName = EventImages.createEventTag
            }
        case .watchEvent:
            imageName = EventImages.watchEvent
        case .pullRequestEvent:
            imageName = EventImages.pullRequestEvent
        case .pushEvent:
            imageName = EventImages.pushEvent
        case .forkEvent:
            imageName = EventImages.forkEvent
        case .issuesEvent:
            imageName = EventImages.issuesEvnet
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
    
    private func handleEventMessage() -> String? {
        switch self.type {
        case .createEvent:
            guard let payload = self.payload as? CreateEventPayload,
                let eventType = payload.type else { return nil }
            if eventType == .repository {
                return "created a repository"
            } else if eventType == .branch {
                let ref = payload.ref ?? ""
                return "created a branch '\(ref)' in"
            } else {
                let ref = payload.ref ?? ""
                return "created a tag '\(ref)' in"
            }
        case .watchEvent:
            return "starred"
        case .pullRequestEvent:
            guard let payload = self.payload as? PullRequestEventPayload else { return nil }
            let action = payload.action
            return "\(action) pull request in"
        case .pushEvent:
            return "pushed at"
        case .forkEvent:
            guard let payload = self.payload as? ForkEventPayload else { return nil }
            let from = self.repo.name
            let forkee = payload.forkee.name
            return "forked \(forkee) from \(from)"
        case .issuesEvent:
            guard let payload = self.payload as? IssuesEventPayload else { return nil }
            return "\(payload.action) a issue \(payload.issue.number) at"
        case .issueCommentEvent:
            guard let payload = self.payload as? IssueCommentEventPayload else { return nil }
            let action = payload.action
            return "comment '\(action)' on issue #\(payload.issue.number) at"
        case .releaseEvent:
            guard let payload = self.payload as? ReleaseEventPayload else { return nil }
            let action = payload.action
            return "\(action) released in"
        case .pullRequestReviewCommentEvent:
            guard let payload = self.payload as? PullRequestReviewCommentEventPayload else { return nil }
            let action = payload.action
            return "comment '\(action)' on pull request #\(payload.pullRequest.number) at"
        case .publicEvent:
            return "made public"
        case .none:
            return nil
        }
    }
    
    private func handleDescription() -> String? {
        switch self.type {
        case .createEvent:
            guard let payload = self.payload as? CreateEventPayload else { return nil }
            return payload.description
        case .watchEvent:
            return nil
        case .pullRequestEvent:
            guard let payload = self.payload as? PullRequestEventPayload else { return nil }
            var message: String = payload.pullRequest.title
            if let body = payload.pullRequest.body {
                message += "\n\(body)"
            }
            return message
        case .pushEvent:
            guard let payload = self.payload as? PushEventPayload else { return nil }
            var message: String = ""
            payload.commits.forEach { message.append($0.message ?? "") }
            return message.isEmpty ? nil : message
        case .forkEvent:
            return nil
        case .issuesEvent:
            guard let payload = self.payload as? IssuesEventPayload else { return nil }
            return payload.issue.title
        case .issueCommentEvent:
            guard let payload = self.payload as? IssueCommentEventPayload else { return nil }
            let issueTitle = payload.issue.title
            let comment = payload.comment.body
            return "\(issueTitle)\n>>>>>>>>>>>>\n\(comment)"
        case .releaseEvent:
            guard let payload = self.payload as? ReleaseEventPayload else { return nil }
            return payload.release.body
        case .pullRequestReviewCommentEvent:
            guard let payload = self.payload as? PullRequestReviewCommentEventPayload else { return nil }
            let pullRequestTitle = payload.pullRequest.title
            let comment = payload.comment.body
            return "\(pullRequestTitle)\n>>>>>>>>>>>>\n\(comment)"
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
            return "\(AppConstants.gitHubDomain)/\(self.repo.name)/commits"
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
}

extension Event {
    static func mockData() -> [Event]? {
        if let url = Bundle.main.url(forResource: "eventMock", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let events = try decoder.decode([Event].self, from: data)
                return events
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
}

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

struct RepositoryInfo: ModelType {
    let id: Int
    let name: String
    var url: String {
        return "\(AppConstants.gitHubDomain)/\(self.name)"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}
