//
//  BluetoothUtility.swift
//  CoreBluetoothApp
//
//  Created by Jared Franzone on 7/11/17.
//  Copyright © 2017 Jared Franzone. All rights reserved.
//

import Foundation
import CoreBluetooth


class BluetoothUtility: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    let ServiceUUID: CBUUID
    let CharacteristicUUID: CBUUID
    
    var centralManager: CBCentralManager? // my phone
    var discoveredPeripheral: CBPeripheral? // the motor/arduino
    var discoveredCharacteristic: CBCharacteristic? // the motor control characteristic
    
    init(serviceUUID: CBUUID, characteristicUUID: CBUUID) {
        self.ServiceUUID = serviceUUID
        self.CharacteristicUUID = characteristicUUID
        
        super.init()
        
        let queue = DispatchQueue(label: "com.new.CoreBluetoothApp", attributes: [])
        /// #1
        print("#1 : Setting the CBCentralManager")
        centralManager = CBCentralManager(delegate: self, queue: queue)
    }
    
    // MARK: - Private Helper functions
    
    func resetClass() {
        self.discoveredPeripheral = nil
        self.discoveredCharacteristic = nil
        postBluetoothStatusNotification(isConnected: false)
    }
    
    private func postBluetoothStatusNotification(isConnected status: Bool) {
        let connectionDetails = ["isConnected": status]
        NotificationCenter.default.post(name: Notification.Name(rawValue: "BluetoothConnectionStatus"), object: self, userInfo: connectionDetails)
    }
    
    /// #3
    func scanForDevices() {
        guard let central = centralManager else {
            return
        }
        print("#3 : centralManager is scanning for peripherals")
        central.scanForPeripherals(withServices: [ServiceUUID], options: nil)
        
    }
    
    // MARK: - CBCentralManager Delegate Methods
    
    /// #2
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("#2 : centralManager is poweredOn")
            scanForDevices()
            break
        default:
            resetClass()
            break
        }
    }
    
    /// #4
    // Called every time the central manager discovers a peripheral,
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("#4 : centralManager discovered a peripheral \(peripheral.description)")
        // newly discovered peripheral is returned as a CBPeripheral object.
        // keep a strong reference to it so the system does not deallocate it
        self.discoveredPeripheral = peripheral
        self.centralManager?.stopScan() // to save battery
        
        print("#5 : centralManager is attempting to connect to the peripheral")
        self.centralManager?.connect(peripheral, options: nil)
    }
    
    /// #6
    // called becaue we previously called 'central.connect(...)'
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
  
        print("#6 : centralManager is connected to the peripheral")
        peripheral.delegate = self
        print("#7 : requesting the peripherals services")
        peripheral.discoverServices([ServiceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        resetClass()
        scanForDevices()
    }
    
    // MARK: - CBPeripheral Delegate Methods
    
    /// #8
    // When the specified services are discovered, the peripheral (the CBPeripheral object you’re connected to) calls the peripheral:didDiscoverServices: method of its delegate object
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
  
        guard let motorControlService = peripheral.services?.first, error == nil else {
            print("didDiscoverServices")
            print(error)
            resetClass()
            scanForDevices()
            return
        }
        
        print("#8 : found the desired service on the peripheral, now we are requesting the peripherals characteristics")
        peripheral.discoverCharacteristics([CharacteristicUUID], for: motorControlService)
        
    }
    
    /// #9
    // called after peripheral.discoverCharacteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics, error == nil else {
            print("didDiscoverCharacteristicsFor")
            print(error)
            resetClass()
            scanForDevices()
            return
        }
        
        for characteristic in characteristics {

            if characteristic.uuid == CharacteristicUUID {
                print("#9 : found the desired charachteristic in the service on the peripheral")
                self.discoveredCharacteristic = characteristic
                print("#10 : Connection process completed... posting 'isConnected=true' notification")
                self.postBluetoothStatusNotification(isConnected: true)
            }
        }
    }
}




