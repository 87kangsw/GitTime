//
//  AuthService.swift
//  GitTime
//
//  Created by Kanz on 22/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import AuthenticationServices
import Foundation

import FirebaseAuth
import RxSwift

protocol AuthServiceType {
    var accessToken: String? { get }
    func authorize() -> Observable<String>
    func requestAccessToken(code: String) -> Observable<GitHubAccessToken>
    func logOut()
//	func firebaseLogin() -> Observable<String>
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
            if #available(iOS 13.0, *) {
                if let loginVC = UIApplication.shared.keyWindow?.rootViewController as? LoginViewController {
                    self.session?.presentationContextProvider = loginVC
                }
            }
            
            self.session?.start()
            
            return Disposables.create { }
        }
    }
    
    func requestAccessToken(code: String) -> Observable<GitHubAccessToken> {
        return self.provider.request(.login(code: code))
            .map(GitHubAccessToken.self)
			.flatMap { [weak self] accessToken -> Observable<GitHubAccessToken> in
				guard let self = self else { return .empty() }
				return self.sendFirebaseCredential(accessToken)
			}
            .asObservable()
    }
    
    func logOut() {
        try? self.keychainService.removeAccessToken()
    }
	
	// MARK: - Firebase
	private func sendFirebaseCredential(_ accessToken: GitHubAccessToken) -> Observable<GitHubAccessToken> {
		return Observable.create { observer -> Disposable in
			
			let credential = GitHubAuthProvider.credential(withToken: accessToken.accessToken)
			
			Auth.auth().signIn(with: credential) { (authResult, error) in
				if let error = error {
					log.error(error)
					observer.onNext(accessToken)
					observer.onCompleted()
					return
				} else {
					// log.debug(authResult)
					let uID = authResult?.user.uid ?? ""
					let name = authResult?.user.displayName ?? ""
					let profileImageURL = authResult?.additionalUserInfo?.profile?["picture"] as? String ?? ""
					log.debug("uID: \(uID), name: \(name), profileImageURL: \(profileImageURL)")
					
					observer.onNext(accessToken)
					observer.onCompleted()
				}
			}
			
			return Disposables.create {
				
			}
		}
	}
}
