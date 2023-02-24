//
//  DukeAdvScannerViewModel.swift
//  ios_blescanner_3_set_rotation
//
//  Created by Kacper Cichosz on 20/02/2023.
//

import Foundation

class DukeAdvScannerViewModel: ObservableObject {
    private var peripheralsObserver: NSObjectProtocol?
    @Published var advertisementArray = [BleDeviceModel]()

    init() {
        self.peripheralsObserver = NotificationCenter.default.addObserver(forName: Notification.Name("SendAdvertisementToViewModel"),
                                                                          object: nil,
                                                                          queue: nil,
                                                                          using: { [weak self] note in
            guard let advertisementToDisplay = note.object as? [BleDeviceModel] else {
                return
            }

            self?.advertisementArray = advertisementToDisplay
        })
    }

    func timeToFindThreeSets() -> String {
        guard let timestamp = advertisementArray.first(where: {$0.foundThreeSets})?.timestamp else {
            return ""
        }

        return timestamp
    }

    func startScanning() {
        self.advertisementArray = [BleDeviceModel]()
        BLEDelegate.shared.startScanning()
    }
}
