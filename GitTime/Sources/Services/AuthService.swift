//
//  AuthService.swift
//  GitTime
//
//  Created by Kanz on 22/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import AuthenticationServices
import Foundation

import RxSwift

protocol AuthServiceType {
    var accessToken: String? { get }
    func authorize() -> Observable<String>
    func requestAccessToken(code: String) -> Observable<GitHubAccessToken>
    func logOut()
}

final class AuthService: AuthServiceType {
    
    var session: ASWebAuthenticationSession?
    private(set) var accessToken: String?
    fileprivate let keychainService: KeychainServiceType
    let provider = GitTimeProvider<GitHubLoginAPI>()
    
    init(keychainService: KeychainServiceType) {
        self.keychainService = keychainService
        self.accessToken = loadAccessToken()
        log.debug("stored access token: \(self.accessToken ?? "not stored..")")
    }
    
    fileprivate func getAutorizeURL() -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "github.com"
        urlComponents.path = "/login/oauth/authorize"
        let clientIDQuery = URLQueryItem(name: "client_id", value: GitHubInfoManager.clientID)
        let scopeQuery = URLQueryItem(name: "scope", value: "user,repo")
        urlComponents.queryItems = [clientIDQuery, scopeQuery]
        return urlComponents.url!
    }
    
    fileprivate func loadAccessToken() -> String? {
        return self.keychainService.getAccessToken()
    }
    
    func authorize() -> Observable<String> {
        return Observable.create { observer -> Disposable in
            let url = self.getAutorizeURL()
            self.session = ASWebAuthenticationSession(url: url,
                                                      callbackURLScheme: GitHubInfoManager.callbackURLScheme,
                                                      completionHandler: { (urls, error) in
                                                        if let error = error {
                                                            observer.onError(error)
                                                        } else if let urls = urls, let code = urls.queryParameters?["code"] {
                                                            observer.onNext(code)
                                                            observer.onCompleted()
                                                        }
            })
            self.session?.start()
            
            return Disposables.create { }
        }
    }
    
    func requestAccessToken(code: String) -> Observable<GitHubAccessToken> {
        return self.provider.rx.request(.login(code: code))
            .asObservable()
            .map(GitHubAccessToken.self)
    }
    
    func logOut() {
        try? self.keychainService.removeAccessToken()
    }
}
