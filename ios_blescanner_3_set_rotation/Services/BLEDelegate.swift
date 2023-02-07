//
//  BLEDelegate.swift
//  ios_blescanner_3_set_rotation
//
//  Created by Kacper Cichosz on 06/02/2023.
//

import Foundation
import CoreBluetooth

class BLEDelegate: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, ObservableObject {
    static let shared = BLEDelegate()

    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    private var peripheralToConnect: CBPeripheral?
    private var inCharacteristic: CBCharacteristic?


    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: .main)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            self.centralManager.scanForPeripherals(withServices: [Constants.ServiceIDs.Sonos.SONOS_GATT_SERVICE_UUID])
        }
        if central.state == .poweredOff {
            self.centralManager.stopScan()
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Otherwise scan for all devices to display them in Main Menu
        self.peripheral = peripheral
        self.peripheral.delegate = self
        //TODO: Connect to nrfDevice
        // if nrfDevice == self.peripheral {
        //   self.centralManager.connect(self.peripheral)
        // }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(Constants.ServiceIDs.servicesToDiscover)
        self.centralManager.stopScan()
        print("Device connected!!!")
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Device disconnected!!!!")
        self.peripheralToConnect = nil
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }

        for service in services {
            // If the service is Sonos one, discover Sonos characteristics. Otherwise search for general ones.
            if service.uuid == Constants.ServiceIDs.Sonos.SONOS_GATT_SERVICE_UUID {
                service.peripheral?.discoverCharacteristics([Constants.ServiceIDs.Sonos.SONOS_GATT_IN_CHAR_UUID, Constants.ServiceIDs.Sonos.SONOS_GATT_OUT_CHAR_UUID],
                                                            for: service)
            } else {
                service.peripheral?.discoverCharacteristics(Constants.ServiceIDs.characteristicsToDiscover,
                                                            for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }

        for characteristic in characteristics {
            // General characteristics (Battery Level, Device information)
            if Constants.ServiceIDs.characteristicsToDiscover.contains(characteristic.uuid) {
                peripheral.setNotifyValue(true, for: characteristic)
                peripheral.readValue(for: characteristic)
            }
            // Sonos Out Characteristics
            if Constants.ServiceIDs.Sonos.SONOS_GATT_OUT_CHAR_UUID == characteristic.uuid {
                peripheral.setNotifyValue(true, for: characteristic)
                peripheral.readValue(for: characteristic)
            }
            // Sonos In Characteristics
            if Constants.ServiceIDs.Sonos.SONOS_GATT_IN_CHAR_UUID == characteristic.uuid {
                self.inCharacteristic = characteristic
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    }

    /// Handle characteristics if device is connected.
    /// - Parameters:
    ///   - characteristic: CBCharacteristic
    func handleCharacteristics(characteristic: CBCharacteristic) {
    }

    func stopScanning() {
        self.centralManager.stopScan()
    }
}
