// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Amplify
import Foundation

class AuthService: ObservableObject {
    @Published var isSignedIn = false

    func checkSessionStatus() {
        _ = Amplify.Auth.fetchAuthSession { [weak self] result in
            switch result {
            case let .success(session):
                print(session)
                DispatchQueue.main.async {
                    self?.isSignedIn = session.isSignedIn
                }

            case let .failure(error):
                print(error)
            }
        }
    }

    private var window: UIWindow {
        guard
            let scene = UIApplication.shared.connectedScenes.first,
            let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
            let window = windowSceneDelegate.window as? UIWindow
        else { return UIWindow() }

        return window
    }

    func signInWithWebUI() {
        _ = Amplify.Auth.signInWithWebUI(presentationAnchor: window) { result in
            switch result {
            case .success:
                print("Signed in - saving user")
                self.manageUser()
            case let .failure(error):
                print("Sign in failed \(error)")
            }
        }
    }

    func signOut() {
        _ = Amplify.Auth.signOut { result in
            switch result {
            case .success:
                print("Signed out")

                // clear local cache(good practice)
                Amplify.DataStore.clear { result in
                    switch result {
                    case .success:
                        print("DataStore cleared")
                    case let .failure(error):
                        print("Error clearing DataStore: \(error)")
                    }
                }

            case let .failure(error):
                print("Sign out failed \(error)")
            }
        }
    }

    func observeAuthEvents() {
        _ = Amplify.Hub.listen(to: .auth) { [weak self] result in
            switch result.eventName {
            case HubPayload.EventName.Auth.signedIn:
                DispatchQueue.main.async {
                    self?.isSignedIn = true
                }

            case HubPayload.EventName.Auth.signedOut:
                DispatchQueue.main.async {
                    self?.isSignedIn = false
                }

            default:
                break
            }
        }
    }

    func manageUser() {
        guard let authUser = Amplify.Auth.getCurrentUser()
        else {
            print("User could not be retrieved")
            return
        }

        Amplify.DataStore.query(User.self, byId: authUser.userId) { result in
            switch result {
            case let .success(user):
                if user == nil {
                    self.saveUser(user: authUser)
                } else {
                    print("User already exists")
                }
            case let .failure(error):
                print("Error retrieving user \(error)")
            }
        }
    }

    func saveUser(user: AuthUser) {
        guard let authUser = Amplify.Auth.getCurrentUser()
        else {
            print("User could not be retrieved")
            return
        }

        let userId = authUser.userId
        let userName = authUser.username
        let user = User(id: userId, username: userName, isSafe: false)

        Amplify.DataStore.save(user) { result in
            switch result {
            case .success:
                print("User saved successfully")
            case let .failure(error):
                print("Error saving user \(error)")
            }
        }
    }
}
