//
//  BleDeviceModel.swift
//  ios_blescanner_3_set_rotation
//
//  Created by Kacper Cichosz on 06/02/2023.
//

import Foundation
import CoreBluetooth

struct BleDeviceModel: Identifiable {
    var id: String { name }
    var peripheral: CBPeripheral
    var name: String
}
