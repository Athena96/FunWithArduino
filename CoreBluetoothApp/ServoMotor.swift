//
//  ServoMotor.swift
//  CoreBluetoothApp
//
//  Created by Jared Franzone on 7/11/17.
//  Copyright © 2017 Jared Franzone. All rights reserved.
//

import Foundation
import CoreBluetooth

struct ServoMotor {
    let servo: CBPeripheral
    let speed: CBCharacteristic
    var lastSpeed: UInt8 = 255
    
    init(discoveredMotorDevice: CBPeripheral, motorSpeedCharacteristic: CBCharacteristic) {
        servo = discoveredMotorDevice
        speed = motorSpeedCharacteristic
    }
    
    func set(speed: UInt8) {
        let data = Data(bytes: [speed])
        self.servo.writeValue(data, for: self.speed, type: .withResponse)
    }
    
}
