//
//  muster_point_patrolApp.swift
//  muster-point-patrol
//
//  Created by Rocha Silva, Fernando on 2021-05-13.
//
import Amplify
import AmplifyPlugins

import SwiftUI


@main
struct muster_point_patrolApp: App {
    
    @ObservedObject var auth = AuthService()
    
    init () {
        configureAmplify()
        
        auth.checkSessionStatus()
        auth.observeAuthEvents()
    }
    
    var body: some Scene {
        WindowGroup {
            if auth.isSignedIn {
                ContentView().environmentObject(auth)
            } else {
                SignInView().environmentObject(auth)
            }
        }
    }
    
    func configureAmplify(){
        do {
            Amplify.Logging.logLevel = .warn
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            
            let dataStorePlugin = AWSDataStorePlugin(modelRegistration: AmplifyModels())
            try Amplify.add(plugin: dataStorePlugin)
            try Amplify.add(plugin: AWSAPIPlugin())
            
            try Amplify.configure()
            print("Amplify configured")
        } catch {
            print("Failed to initialize Amplify with \(error)")
        }
    }
}
