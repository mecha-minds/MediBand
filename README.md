# 🩹 Smart Bandage Project

This project utilizes the Seeed Studio XIAO RP2040 to develop a smart bandage that measures and displays temperature and humidity in real-time using Bluetooth and NFC communication.

## 📁 File Structure

- **MediBand.html**  
  Main web page file.  
  Displays temperature and humidity in real-time and visualizes the data using graphs.

- **plot.html**  
  Test file for graph functionality.  
  Used to verify proper graph rendering based on sensor data.

- **real.html**  
  Test file for Bluetooth communication.  
  Displays only temperature and humidity values.

- **ContentView.swift**  
  Main SwiftUI view for the iOS app.  
  Displays real-time temperature and humidity data.  
  Includes a start scanning button to initiate BLE connection and embeds the graph view for historical data.

- **BLEManager.swift**  
  Handles Bluetooth Low Energy (BLE) communication.  
  Scans and connects to the smart bandage device.  
  Parses received data and updates temperature/humidity values.  
  Maintains historical data arrays for graphing.

- **GraphView.swift**  
  Responsible for drawing temperature and humidity charts.  
  Uses Swift Charts or SwiftUI-based rendering to visualize data over time.

## 🌟 Features

- **Real-time Data Acquisition**  
  Retrieves temperature and humidity data from the sensor.

- **Bluetooth Communication**  
  Displays data from the smart bandage on a web browser and iOS app.

- **Graph Visualization**  
  Enables visual analysis of past data.

- **Multilingual UI**  
  Supports both English and Japanese interfaces in the app.

- **NFC Integration (Planned)**  
  Exploring the addition of NFC-based data transfer.

## 🚀 Future Improvements

- Implementing data storage functionality  
- Enhancing mobile compatibility  
- Developing and testing NFC features  
- Improving sensor data accuracy  
- Cloud synchronization for remote monitoring

---

This project is currently under development, and feedback is highly welcome!
