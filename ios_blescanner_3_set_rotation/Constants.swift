//
//  Constants.swift
//  ios_blescanner_3_set_rotation
//
//  Created by Kacper Cichosz on 06/02/2023.
//

import Foundation
import CoreBluetooth


struct Constants {
    struct ServiceIDs {
        static let servicesToDiscover = [Sonos.SONOS_GATT_SERVICE_UUID, BATTERY_SERVICE, DEVICE_INFORMATION]
        static let characteristicsToDiscover = [BATTERY_LEVEL, MODEL_NUMBER_STRING, MANUFACTURER_NAME_STRING]
        struct Sonos {
            static let SONOS_GATT_SERVICE_UUID = CBUUID(string: "FE07")
            static let SONOS_GATT_IN_CHAR_UUID = CBUUID(string: "C44F42B1-F5CF-479B-B515-9F1BB0099C98")
            static let SONOS_GATT_OUT_CHAR_UUID = CBUUID(string: "C44F42B1-F5CF-479B-B515-9F1BB0099C99")
            static let BLE_TEST_CONTROLLER_PERIPHERAL_ID = "DEADBEEFFEED"
            static let BLE_TEST_MOCK_PERIPHERAL_ID = "CAFEFACEFEED"
            static let BLE_TEST_GATT_SERVER_ID = "FCFFAFEDB3BF33D7E9"
        }
        static let BATTERY_SERVICE = CBUUID(string:"0x180F")
        static let BATTERY_LEVEL = CBUUID(string: "0X2A19")
        static let DEVICE_INFORMATION = CBUUID(string: "0x180A")
        static let MODEL_NUMBER_STRING = CBUUID(string: "0x2A24")
        static let MANUFACTURER_NAME_STRING = CBUUID(string: "0x2A29")
    }
}
