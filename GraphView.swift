import SwiftUI
import Charts

struct GraphView: View {
    @ObservedObject var bleManager: BLEManager
    @State private var selectedGraph = 2

    var body: some View {
        ZStack {
            // グラデーション背景
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#2b79e0"), Color(hex: "#58bfae")]),
                startPoint: .bottom,
                endPoint: .top
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                    .offset(x:160, y:5)
                
                Image("circle")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                
                Text(bleManager.language == "ja" ? "温度と湿度の推移" : "Temperature & Humidity Trend")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .offset(y: -10)

                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 50, style: .continuous)
                        .fill(Color.white)
                        .ignoresSafeArea(edges: .bottom)

                    VStack {
                        Picker("", selection: $selectedGraph) {
                            Text(bleManager.language == "ja" ? "温度" : "Temperature").tag(0)
                            Text(bleManager.language == "ja" ? "湿度" : "Humidity").tag(1)
                            Text(bleManager.language == "ja" ? "両方" : "Both").tag(2)
                        }
                        .tint(Color(hex: "#2b79e0"))
                        .offset(y: 5)

                        if selectedGraph == 0 || selectedGraph == 2 {
                            Text(bleManager.language == "ja" ? "温度 (°C)" : "Temperature (°C)")
                                .font(.headline)
                                .foregroundColor(Color(hex: "#2b79e0"))
                            Chart {
                                ForEach(Array(bleManager.temperatureHistory.enumerated()), id: \.offset) { index, value in
                                    LineMark(x: .value("Time", index), y: .value("Temperature", value))
                                        .foregroundStyle(Color(hex: "#e69adf"))
                                }
                            }
                            .chartXAxis {
                                AxisMarks { _ in
                                    AxisGridLine().foregroundStyle(Color.black)
                                    AxisTick().foregroundStyle(Color.black)
                                    AxisValueLabel().foregroundStyle(Color.black)
                                }
                            }
                            .chartYAxis {
                                AxisMarks { _ in
                                    AxisGridLine().foregroundStyle(Color.black)
                                    AxisTick().foregroundStyle(Color.black)
                                    AxisValueLabel().foregroundStyle(Color.black)
                                }
                            }
                            .frame(width: 375, height: 200)
                            .offset(x: 5)
                            .padding(.bottom, 10)
                        }
                        
                        if selectedGraph == 1 || selectedGraph == 2 {
                            Text(bleManager.language == "ja" ? "湿度 (%)" : "Humidity (%)")
                                .font(.headline)
                                .foregroundColor(Color(hex: "#2b79e0"))
                            Chart {
                                ForEach(Array(bleManager.humidityHistory.enumerated()), id: \.offset) { index, value in
                                    LineMark(x: .value("Time", index), y: .value("Humidity", value))
                                        .foregroundStyle(Color(hex: "#9cdce2"))
                                }
                            }
                            .chartXAxis {
                                AxisMarks { _ in
                                    AxisGridLine().foregroundStyle(Color.black)
                                    AxisTick().foregroundStyle(Color.black)
                                    AxisValueLabel().foregroundStyle(Color.black)
                                }
                            }
                            .chartYAxis {
                                AxisMarks { _ in
                                    AxisGridLine().foregroundStyle(Color.black)
                                    AxisTick().foregroundStyle(Color.black)
                                    AxisValueLabel().foregroundStyle(Color.black)
                                }
                            }
                            .frame(width: 375, height: 200 )
                            .offset(x: 5)
                            .padding(.bottom, 50)
                        }
                    }
                    
                    .padding(.top, 5)
                }
            }
        }
    }
}
