//
//  SignInView.swift
//  muster-point-client
//
//  Created by Rocha Silva, Fernando on 2021-05-08.
//

import SwiftUI
import Amplify

struct SignInView: View {
    
    @EnvironmentObject var auth: AuthService
    
    var body: some View {
        Button("Sign In", action: auth.signInWithWebUI)
            .padding()
            .background(Color.orange)
            .foregroundColor(Color.white)
            .cornerRadius(3)
    }
}
