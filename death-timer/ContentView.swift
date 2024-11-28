//
//  ContentView.swift
//  death-timer
//
//  Created by Ali Siddique on 11/12/24.
//

import SwiftUI
import SwiftData

class TimerModel: ObservableObject {
    @Published var timeComponents: [String: Int] = [
        "years": 0,
        "months": 0,
        "days": 0,
        "hours": 0,
        "minutes": 0,
        "seconds": 0
    ]
    @Published var totalTime: Double = 0
    var timer: Timer?
    var userData: UserData?
    
    init(userData: UserData?) {
        self.userData = userData
        if userData?.timerStartDate != nil {
            restartTimer()
        }
    }
    
    func updateUserData(_ newUserData: UserData) {
        self.userData = newUserData
        if newUserData.timerStartDate != nil {
            restartTimer()
        }
    }
    
    var isTimerRunning: Bool {
        userData?.timerStartDate != nil
    }
    
  
    
     func timerProc() {
        guard let deathDate = userData?.predictedDeathDate else { return }
        let currentDate = Date()
        
        switch userData?.timeDisplayMode ?? .split {
        case .split:
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], 
                from: currentDate, 
                to: deathDate)
            
            timeComponents["years"] = components.year ?? 0
            timeComponents["months"] = components.month ?? 0
            timeComponents["days"] = components.day ?? 0
            timeComponents["hours"] = components.hour ?? 0
            timeComponents["minutes"] = components.minute ?? 0
            timeComponents["seconds"] = components.second ?? 0
            
        case .years:
            let interval = deathDate.timeIntervalSince(currentDate)
            totalTime = interval / (365.25 * 24 * 60 * 60)
            
        case .months:
            let interval = deathDate.timeIntervalSince(currentDate)
            totalTime = interval / (30.44 * 24 * 60 * 60)
            
        case .days:
            let interval = deathDate.timeIntervalSince(currentDate)
            totalTime = interval / (24 * 60 * 60)
            
        case .hours:
            let interval = deathDate.timeIntervalSince(currentDate)
            totalTime = interval / (60 * 60)
            
        case .minutes:
            let interval = deathDate.timeIntervalSince(currentDate)
            totalTime = interval / 60
            
        case .seconds:
            totalTime = deathDate.timeIntervalSince(currentDate)
        }
    }
    
     func restartTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.timerProc()
        }
        timerProc()
    }
    
    func startTimer() {
        guard !isTimerRunning else { return }
        userData?.timerStartDate = Date()
        restartTimer()
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        userData?.timerStartDate = nil
      
    }
}

import WidgetKit
import SuperwallKit
import StoreKit

struct WellbeingDashboardView: View {
    @Environment(\.modelContext) private var modelContext
      @Query private var userData: [UserData]
      @StateObject private var timerModel: TimerModel
      @State private var showingDisplayOptions = false
      @State private var showStatistics = false
      @State private var showBucketList = false
      @State private var showMemories = false
      @Environment(\.requestReview) private var requestReview
      @State private var selectedDate = Date()
      
