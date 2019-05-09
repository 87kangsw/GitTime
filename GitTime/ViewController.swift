//
//  ViewController.swift
//  GitTime
//
//  Created by Kanz on 09/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import UIKit
import AuthenticationServices

class ViewController: UIViewController {

    var session: ASWebAuthenticationSession?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    fileprivate func getLoginUrl() -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "github.com"
        urlComponents.path = "/login/oauth/authorize"
        let clientIDQuery = URLQueryItem(name: "client_id", value: "89a2e056f183a7913852")
        let scopeQuery = URLQueryItem(name: "scope", value: "user,repo")
        urlComponents.queryItems = [clientIDQuery, scopeQuery]
        return urlComponents.url!
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        // 07445dc011bd0404bdee
        let url = getLoginUrl()
        session = ASWebAuthenticationSession(url: url,
                                             callbackURLScheme: "gittime",
                                             completionHandler: { (urls, error) in
                                                if (error != nil) {
                                                    print(error)
                                                } else {
                                                    print(urls)
                                                }
        })
        session?.start()
    }
    
}

