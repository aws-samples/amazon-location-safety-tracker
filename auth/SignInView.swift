// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Amplify
import SwiftUI

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
