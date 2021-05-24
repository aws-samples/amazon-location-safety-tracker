//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSPluginsCore
import Combine

@available(iOS 13.0, *)
final class SyncEventEmitter {
    var modelSyncedEventEmitters: [String: ModelSyncedEventEmitter]
    var initialSyncCompleted: AnyCancellable?

    init(initialSyncOrchestrator: InitialSyncOrchestrator?,
         reconciliationQueue: IncomingEventReconciliationQueue?) {
        self.modelSyncedEventEmitters = [String: ModelSyncedEventEmitter]()

        let syncableModelSchemas = ModelRegistry.modelSchemas.filter { $0.isSyncable }

        var publishers = [AnyPublisher<Never, Never>]()
        for syncableModelSchema in syncableModelSchemas {
            let modelSyncedEventEmitter = ModelSyncedEventEmitter(modelSchema: syncableModelSchema,
                                                                  initialSyncOrchestrator: initialSyncOrchestrator,
                                                                  reconciliationQueue: reconciliationQueue)
            modelSyncedEventEmitters[syncableModelSchema.name] = modelSyncedEventEmitter
            publishers.append(modelSyncedEventEmitter.publisher)
        }

        self.initialSyncCompleted = Publishers
            .MergeMany(publishers)
            .sink(receiveCompletion: { [weak self] _ in
                self?.dispatchSyncQueriesReady()
            }, receiveValue: { _ in })
    }

    private func dispatchSyncQueriesReady() {
        let syncQueriesReadyEventPayload = HubPayload(eventName: HubPayload.EventName.DataStore.syncQueriesReady)
        Amplify.Hub.dispatch(to: .dataStore, payload: syncQueriesReadyEventPayload)
    }

}

@available(iOS 13.0, *)
extension SyncEventEmitter: DefaultLogger { }
