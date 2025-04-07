import Foundation
import CoreBluetooth

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published var temperature: String = "--"
    @Published var humidity: String = "--"
    @Published var isConnected: Bool = false
    @Published var language: String = "ja"
    @Published var statusMessage = "デバイス未接続"
    
    
    @Published var temperatureHistory: [Double] = Array(repeating: 0, count: 10) // 🔹 温度の履歴データ
    @Published var humidityHistory: [Double] = Array(repeating: 0, count: 10) // 🔹 湿度の履歴データ
    
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    private var uartCharacteristic: CBCharacteristic?
    private var txCharacteristic: CBCharacteristic?
    private var rxCharacteristic: CBCharacteristic?
    private var motorControlCharacteristic: CBCharacteristic?
    
    let deviceName = "Smart Bandage"
    let uartServiceUUID = CBUUID(string: "6e400001-b5a3-f393-e0a9-e50e24dcca9e")
    let txCharUUID = CBUUID(string: "6e400003-b5a3-f393-e0a9-e50e24dcca9e") // from Arduino
    let rxCharUUID = CBUUID(string: "6e400002-b5a3-f393-e0a9-e50e24dcca9e") // to Arduino

    let uartCharUUID = CBUUID(string: "6e400003-b5a3-f393-e0a9-e50e24dcca9e")
    let motorCharUUID = CBUUID(string: "2A56")
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func toggleLanguage() {
        DispatchQueue.main.async {
            self.language = (self.language == "ja") ? "en" : "ja"
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth is on")
        } else {
            print("Bluetooth is not available")
        }
    }
    
    func startScanning() {
        if isConnected {
            disconnect()
        } else {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func disconnect() {
        if let peripheral = peripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == deviceName {
            self.peripheral = peripheral
            self.peripheral?.delegate = self
            centralManager.stopScan()
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isConnected = true
        peripheral.discoverServices([uartServiceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        isConnected = false
        self.peripheral = nil
        self.uartCharacteristic = nil
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            if service.uuid == uartServiceUUID {
                peripheral.discoverCharacteristics([txCharUUID, rxCharUUID], for: service) ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.uuid == txCharUUID {
                txCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            } else if characteristic.uuid == rxCharUUID {
                rxCharacteristic = characteristic
            }
        }
    }

    
    func startMotor() {
        sendMotorCommand("ON")
    }

    func stopMotor() {
        sendMotorCommand("OFF")
    }

    private func sendMotorCommand(_ command: String) {
        guard let peripheral = peripheral,
              let rxCharacteristic = rxCharacteristic else {
            print("❌ RX characteristic not available")
            return
        }

        if let data = "\(command)\n".data(using: .utf8) {
            peripheral.writeValue(data, for: rxCharacteristic, type: .withResponse)
            print("✅ Sent command: \(command)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { return }
        if let stringData = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
            let values = stringData.split(separator: ",").map { String($0) }
            if values.count == 2, let temp = Double(values[0]), let hum = Double(values[1]) {
                DispatchQueue.main.async {
                    self.temperature = "\(temp)°C"
                    self.humidity = "\(hum)%"
                    
                    // 🔹 最新のデータを履歴に追加
                    self.temperatureHistory.append(temp)
                    self.humidityHistory.append(hum)
                    
                    // 🔹 配列のサイズを10件に維持
                    if self.temperatureHistory.count > 10 {
                        self.temperatureHistory.removeFirst()
                    }
                    if self.humidityHistory.count > 10 {
                        self.humidityHistory.removeFirst()
                    }
                }
            }
        }
    }
    var temperatureMessage: String {
        let tempValue = Double(temperature.replacingOccurrences(of: "°C", with: "")) ?? 0.0
        
        if tempValue <= 32 {
            return language == "ja" ? "⚠️ 注意: 体温が低すぎます。" : "⚠️ Warning: Temperature is too low."
        } else if tempValue <= 35 {
            return language == "ja" ? "体温が少し低いです。" : "Temperature is slightly low."
        } else if tempValue <= 38 {
            return language == "ja" ? "体温は正常です" : "Temperature is normal"
        } else {
            return language == "ja" ? "体温は高すぎです" : "Temperature is too high!"
        }
    }
                                                                            
    var humidityMessage: String {
        let humValue = Double(humidity.replacingOccurrences(of: "%", with: "")) ?? 0.0
        
        if humValue < 70 {
            return language == "ja" ? "湿度が低すぎます" : "Humidity is too low"
        } else if humValue <= 90 {
            return language == "ja" ? "湿度が正常です" : "Humidity is normal"
        } else {
            return language == "ja" ? "湿度が高すぎます" : "Humidity is too high!"
        }
    }
}