      init() {
          let userDataItem = UserData()
          _timerModel = StateObject(wrappedValue: TimerModel(userData: userDataItem))
      }
      var body: some View {
          NavigationStack {
              ZStack {
                  Color(hex: "#0d1824")
                      .ignoresSafeArea()
                  
                  VStack {
                      Spacer()
                      
                      // Main Timer Section
                      VStack(spacing: 40) {
                        Text(formatDate(userData.first?.predictedDeathDate ?? Date()))
                          if userData.first?.timeDisplayMode == .split {
                              LazyVGrid(columns: [
                                  GridItem(.flexible()),
                                  GridItem(.flexible())
                              ], spacing: 30) {
                                  MainTimeComponent(value: timerModel.timeComponents["years"] ?? 0, unit: "Years")
                                  MainTimeComponent(value: timerModel.timeComponents["months"] ?? 0, unit: "Months")
                                  MainTimeComponent(value: timerModel.timeComponents["days"] ?? 0, unit: "Days")
                                  MainTimeComponent(value: timerModel.timeComponents["hours"] ?? 0, unit: "Hours")
                                  MainTimeComponent(value: timerModel.timeComponents["minutes"] ?? 0, unit: "Minutes")
                                  MainTimeComponent(value: timerModel.timeComponents["seconds"] ?? 0, unit: "Seconds")
                              }
                          } else {
                              MainTimeComponent(
                                  value: Int(timerModel.totalTime),
                                  unit: userData.first?.timeDisplayMode.rawValue.capitalized ?? "Time"
                              )
                          }
                          
                          Button(action: {
                              if timerModel.isTimerRunning {
                                  timerModel.stopTimer()
                              } else {
                                  timerModel.startTimer()
                              }
                          }) {
                              Text(timerModel.isTimerRunning ? "Stop Countdown" : "Start Countdown")
                                  .font(.custom("BebasNeue", size: 24))
                                  .foregroundColor(.white)
                                  .frame(maxWidth: .infinity)
                                  .padding()
                                  .background(timerModel.isTimerRunning ? Color.red.opacity(0.3) : Color(hex:"#fbf8ee").opacity(0.3))
                                  .clipShape(RoundedRectangle(cornerRadius: 40))
                                  .overlay(
                                      RoundedRectangle(cornerRadius: 40)
                                          .stroke(timerModel.isTimerRunning ? Color.red : Color(hex:"#fbf8ee"), lineWidth: 2)
                                  )
                          }
                      }
                      .padding(.horizontal, 30)
                      
                      Spacer()
                      
                      // Bottom Action Buttons
                      HStack(spacing: 40) {
                          ActionButton(icon: "chart.bar.fill", action: { showStatistics = true })
                          if Superwall.shared.subscriptionStatus == .inactive {
                              ActionButton(icon: "gearshape.fill", action: { Superwall.shared.register(event: "paid") })
                                  
                          } else {
                              ActionButton(icon: "gearshape.fill", action: { showingDisplayOptions = true })
                          }
                  
                          ActionButton(icon: "list.bullet.clipboard", action: { showBucketList = true })
                          ActionButton(icon: "photo.stack", action: { showMemories = true })
                      }
                      .padding(.bottom, 40)
                  }
                  .padding(.horizontal)
              }
          
                .fullScreenCover(isPresented: $showingDisplayOptions) {
                    DisplayOptionsView(userData: userData.first)
                }
              .fullScreenCover(isPresented: $showStatistics) {
                    LifeVisualizationView()
                }
              .fullScreenCover(isPresented: $showBucketList) {
                    BucketListItemView()
                }
                .fullScreenCover(isPresented: $showMemories) {
                    PhotoMemoryView()
                }
              
           
          }
          .onAppear(perform: initializeUserDataIfNeeded)
          .onAppear {
            requestReview()
              Superwall.shared.register(event: "campaign_trigger")
          }
          .preferredColorScheme(.dark)
      }
      
 
    
