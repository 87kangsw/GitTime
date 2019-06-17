//
//  GitTimeStep.swift
//  GitTime
//
//  Created by Kanz on 20/05/2019.
//  Copyright © 2019 KanzDevelop. All rights reserved.
//

import RxFlow

enum GitTimeStep: Step {
    
    // Global: Token Revoked
    case tokenRevoked
    
    // Start
    case goToSplash
    
    // Splash
    case goToLogin
    case goToMain
    
    // Login
    case loginIsRequired
    case userIsLoggedIn
}
