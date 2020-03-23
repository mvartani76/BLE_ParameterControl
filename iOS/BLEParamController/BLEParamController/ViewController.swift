//
//  ViewController.swift
//  BLEParamController
//
//  Created by Michael Vartanian on 3/21/20.
//  Copyright © 2020 Michael Vartanian. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBPeripheralDelegate, CBCentralManagerDelegate {

    // Properties
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!

    // Characteristics
    private var param1Char: CBCharacteristic?
    private var param2Char: CBCharacteristic?
    private var param3Char: CBCharacteristic?
    private var paramButtonChar: CBCharacteristic?

    @IBOutlet var paramSlider1: UISlider!
    @IBOutlet var paramSlider2: UISlider!
    @IBOutlet var paramSlider3: UISlider!
    @IBOutlet var paramButton: UIButton!
    @IBOutlet var backgroundGraidentView: UIStackView!
    @IBOutlet var titleLabel: UILabel!

    // If we're powered on, start scanning
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central state update")
        if central.state != .poweredOn {
            print("Central is not powered on")
        } else {
            print("Central scanning for", Peripheral.peripheralParamServiceUUID);
            centralManager.scanForPeripherals(withServices: [Peripheral.peripheralParamServiceUUID],
                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }

    // Handles the result of the scan
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        // We've found it so stop scan
        self.centralManager.stopScan()

        // Copy the peripheral instance
        self.peripheral = peripheral
        self.peripheral.delegate = self

        // Connect!
        self.centralManager.connect(self.peripheral, options: nil)
    }

    // The handler if we do connect succesfully
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == self.peripheral {
            print("Connected to the Peripheral")
            peripheral.discoverServices([Peripheral.peripheralParamServiceUUID])
        }
    }

    // Handler for disconnects
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {

        if peripheral == self.peripheral {
            print("Disconnected")

            paramSlider1.isEnabled = false
            paramSlider2.isEnabled = false
            paramSlider3.isEnabled = false
            paramButton.isEnabled = false

            self.peripheral = nil

            // Start scanning again
            print("Central scanning for", Peripheral.peripheralParamServiceUUID);
            centralManager.scanForPeripherals(withServices: [Peripheral.peripheralParamServiceUUID],
                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }

    // Handles discovery event
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                if service.uuid == Peripheral.peripheralParamServiceUUID {
                    print("Param service found")
                    //Now kick off discovery of characteristics
                    peripheral.discoverCharacteristics([
                        Peripheral.param1CharacteristicUUID,
                        Peripheral.param2CharacteristicUUID,
                        Peripheral.param3CharacteristicUUID,
                        Peripheral.paramButtonCharacteristicUUID], for: service)
                    return
                }
            }
        }
    }

    // Handling discovery of characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == Peripheral.param1CharacteristicUUID {
                    print("Param 1 characteristic found")
                    param1Char = characteristic
                    paramSlider1.isEnabled = true
                } else if characteristic.uuid == Peripheral.param2CharacteristicUUID {
                    print("Param 2 characteristic found")
                    param2Char = characteristic
                    paramSlider2.isEnabled = true
                } else if characteristic.uuid == Peripheral.param3CharacteristicUUID {
                    print("Param 3 characteristic found");
                    param3Char = characteristic
                    paramSlider3.isEnabled = true
                } else if characteristic.uuid == Peripheral.paramButtonCharacteristicUUID {
                    print("Param Button characteristic found");
                    paramButtonChar = characteristic
                    paramButton.isEnabled = true
                    paramButton.alpha = 1.0
                }
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didModifyServices invalidatedServices: [CBService]) {
        print("Services Invalidated...")
        for service in invalidatedServices {
            if let characteristics = service.characteristics {
                for characteristic in characteristics {
                        print(characteristic)
                    }
            }
        }
        paramSlider1.isEnabled = false
        paramSlider2.isEnabled = false
        paramSlider3.isEnabled = false
        paramButton.isEnabled = false
        paramButton.alpha = 0.5
    }

    private func writeValueToChar( withCharacteristic characteristic: CBCharacteristic, withValue value: Data) {
        // Check if it has the write property
        // Still need to investigate how to send without response
        if characteristic.properties.contains(.write) && peripheral != nil {
            peripheral.writeValue(value, for: characteristic, type: .withResponse)
        }
    }

    @IBAction func ParamSlider1Changed(_ sender: Any) {
        let slider:UInt8 = UInt8(paramSlider1.value)
        print(slider)
        print(Data([slider]))
        writeValueToChar( withCharacteristic: param1Char!, withValue: Data([slider]))
    }

    @IBAction func ParamSlider2Changed(_ sender: Any) {
        let slider:UInt8 = UInt8(paramSlider2.value)
        writeValueToChar( withCharacteristic: param2Char!, withValue: Data([slider]))
    }

    @IBAction func ParamSlider3Changed(_ sender: Any) {
        let slider:UInt8 = UInt8(paramSlider3.value)
        writeValueToChar( withCharacteristic: param3Char!, withValue: Data([slider]))
    }

    @IBAction func ParamButtonChanged(_ sender: Any) {
        writeValueToChar( withCharacteristic: paramButtonChar!, withValue: Data([UInt8(135)]))
    }

    override func viewDidAppear(_ animated: Bool) {
        let gradientLayer = CAGradientLayer()
        let buttonGradientLayer = CAGradientLayer()

        gradientLayer.frame = self.view.bounds
        buttonGradientLayer.frame = paramButton.bounds
        //gradientLayer.colors = [UIColor.yellow.cgColor, UIColor.white.cgColor]

        gradientLayer.colors = [#colorLiteral(red: 0.06017230308, green: 0.03214876275, blue: 0.04932325242, alpha: 1).cgColor,
        #colorLiteral(red: 0.2197335064, green: 0.2197335064, blue: 0.2197335064, alpha: 1).cgColor]
        buttonGradientLayer.colors = [#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor,
        #colorLiteral(red: 0.3556107581, green: 0.3556107581, blue: 0.3556107581, alpha: 1).cgColor]

        // Diagonal: top left to bottom corner.
        gradientLayer.startPoint = CGPoint(x: 0, y: 0) // Top left corner.
        gradientLayer.endPoint = CGPoint(x: 1, y: 1) // Bottom right corner.
        buttonGradientLayer.startPoint = CGPoint(x: 0, y: 0) // Top left corner.
        buttonGradientLayer.endPoint = CGPoint(x: 1, y: 1) // Bottom right corner.
        self.view.layer.insertSublayer(gradientLayer, at: 0)

        titleLabel.textColor = UIColor.darkGray
        paramButton.backgroundColor = UIColor.lightGray
        buttonGradientLayer.cornerRadius = 5
        paramButton.layer.insertSublayer(buttonGradientLayer, at: 0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        centralManager = CBCentralManager(delegate: self, queue: nil)

        paramButton.setTitleColor(UIColor.black, for: .normal)
        paramButton.setTitleColor(UIColor.darkGray, for: .disabled)
        paramButton.alpha = 0.5
    }
}

