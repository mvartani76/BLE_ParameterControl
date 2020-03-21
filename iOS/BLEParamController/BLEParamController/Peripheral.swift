//
//  Peripheral.swift
//  BLEParamController
//
//  Created by Michael Vartanian on 3/21/20.
//  Copyright © 2020 Michael Vartanian. All rights reserved.
//

import UIKit
import CoreBluetooth

class Peripheral: NSObject {

    /// MARK: - Particle LED services and charcteristics Identifiers

    public static let peripheralParamServiceUUID    = CBUUID.init(string: "b4250400-fb4b-4746-b2b0-93f0e61122c6")
    public static let param1CharacteristicUUID      = CBUUID.init(string: "b4250401-fb4b-4746-b2b0-93f0e61122c6")
    public static let param2CharacteristicUUID      = CBUUID.init(string: "b4250402-fb4b-4746-b2b0-93f0e61122c6")
    public static let param3CharacteristicUUID      = CBUUID.init(string: "b4250403-fb4b-4746-b2b0-93f0e61122c6")

}
