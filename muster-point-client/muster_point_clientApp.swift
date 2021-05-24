//
//  muster_point_clientApp.swift
//  muster-point-client
//
//  Created by Rocha Silva, Fernando on 2021-05-08.
//

import SwiftUI

import Amplify
import AmplifyPlugins
import AWSMobileClient

@main
struct muster_point_clientApp: App {
    
    @ObservedObject var auth = AuthService()
    //@UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    init () {
        configureLocation()
        configureAmplify()
        
        auth.checkSessionStatus()
        auth.observeAuthEvents()
    }
    
    var body: some Scene {
        WindowGroup {
            if auth.isSignedIn {
                SessionView().environmentObject(auth)
            } else {
                SignInView().environmentObject(auth)
            }
        }
    }
    
    func configureAmplify(){
        do {
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
    
    func configureLocation(){
        // Override point for customization after application launch.
        AWSMobileClient.default().initialize { (userState, error) in
            if let userState = userState {
                print("UserState: \(userState.rawValue)")
            } else if let error = error {
                print("error: \(error.localizedDescription)")
            }
        }
    }
}

//class AppDelegate: NSObject, UIApplicationDelegate {
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//
//
//
//        return true
//    }
//}
