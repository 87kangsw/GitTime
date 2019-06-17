//
//  Payload.swift
//  GitTime
//
//  Created by Kanz on 15/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import Foundation

protocol PayloadType: ModelType {}

// https://developer.github.com/v3/activity/events/types

// MARK: - CreateEvent
/**
 * Represents a created repository, branch, or tag.
 */
enum CreateEventType: String {
    case repository
    case branch
    case tag
}

struct CreateEventPayload: PayloadType {
    let type: CreateEventType?
    let ref: String?
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case type = "ref_type"
        case ref
        case description
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let refType = try? container.decode(String.self, forKey: .type)
        type = CreateEventType(rawValue: refType ?? "")
        ref = try? container.decode(String.self, forKey: .ref)
        description = try? container.decode(String.self, forKey: .description)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type?.rawValue, forKey: .type)
        try container.encode(ref, forKey: .ref)
        try container.encode(description, forKey: .description)
    }
}

// MARK: - WatchEvent
/**
 * Triggered when someone stars a repository.
 */
struct WatchEventPayload: PayloadType { }

// MARK: - PullRequestEvent
enum PullRequestActionType: String {
    case opened
    case closed
}

/**
 * Triggered when a pull request is assigned, unassigned, labeled, unlabeled, opened, edited, closed, reopened, synchronize, ready_for_review, locked, unlocked or when a pull request review is requested or removed.
 */
struct PullRequestEventPayload: PayloadType {
    let action: PullRequestActionType
    let number: Int
    let pullRequest: PullRequestObject
    
    enum CodingKeys: String, CodingKey {
        case action
        case number
        case pullRequest = "pull_request"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        action = PullRequestActionType(rawValue: try container.decode(String.self, forKey: .action)) ?? .opened
        number = try container.decode(Int.self, forKey: .number)
        pullRequest = try container.decode(PullRequestObject.self, forKey: .pullRequest)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(action.rawValue, forKey: .action)
        try container.encode(number, forKey: .number)
        try container.encode(pullRequest, forKey: .pullRequest)
    }
}

struct PullRequestObject: ModelType {
    let id: Int
    let url: String
    let title: String
    let number: Int
    let body: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case url = "html_url"
        case title
        case number
        case body
    }
}

/*
    "push_id": 3609958082,
    "size": 1,
    "distinct_size": 1,
    "ref": "refs/heads/patch-1",
    "head": "97aa5eaaa37859cb123edd1defb53e8d2de176da",
    "before": "e2fc7e6c990adc8ea556665eca70aec3eb1ba267",
    "commits": [
        {
            "sha": "97aa5eaaa37859cb123edd1defb53e8d2de176da",
            "author": {
                        "email": "50608484+KanzDevelop@users.noreply.github.com",
                        "name": "KanzDevelop"
            },
            "message": "Create test.txt",
            "distinct": true,
            "url": "https://api.github.com/repos/KanzDevelop/PublicRepoTest/commits/97aa5eaaa37859cb123edd1defb53e8d2de176da"
        }
    ]
 */

// MARK: - PushEvent

/**
 Triggered on a push to a repository branch. Branch pushes and repository tag pushes also trigger webhook push events.
 */
struct PushEventPayload: PayloadType {
    let pushID: Int
    let commits: [PushCommitObject]
    
    enum CodingKeys: String, CodingKey {
        case pushID = "push_id"
        case commits
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        pushID = try container.decode(Int.self, forKey: .pushID)
        commits = try container.decode([PushCommitObject].self, forKey: .commits)
    }
}

struct PushCommitObject: ModelType {
    let message: String?
    let author: CommitAuthor
    let sha: String
}

struct CommitAuthor: ModelType {
    let email: String
    let name: String
}

// MARK: - ForkEvent

/**
 Triggered when a user forks a repository.
 */
struct ForkEventPayload: PayloadType {
    let forkee: ForkeeObject
    
    enum CodingKeys: String, CodingKey {
        case forkee
    }
}

struct ForkeeObject: ModelType {
    let id: Int
    let name: String
    let description: String?
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "full_name"
        case description
        case url = "html_url"
    }
}

// MARK: - IssueCommentEvent
/**
 Triggered when an issue comment is created, edited, or deleted.
 */
struct IssueCommentEventPayload: PayloadType {
    let action: CommentActionType
    let issue: Issue
    let comment: Comment
    