    private func initializeUserDataIfNeeded() {
        if userData.isEmpty {
            let newUserData = UserData()
            modelContext.insert(newUserData)
            timerModel.updateUserData(newUserData)
        } else {
            timerModel.updateUserData(userData[0])
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let days = Int(timeInterval) / 86400
        let hours = (Int(timeInterval) % 86400) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        
        var components: [String] = []
        
        // Add days if present
        if days > 0 {
            components.append("\(days) days")
        }
        
        // Add hours if present
        if hours > 0 || days > 0 {
            components.append("\(hours) hrs")
        }
        
        // Add minutes if present
        if minutes > 0 || hours > 0 || days > 0 {
            components.append("\(minutes) mins")
        }
        
        // Always add seconds
        components.append("\(seconds) sec")
        
        return components.joined(separator: ", ")
    }
    
    private func updateStartDate(_ date: Date) {
        // Set time components to start of day
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        if let newStartDate = calendar.date(from: components) {
            timerModel.userData?.timerStartDate = newStartDate
            // Update the elapsed time calculation
            timerModel.timerProc()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
#Preview{
    WellbeingDashboardView()
}
struct MainTimeComponent: View {
    let value: Int
    let unit: String
    
    var body: some View {
        VStack(spacing: 12) {
            Text("\(value)")
                .font(.system(size: 50, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex:"#fbf8ee"))
                .contentTransition(.numericText(countsDown: true))
                .transaction { t in
                    t.animation = .spring(response: 0.4, dampingFraction: 0.8)
                }
            
            Text(unit)
                .font(.custom("BebasNeue", size: 20))
                .foregroundColor(Color(hex:"#fbf8ee").opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex:"#fbf8ee").opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex:"#fbf8ee").opacity(0.3), lineWidth: 1)
                )
        )
    }
}
struct ActionButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color(hex: "#fbf8ee"))
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(Color(hex:"#fbf8ee").opacity(0.2))
                        .overlay(
                            Circle()
                                .stroke(Color(hex:"#fbf8ee"), lineWidth: 1)
                        )
                )
        }
    }
}
struct TimeComponent: View {
    let value: Int
    let unit: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(value)")
                .font(.custom("BebasNeue", size: 30))
                .foregroundColor(Color(hex:"#fbf8ee"))
            Text(unit)
                .font(.custom("BebasNeue", size: 16))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .cornerRadius(15)
    }
}

struct DisplayOptionsView: View {
    let userData: UserData?
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#0d1824").ignoresSafeArea()
                
                List {
                    ForEach(TimeDisplayMode.allCases, id: \.self) { mode in
                        Button(action: {
                            if let userData = userData {
                                userData.timeDisplayMode = mode
                                try? modelContext.save()
                            }
                            WidgetCenter.shared.reloadAllTimelines()
                            dismiss()
                        }) {
                            HStack {
                                Text(mode.rawValue.capitalized)
                                    .foregroundStyle(Color(hex: "#fbf8ee"))
                                Spacer()
                                if userData?.timeDisplayMode == mode {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color(hex: "#fbf8ee"))
                                }
                            }
                        }
                        .listRowBackground(Color(hex: "#fbf8ee").opacity(0.2))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color(hex: "#fbf8ee"))
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(Color(hex: "#fbf8ee").opacity(0.2))
                                    .overlay(
                                        Circle()
                                            .stroke(Color(hex: "#fbf8ee"), lineWidth: 1)
                                    )
                            )
                    }
                }
            }
            .navigationTitle("Display Mode")
            .navigationBarTitleDisplayMode(.inline)
            .foregroundColor(Color(hex: "#fbf8ee"))
        }
    }
}


//
//   ColorExtensions.swift
//  firebase-boilerplate
//
//  Created by Ali Siddique on 10/10/2024.
//

import Foundation
import SwiftUI

extension Color {
    
    static let customBlue = Color(hex:"#17233A")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


import SwiftUI

import SwiftUI

struct ContentView: View {
    @State private var currentAmount = 330
    @State private var goalAmount = 2000
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var showBucketList = false
    @State var showPhotoMemory = false
    @State var showLifeLesson = false
    var body: some View {
        VStack(spacing: 0) {
            // Status Bar
            HStack {
                Text("9:41")
                    .foregroundColor(.black)
                Spacer()
                HStack(spacing: 8) {
                    Image(systemName: "wifi")
                    Image(systemName: "battery.100")
                        .foregroundColor(.black)
                }
            }
            .padding()
            
            // Top Stats
            HStack {
                HStack(spacing: 4) {
                    Text("1")
                        .bold()
                    Text("day")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.2))
                .foregroundColor(.blue)
                .clipShape(Capsule())
                
                Spacer()
                
                Image(systemName: "waves.2")
                    .font(.title2)
                    .foregroundColor(.pink)
                    .padding(8)
                    .background(Color.pink.opacity(0.2))
                    .clipShape(Circle())
            }
            .padding()
            
            // Main Content
            VStack(spacing: 8) {
                Text("\(currentAmount)ml")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.blue)
                
                Text("Hydration • \(Int((Double(currentAmount) / Double(goalAmount)) * 100))% of your goal")
                    .foregroundColor(.gray)
            }
            .padding(.top, 20)
            
