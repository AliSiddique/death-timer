//
//  death_widget.swift
//  death-widget
//
//  Created by Ali Siddique on 11/13/24.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        
        // Update every second
        let nextUpdate = Calendar.current.date(byAdding: .second, value: 1, to: currentDate)!
        
        let entry = SimpleEntry(date: currentDate)
        entries.append(entry)

        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}
struct death_widgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry
    @Query(death_widgetEntryView.userDataDescriptor) var userData: [UserData]
    
    private var totalMonths: Int {
        guard let user = userData.first,
              let deathDate = user.predictedDeathDate else { return 0 }
        return Calendar.current.dateComponents([.month], from: user.birthDate, to: deathDate).month ?? 0
    }
    
    private var monthsLived: Int {
        guard let user = userData.first else { return 0 }
        return Calendar.current.dateComponents([.month], from: user.birthDate, to: Date()).month ?? 0
    }
    
    private var timeComponents: [String: Int] {
        guard let user = userData.first,
              let deathDate = user.predictedDeathDate else { return [:] }
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], 
            from: Date(), 
            to: deathDate)
        return [
            "years": components.year ?? 0,
            "months": components.month ?? 0,
            "days": components.day ?? 0,
            "hours": components.hour ?? 0,
            "minutes": components.minute ?? 0,
            "seconds": components.second ?? 0
        ]
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#0d1824")
                .ignoresSafeArea()
            
            if let user = userData.first {
                switch family {
                case .systemSmall:
                    smallWidget
                case .systemMedium:
                    mediumWidget
                default:
                    largeWidget
                }
            } else {
                Text("No Data")
                    .font(.custom("BebasNeue", size: 20))
                    .foregroundColor(Color(hex: "#fbf8ee"))
            }
        }
    }
    
    private var smallWidget: some View {
        VStack(spacing: 4) {
            Text("Time Left")
                .font(.custom("BebasNeue", size: 14))
                .foregroundColor(Color(hex: "#fbf8ee").opacity(0.7))
            
            VStack(spacing: 8) {
                TimeComponent(value: timeComponents["years"] ?? 0, unit: "Years")
                TimeComponent(value: timeComponents["months"] ?? 0, unit: "Months")
                TimeComponent(value: timeComponents["days"] ?? 0, unit: "Days")
            }
        }
        .padding(8)
    }
    
    private var mediumWidget: some View {
        VStack(spacing: 4) {
            Text("Time Left")
                .font(.custom("BebasNeue", size: 14))
                .foregroundColor(Color(hex: "#fbf8ee").opacity(0.7))
            
            HStack(spacing: 12) {
                TimeComponent(value: timeComponents["years"] ?? 0, unit: "Years")
                TimeComponent(value: timeComponents["months"] ?? 0, unit: "Months")
                TimeComponent(value: timeComponents["days"] ?? 0, unit: "Days")
                TimeComponent(value: timeComponents["hours"] ?? 0, unit: "Hours")
            }
        }
        .padding(8)
    }
    
    private var largeWidget: some View {
        VStack(spacing: 4) {
            Text("Life Progress")
                .font(.custom("BebasNeue", size: 14))
                .foregroundColor(Color(hex: "#fbf8ee").opacity(0.7))
                .padding(.top, 4)
            
            GeometryReader { geometry in
                let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 16)
                let rows = (totalMonths + 16 - 1) / 16
                let availableHeight = geometry.size.height - 40
                let availableWidth = geometry.size.width - 16
                
                let circleSize = min(
                    (availableWidth - CGFloat(15) * 2) / CGFloat(16),
                    availableHeight / CGFloat(rows)
                ) - 2
                
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(0..<totalMonths, id: \.self) { month in
                        Circle()
                            .fill(month < monthsLived ? Color(hex: "#fbf8ee") : Color(hex: "#fbf8ee").opacity(0.2))
                            .frame(width: circleSize, height: circleSize)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            Text("\(monthsLived) / \(totalMonths) months")
                .font(.custom("BebasNeue", size: 12))
                .foregroundColor(Color(hex: "#fbf8ee"))
                .padding(.bottom, 4)
        }
        .padding(8)
    }
    
    static var userDataDescriptor: FetchDescriptor<UserData> {
        var descriptor = FetchDescriptor<UserData>()
        descriptor.fetchLimit = 1
        return descriptor
    }
}

struct TimeComponent: View {
    let value: Int
    let unit: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#fbf8ee"))
                .minimumScaleFactor(0.5)
            
            Text(unit)
                .font(.custom("BebasNeue", size: 12))
                .foregroundColor(Color(hex: "#fbf8ee").opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

struct death_widget: Widget {
    let kind: String = "death_widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                death_widgetEntryView(entry: entry)
                    .modelContainer(for: UserData.self)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                death_widgetEntryView(entry: entry)
                    .modelContainer(for: UserData.self)
            }
        }
        .contentMarginsDisabled()
        .configurationDisplayName("Death Timer")
        .description("Shows life progress visualization.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemSmall) {
    death_widget()
} timeline: {
    SimpleEntry(date: .now)
}

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
extension WidgetConfiguration
{
    func contentMarginsDisabledIfAvailable() -> some WidgetConfiguration
    {
        if #available(iOSApplicationExtension 17.0, *)
        {
            return self.contentMarginsDisabled()
        }
        else
        {
            return self
        }
    }
}
