import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b, a: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b, a) = (
                (int >> 8) * 17,
                (int >> 4 & 0xF) * 17,
                (int & 0xF) * 17,
                255
            )
        case 6: // RGB (24-bit)
            (r, g, b, a) = (
                int >> 16,
                int >> 8 & 0xFF,
                int & 0xFF,
                255
            )
        case 8: // ARGB (32-bit)
            (r, g, b, a) = (
                int >> 16 & 0xFF,
                int >> 8 & 0xFF,
                int & 0xFF,
                int >> 24
            )
        default:
            (r, g, b, a) = (0, 0, 0, 255)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct ContentView: View {
    @StateObject private var bleManager = BLEManager()

    var body: some View {
        TabView {
            TempHumidityView(bleManager: bleManager)
                .tabItem {
                    Image(systemName: "thermometer.sun") // system SF Symbol
                    Text(bleManager.language == "ja" ? "温度湿度" : "Temp")
                }

            VibrationView(bleManager: bleManager)
                .tabItem {
                    Image(systemName: "waveform.path") // system SF Symbol
                    Text(bleManager.language == "ja" ? "振動" : "Vibration")
                }
        }
    }
}

struct TempHumidityView: View {
    @ObservedObject var bleManager: BLEManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "#2b79e0"), Color(hex: "#58bfae")]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                        .offset(x:-160, y:-10)
                    
                    Image("circle")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 60)

                    Text(bleManager.language == "ja" ? "温度と湿度" : "Temperature & Humidity")
                        .font(.largeTitle)
                        .foregroundColor(Color.white)
                        .offset(y: -10)
                    
                    ZStack(alignment: .top) {
                        //Rounded top only
                        RoundedRectangle(cornerRadius: 50, style: .continuous)
                            .fill(Color.white)
                            .ignoresSafeArea(edges: .bottom)
                        
                        VStack(spacing: 20) { //temp/humid boxes buttons etc
                            Text(bleManager.language == "ja" ? "現在の温度と湿度を表示します。" : "Displaying current temperature and humidity.")
                                .font(.subheadline)
                                .foregroundColor(Color(hex: "#2b79e0"))
                                .offset(y: -20)
                            
                            HStack(spacing:20) {
                                VStack {
                                    Text("\(bleManager.language == "ja" ? "温度:" : "Temperature:")")
                                        .font(.headline)
                                        .foregroundColor(Color.white)
                                    
                                    Text(bleManager.temperature)
                                        .font(.title)
                                        .bold()
                                        .foregroundColor(.white) // temp color
                                }
                                .frame(width:120, height:80)
                                .padding()
                                .background((Color(hex: "#2b79e0")) .opacity(0.7))
                                .cornerRadius(20)
                                .shadow(radius: 5)
                                
                                VStack {
                                    Text("\(bleManager.language == "ja" ? "湿度:" : "Humidity:")")
                                        .font(.headline)
                                        .foregroundColor(Color.white)
                                    
                                    Text(bleManager.humidity)
                                        .font(.title)
                                        .bold()
                                        .foregroundColor(.white)
                                }
                                .frame(width: 120, height:80)
                                .padding()
                                .background((Color(hex: "#2b79e0")) .opacity(0.7))
                                .cornerRadius(20)
                                .shadow(radius: 5)
                            }
                            .padding(.horizontal)
                            .offset(y: -20) //temp n humid boxes
                            
                            VStack{
                                Text(bleManager.temperatureMessage)
                                    .font(.subheadline)
                                    .foregroundColor(Color(hex: "#2b79e0"))
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(hex: "#2b79e0").opacity(0.2))
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                                
                                Text(bleManager.humidityMessage)
                                    .font(.subheadline)
                                    .foregroundColor(Color(hex: "#2b79e0"))
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(hex: "#2b79e0").opacity(0.2))
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                            }
                            .offset(y:-30)
                            .frame(width: 360)
                            
                            VStack{
                                Button(action: {
                                    bleManager.startScanning()
                                }) {
                                    Text(bleManager.isConnected ? (bleManager.language == "ja" ? "接続を切る" : "Disconnect") : (bleManager.language == "ja" ? "Bluetooth接続" : "Connect Bluetooth"))
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background((bleManager.isConnected ? Color.red : Color(hex: "#2b79e0")) .opacity(0.4))
                                        .foregroundColor(Color(hex: "#2b79e0"))
                                        .cornerRadius(10)
                                }
                                .offset(y:-40)

                                NavigationLink(destination: GraphView(bleManager: bleManager)) {
                                    Text(bleManager.language == "ja" ? "傷の旅" : "Your Wound's Journey")
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background((Color(hex: "#2b79e0")) .opacity(0.4))
                                        .foregroundColor(Color(hex: "#2b79e0"))
                                        .cornerRadius(10)
                                }
                                .offset(y:-40)
                                
                                Button(action: {
                                    bleManager.toggleLanguage()
                                }) {
                                    Text(bleManager.language == "ja" ? "Switch to English" : "日本語へ切り替え")
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(Color.gray)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .offset(y:-20)

                            }
                            .padding(.top, 20) //three buttons down
                            .frame(width: 200)
                        }
                        .padding(.top, 40)// components in the white area
                    }
                }
            }
        }
    }
}

struct VibrationView: View {
    @ObservedObject var bleManager: BLEManager
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#2b79e0"), Color(hex: "#58bfae")]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                    .offset(x:-160, y:-10)
                
                Image("circle")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                
                Text(bleManager.language == "ja" ? "振動モーター制御" : "Vibration Motor Control")
                    .font(.largeTitle)
                    .foregroundColor(Color.white)
                    .offset(y: -10)
                
                ZStack(alignment: .top) {
                    //Rounded top only
                    RoundedRectangle(cornerRadius: 50, style: .continuous)
                        .fill(Color.white)
                        .ignoresSafeArea(edges: .bottom)
                    
                    VStack(spacing: 20) {
                        // 🔹 Start Vibration Button
                        
                        Button(action: {
                            bleManager.startMotor()
                        }) {
                            Text(bleManager.language == "ja" ? "振動を開始" : "Start Vibration")
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.green.opacity(0.4))
                            .foregroundColor(Color(hex: "#2b79e0"))
                            .cornerRadius(10)
                        }

                        // 🔹 Stop Vibration Button
                        Button(action: {
                             bleManager.stopMotor()
                        }) {
                             Text(bleManager.language == "ja" ? "振動を停止" : "Stop Vibration")
                             .frame(maxWidth: .infinity)
                             .frame(height: 50)
                             .background(Color.red.opacity(0.4))
                             .foregroundColor(Color(hex: "#2b79e0"))
                             .cornerRadius(10)
                        }
                    }
                    .padding(.top, 200)
                    .frame(width:200)
                }
            }
        }
    }
}