    enum CodingKeys: String, CodingKey {
        case action
        case issue
        case comment
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        action = CommentActionType(rawValue: try container.decode(String.self, forKey: .action)) ?? .created
        issue = try container.decode(Issue.self, forKey: .issue)
        comment = try container.decode(Comment.self, forKey: .comment)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(action.rawValue, forKey: .action)
        try container.encode(issue, forKey: .issue)
        try container.encode(comment, forKey: .comment)
    }
}

enum IssueStateType: String {
    case open
    case closed
}

struct Issue: ModelType {
    let url: String
    let title: String
    let number: Int
    let state: IssueStateType
    let body: String?
    
    enum CodingKeys: String, CodingKey {
        case url = "html_url"
        case title = "title"
        case number = "number"
        case state = "state"
        case body
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        url = try container.decode(String.self, forKey: .url)
        title = try container.decode(String.self, forKey: .title)
        number = try container.decode(Int.self, forKey: .number)
        state = IssueStateType(rawValue: try container.decode(String.self, forKey: .state)) ?? .open
        body = try? container.decode(String.self, forKey: .body)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
        try container.encode(title, forKey: .title)
        try container.encode(number, forKey: .number)
        try container.encode(state.rawValue, forKey: .state)
    }
}

enum CommentActionType: String {
    case created
    case edited
    case deleted
}

struct Comment: ModelType {
    let url: String
    let user: User
    let createdAt: Date
    let body: String
    
    enum CodingKeys: String, CodingKey {
        case url = "html_url"
        case user = "user"
        case createdAt = "created_at"
        case body = "body"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        url = try container.decode(String.self, forKey: .url)
        user = try container.decode(User.self, forKey: .user)
        body = try container.decode(String.self, forKey: .body)
        
        let dateString = try container.decode(String.self, forKey: .createdAt)
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        createdAt = df.date(from: dateString) ?? Date()
    }
    
}

// MARK: - IssuesEvent
/**
 Triggered when an issue is opened, edited, deleted, transferred, pinned, unpinned, closed, reopened, assigned, unassigned, labeled, unlabeled, locked, unlocked, milestoned, or demilestoned.
 */
enum IssuesEventActionType: String {
    case opened
    case edited
    case deleted
    case closed
    case reopened
    case etc
}

struct IssuesEventPayload: PayloadType {
    let action: IssuesEventActionType
    let issue: Issue
    
    enum CodingKeys: String, CodingKey {
        case action
        case issue
        case state
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        action = IssuesEventActionType(rawValue: try container.decode(String.self, forKey: .action)) ?? .etc
        issue = try container.decode(Issue.self, forKey: .issue)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(action.rawValue, forKey: .action)
        try container.encode(issue, forKey: .issue)
    }
}

// MARK: - ReleaseEvent
/**
 Triggered when a release is published, unpublished, created, edited, deleted, or prereleased.
 */
enum ReleaseEventActionType: String {
    case published
    case created
    case etc
}

struct ReleaseEventPayload: PayloadType {
    let action: ReleaseEventActionType
    let release: ReleaseObject
    
    enum CodingKeys: String, CodingKey {
        case action
        case release
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        action = ReleaseEventActionType(rawValue: try container.decode(String.self, forKey: .action)) ?? .etc
        release = try container.decode(ReleaseObject.self, forKey: .release)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(action.rawValue, forKey: .action)
        try container.encode(release, forKey: .release)
    }
}

struct ReleaseObject: ModelType {
    let id: Int
    let url: String
    let body: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case url = "html_url"
        case body = "body"
    }
}

// MARK: - PullRequestReviewCommentEvent

/**
 Triggered when a comment on a pull request's unified diff is created, edited, or deleted (in the Files Changed tab).
 */
struct PullRequestReviewCommentEventPayload: PayloadType {
    let action: CommentActionType
    let comment: Comment
    let body: String?
    let pullRequest: PullRequestObject
    
    enum CodingKeys: String, CodingKey {
        case action
        case comment
        case body
        case pullRequest = "pull_request"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        action = CommentActionType(rawValue: try container.decode(String.self, forKey: .action)) ?? .created
        comment = try container.decode(Comment.self, forKey: .comment)
        pullRequest = try container.decode(PullRequestObject.self, forKey: .pullRequest)
        body = try? container.decode(String.self, forKey: .body)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(action.rawValue, forKey: .action)
        try container.encode(comment, forKey: .comment)
        try container.encode(pullRequest, forKey: .pullRequest)
        try container.encode(body, forKey: .body)
    }
}

// MARK: - PublicEvent
/**
 Triggered when a private repository is made public. Without a doubt: the best GitHub event.
 */
struct PublicEventPayload: PayloadType { }
