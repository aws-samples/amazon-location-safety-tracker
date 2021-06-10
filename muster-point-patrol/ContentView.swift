// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import SwiftUI
import Combine
import Amplify

struct ContentView: View {
    
    @EnvironmentObject var auth: AuthService
    
    @State var users = [User]()
    @State var postsSubscription: AnyCancellable?
    
    var body: some View {
        VStack{
            List {
                ForEach(users) { user in
                    VStack{
                        Spacer()
                        HStack{
                            Spacer()
                            Text(user.username)
                                .font(.system(size: 50))
                                .foregroundColor(Color.white)
                            Spacer()
                        }
                        .frame(
                                minWidth: 0,
                                maxWidth: .infinity,
                                minHeight: 180,
                                maxHeight: 180,
                                alignment: .center
                        )
                        .background(user.isSafe! ? Color.green : Color.red)
                        Spacer()
                    }
                }
            }
            Spacer()
            Button("Sign Out", action: auth.signOut)
        }.onAppear{
            observeUsers()
            queryUsers()
        }
    }
    
    func queryUsers() {
        let u = User.keys
        Amplify.DataStore.query(User.self) {
            result in
            switch result {
            case . success(let users):
                self.users = users
            case .failure(let error):
                print(error)
            }
        }
    }

    func observeUsers() {
        postsSubscription = Amplify.DataStore.publisher(for: User.self)
            .sink {
                if case let .failure(error) = $0 {
                    print("Subscription received error - \(error.localizedDescription)")
                }
            }
            receiveValue: { changes in
                // handle incoming changes
                print("Subscription received mutation: \(changes)")
                queryUsers()
            }
    }

}
