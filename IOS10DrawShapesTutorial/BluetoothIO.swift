import CoreBluetooth

protocol BluetoothIODelegate: class {
    func bluetoothIO(_ bluetoothIO: BluetoothIO, didReceiveValue value: String)
}

class BluetoothIO: NSObject {
    let serviceUUID: String
    weak var delegate: BluetoothIODelegate?

    var centralManager: CBCentralManager!
    var connectedPeripheral: CBPeripheral?
    var targetService: CBService?
    var writableCharacteristic: CBCharacteristic?

    init(serviceUUID: String, delegate: BluetoothIODelegate?) {
        self.serviceUUID = serviceUUID
        self.delegate = delegate

        super.init()

        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func writeValue(_ value: String) {
        guard let peripheral = connectedPeripheral, let characteristic = writableCharacteristic else {
            return
        }

        let data = value.data(using: String.Encoding.utf8)
        peripheral.writeValue(data!, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
    }
    
    func disconnect() {
        guard let peripheral = connectedPeripheral else {
            return
        }
        
        centralManager.cancelPeripheralConnection(peripheral)
    }

}

extension BluetoothIO: CBCentralManagerDelegate {
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        connectedPeripheral = peripheral

        if let connectedPeripheral = connectedPeripheral {
            connectedPeripheral.delegate = self
            centralManager.connect(connectedPeripheral, options: nil)
        }
        centralManager.stopScan()
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: [CBUUID(string: serviceUUID)], options: nil)
        }
    }
}

extension BluetoothIO: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }

        targetService = services.first
        if let service = services.first {
            targetService = service
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }

        for characteristic in characteristics {
            if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse) {
                writableCharacteristic = characteristic
            }
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value, let delegate = delegate else {
            return
        }
        
        
        delegate.bluetoothIO(self, didReceiveValue: String(data: data, encoding: String.Encoding.utf8)!)
    }
}
