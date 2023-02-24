//
//  BLEDelegate.swift
//  ios_blescanner_3_set_rotation
//
//  Created by Kacper Cichosz on 06/02/2023.
//

import Foundation
import CoreBluetooth

private enum AdvertState {
    case ADVERT_IDLE, ADVERT_FIRST, ADVERT_SECOND, ADVERT_ALL, ADVERT_COMPLETE
}

class BLEDelegate: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, ObservableObject {
    static let shared = BLEDelegate()

    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    private var scanResult = [BleDeviceModel]()
    private var advertState = AdvertState.ADVERT_IDLE
    private var secondSet = 0
    private var orgTime = 0.0
    private var advertCount = 0
    private var background = false
    private var firstTime = true
    private var advertMax = 20
    private var nRFIdentifier: UUID?
    private var advertisementToDisplay: [BleDeviceModel]? {
        didSet {
            NotificationCenter.default.post(name: Notification.Name("SendAdvertisementToViewModel"),
                                            object: self.advertisementToDisplay)
        }
    }

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
        self.peripheral = peripheral
        self.peripheral.delegate = self
        // Checks if dukeAdvServiceData advertise 111 or 222 or 333, which means we scan nRF device. If that's the case, store the nRF identifier.
        if let dukeAdvServiceData = advertisementData["kCBAdvDataServiceData"] as? NSDictionary,
           self.identifyAdvertSet(advert: dukeAdvServiceData.allValues.first as! Data) != 0 {
            self.nRFIdentifier = peripheral.identifier
        }
        // If nRFIdentifier is the same as current peripheral one - run the process of scanning for the results.
        if self.nRFIdentifier == self.peripheral.identifier {
            self.scanResults(advertisementData: advertisementData, rssi: RSSI)
        }
    }

    func stopScanning() {
        self.centralManager.stopScan()
    }

    func startScanning() {
        self.scanResult = [BleDeviceModel]()
        self.advertState = AdvertState.ADVERT_IDLE
        self.secondSet = 0
        self.orgTime = 0.0
        self.advertCount = 0
        self.advertisementToDisplay = nil
        self.centralManager.scanForPeripherals(withServices:
                                                [Constants.ServiceIDs.Sonos.SONOS_GATT_SERVICE_UUID])
    }

    func scanResults(advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var shouldInsert = true
        var timestamp = 0.0
        var foundThreeSets = false
        let set = self.identifyAdvertSet(advert: (advertisementData["kCBAdvDataServiceData"] as! NSDictionary).allValues.first as! Data)
        switch advertState {
        case .ADVERT_IDLE:
            if set == 1 {
                self.advertState = .ADVERT_FIRST
                self.advertCount = 0
                timestamp = 0.0
                self.orgTime = (advertisementData["kCBAdvDataTimestamp"] as! NSNumber).doubleValue
            } else {
                shouldInsert = false
            }
        case .ADVERT_FIRST:
            if set != 1 {
                self.secondSet = set
                self.advertState = .ADVERT_SECOND
            }
            timestamp = (advertisementData["kCBAdvDataTimestamp"] as! NSNumber).doubleValue - self.orgTime
        case .ADVERT_SECOND:
            if set != 1 && set != self.secondSet {
                self.advertState = .ADVERT_ALL
                foundThreeSets = true
            }
            timestamp = (advertisementData["kCBAdvDataTimestamp"] as! NSNumber).doubleValue - self.orgTime
        case .ADVERT_ALL:
            if self.advertCount < self.advertMax {
                self.advertCount += 1
                timestamp = (advertisementData["kCBAdvDataTimestamp"] as! NSNumber).doubleValue - self.orgTime
            } else {
                self.advertState = .ADVERT_COMPLETE
                shouldInsert = false
            }
            if set == 1 {
                //TODO: if we update nRF to V2.2
            }
        case .ADVERT_COMPLETE:
            self.stopScanning()
            self.advertisementToDisplay = self.scanResult
            if set == 1 {
                //TODO: if we update nRF to V2.2
            }
        }

        if shouldInsert {
            self.scanResult.append(BleDeviceModel(id: self.scanResult.count + 1,
                                                  name: peripheral.name ?? "",
                                                  timestamp: self.stringFromTimeInterval(interval: timestamp),
                                                  foundThreeSets: foundThreeSets,
                                                  advertisementData: advertisementData["kCBAdvDataServiceData"] as! NSDictionary,
                                                  set: "Adv set \(set)",
                                                  rssi: RSSI,
                                                  timeInterval: self.formatIntervalTime(data: advertisementData["kCBAdvDataManufacturerData"] as! Data)))
        }
    }

    // Reads advertisement data from 'kCBAdvDataServiceData' and convert it to set: Int. If the bytes don't contain 111, 222 or 333, return 0.
    func identifyAdvertSet(advert: Data) -> Int {
        guard let bytes = String(bytes: advert, encoding: .utf8) else {
            return 0
        }

        var set = 0
        if bytes.contains("111") {
            set = 1
        } else if bytes.contains("222") {
            set = 2
        } else if bytes.contains("333") {
            set = 3
        }
        return set
    }

    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let ti = Int(interval)
        let ms = Int(interval.truncatingRemainder(dividingBy: 1) * 1000)

        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)

        return String(format: "%0.2d:%0.2d:%0.2d.%0.3d",hours,minutes,seconds,ms)
    }

    func formatIntervalTime(data: Data) -> Int {
        var low = Int(data[4])
        if (low < 0) {
            low += 256
        }
        var high = Int(data[5])
        if (high < 0) {
            high += 256
        }
        high *= 256
        return high + low
    }
}
