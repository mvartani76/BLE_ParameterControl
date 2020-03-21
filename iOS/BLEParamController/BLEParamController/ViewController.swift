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

    @IBOutlet var paramSlider1: UISlider!
    @IBOutlet var paramSlider2: UISlider!
    @IBOutlet var paramSlider3: UISlider!
    @IBOutlet var paramButton: UIButton!

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
                        Peripheral.param3CharacteristicUUID], for: service)
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
                } else if characteristic.uuid == Peripheral.param2CharacteristicUUID {
                    print("Param 2 characteristic found")
                } else if characteristic.uuid == Peripheral.param3CharacteristicUUID {
                    print("Param 3 characteristic found");
                }
            }
        }
    }

    @IBAction func ParamSlider1Changed(_ sender: Any) {
    }

    @IBAction func ParamSlider2Changed(_ sender: Any) {
    }

    @IBAction func ParamSlider3Changed(_ sender: Any) {
    }

    @IBAction func ParamButtonChanged(_ sender: Any) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}

