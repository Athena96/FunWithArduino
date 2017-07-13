//
//  ViewController.swift
//  CoreBluetoothApp
//
//  Created by Jared Franzone on 7/11/17.
//  Copyright © 2017 Jared Franzone. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {

    @IBOutlet weak var servoSpeedLabel: UILabel!
    @IBOutlet weak var servoSpeedSlider: UISlider!
    
    private let ArduinoMotorServiceUUID = CBUUID(string: "025A7775-49AA-42BD-BBDB-E2AE77782966")
    private let ServoSpeedCharUUID = CBUUID(string: "F38A2C23-BC54-40FC-BED0-60EDDA139F47")
    
    private var bluetoothUtility: BluetoothUtility?
    private var servo: ServoMotor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(bluetoothUtilitystatusChanged(_:)),
                                               name: Notification.Name(rawValue: "BluetoothConnectionStatus"),
                                               object: nil)
        // starts off the bluetooth device search
        bluetoothUtility = BluetoothUtility(serviceUUID: ArduinoMotorServiceUUID, characteristicUUID: ServoSpeedCharUUID)
    }
    
    @IBAction func servoSpeedSlider(_ sender: UISlider) {
        if servo != nil {
            self.servoSpeedLabel.text = sender.value.description
            self.servo?.set(speed: UInt8(sender.value))
        }
    }
    
    func bluetoothUtilitystatusChanged(_ notification: Notification) {
        if let userInfo = (notification as NSNotification).userInfo as? [String: Bool] {
            DispatchQueue.main.async {
                if let connected: Bool = userInfo["isConnected"] {
                    self.servoSpeedSlider.minimumTrackTintColor = connected ? #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1) : #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
                    self.servo = (connected) ? ServoMotor(discoveredMotorDevice: (self.bluetoothUtility?.discoveredPeripheral)!, motorSpeedCharacteristic: (self.bluetoothUtility?.discoveredCharacteristic)!) : nil
                }
            }
            
            
        }
    }
    


}