            // Clock View
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                    .frame(width: 200, height: 200)
                
                // Hour hand
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 4, height: 60)
                    .offset(y: -30)
                    .rotationEffect(.degrees(Double(Calendar.current.component(.hour, from: currentTime)) * 30 + Double(Calendar.current.component(.minute, from: currentTime)) * 0.5))
                
                // Minute hand
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 3, height: 80)
                    .offset(y: -40)
                    .rotationEffect(.degrees(Double(Calendar.current.component(.minute, from: currentTime)) * 6))
                
                // Second hand
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 2, height: 90)
                    .offset(y: -45)
                    .rotationEffect(.degrees(Double(Calendar.current.component(.second, from: currentTime)) * 6))
                
                // Center circle
                Circle()
                    .fill(Color.black)
                    .frame(width: 12, height: 12)
            }
            .padding(.vertical, 40)
            
            Spacer()
            
            // Bottom Drink Options
            HStack(spacing: 20) {
                VStack {
                    Image(systemName: "heart")
                        .foregroundColor(.gray)
                    Text("LLAMA LANA")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                VStack {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 40, height: 40)
                        Text("+")
                            .foregroundColor(.blue)
                    }
                    Text("WATER")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .onTapGesture {
                            showBucketList.toggle()
                        }
                }
                
                VStack {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.2))
                            .frame(width: 40, height: 40)
                        Text("+")
                            .foregroundColor(.green)
                    }
                    Text("GREEN TEA")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .onTapGesture {
                            showPhotoMemory.toggle()
                        }
                }
                
                VStack {
                    ZStack {
                        Circle()
                            .fill(Color.brown.opacity(0.2))
                            .frame(width: 40, height: 40)
                        Text("+")
                            .foregroundColor(.brown)
                    }
                    Text("COFFEE")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .onTapGesture {
                            showLifeLesson.toggle()
                        }
                }
                
                VStack {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.2))
                            .frame(width: 40, height: 40)
                        Text("+")
                            .foregroundColor(.orange)
                    }
                    Text("JUICE")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            .padding(.bottom, 20)
            
            // Bottom Banner
            HStack {
                Image(systemName: "figure.walk")
                    .foregroundColor(.green)
                Text("New Year Fresh Me")
                    .foregroundColor(.green)
                Spacer()
                Text("28")
                    .foregroundColor(.green)
                Text("DEC")
                    .foregroundColor(.green)
            }
            .padding()
            .background(Color.green.opacity(0.2))
            .cornerRadius(20)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .onReceive(timer) { input in
            currentTime = input
        }
        .fullScreenCover(isPresented: $showBucketList) {
            BucketListItemView()
        }
        .fullScreenCover(isPresented: $showPhotoMemory) {
            PhotoMemoryView()
        }
        .fullScreenCover(isPresented: $showLifeLesson) {
            LifeLessonView()
        }
            
    }
    
}

struct BottomSheetView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Timer Settings")
                .font(.title2)
                .bold()
            
            Button(action: {
                // Start timer action
            }) {
                Text("Start Timer")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(30)
            }
            
            Button(action: {
                // Reset timer action
            }) {
                Text("Reset")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(30)
            }
        }
        .padding()
        .background(Color(hex: "#0A0A1E"))
    }
}


#Preview {
    ContentView()
}
