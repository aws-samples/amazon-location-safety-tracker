//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import Combine

/// Publishes mutation events to downstream subscribers for subsequent sync to the API.
@available(iOS 13.0, *)
protocol MutationEventPublisher: class, AmplifyCancellable {
    var publisher: AnyPublisher<MutationEvent, DataStoreError> { get }
}
