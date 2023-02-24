//
//  BleDeviceModel.swift
//  ios_blescanner_3_set_rotation
//
//  Created by Kacper Cichosz on 06/02/2023.
//

import Foundation
import CoreBluetooth

struct BleDeviceModel: Identifiable {
    var id: Int
    var name: String
    var timestamp: String
    var foundThreeSets: Bool
    var advertisementData: NSDictionary
    var set: String
    var rssi: NSNumber
    var timeInterval: Int
}
