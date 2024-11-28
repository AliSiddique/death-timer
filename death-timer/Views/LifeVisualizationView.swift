import SwiftUI
import SwiftData

struct LifeVisualizationView: View {
    @Query private var userData: [UserData]
    @Environment(\.dismiss) private var dismiss
    private var totalDays: Int {
        let birthDate = userData.first?.birthDate ?? Date()
        let deathDate = userData.first?.predictedDeathDate ?? Date()
        return Calendar.current.dateComponents([.day], from: birthDate, to: deathDate).day ?? 0
    }
    
    private var daysLived: Int {
        let birthDate = userData.first?.birthDate ?? Date()
        return Calendar.current.dateComponents([.day], from: birthDate, to: Date()).day ?? 0
    }
    
    private var daysRemaining: Int {
        totalDays - daysLived
    }
    
    private var percentageLived: Double {
        (Double(daysLived) / Double(totalDays)) * 100
    }
    
    private var totalMonths: Int {
        let birthDate = userData.first?.birthDate ?? Date()
        let deathDate = userData.first?.predictedDeathDate ?? Date()
        return Calendar.current.dateComponents([.month], from: birthDate, to: deathDate).month ?? 0
    }
    
    private var monthsLived: Int {
        let birthDate = userData.first?.birthDate ?? Date()
        return Calendar.current.dateComponents([.month], from: birthDate, to: Date()).month ?? 0
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // dismiss buton
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.gray)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                            )
                    }
                }
                    .padding(.leading, 16)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Life Progress")
                        .font(.custom("BebasNeue", size: 24))
                        .foregroundColor(Color(hex: "#fbf8ee"))
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color(hex: "#fbf8ee").opacity(0.1))
                            
                            Rectangle()
                                .fill(Color.green.opacity(0.8))
                                .frame(width: geometry.size.width * CGFloat(percentageLived / 100))
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .frame(height: 20)
                    
                    HStack {
                        Text("\(String(format: "%.1f", percentageLived))% Lived")
                            .foregroundColor(Color(hex: "#fbf8ee"))
                        Spacer()
                        Text("\(String(format: "%.1f", 100 - percentageLived))% Remaining")
                            .foregroundColor(Color(hex: "#fbf8ee").opacity(0.7))
                    }
                    .font(.custom("BebasNeue", size: 16))
                }
                .padding()
                .background(Color(hex: "#fbf8ee").opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(hex: "#fbf8ee"), lineWidth: 1)
                )
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    MetricCard(title: "Days Lived", value: "\(daysLived)", color: .green)
                    MetricCard(title: "Days Remaining", value: "\(daysRemaining)", color: .red)
                    MetricCard(title: "Weeks Lived", value: "\(daysLived / 7)", color: .blue)
                    MetricCard(title: "Months Lived", value: "\(daysLived / 30)", color: .orange)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Life in Months")
                        .font(.custom("BebasNeue", size: 24))
                        .foregroundColor(Color(hex: "#fbf8ee"))
                    
                    let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 20)
                    LazyVGrid(columns: columns, spacing: 4) {
                        ForEach(0..<totalMonths, id: \.self) { month in
                            Circle()
                                .fill(month < monthsLived ? Color(hex: "#fbf8ee") : Color(hex: "#fbf8ee").opacity(0.2))
                                .frame(width: 8, height: 8)
                        }
                    }
                }
                .padding()
                .background(Color(hex: "#fbf8ee").opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(hex: "#fbf8ee"), lineWidth: 1)
                )
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Life Statistics")
                        .font(.custom("BebasNeue", size: 24))
                        .foregroundColor(Color(hex: "#fbf8ee"))
                    
                    StatRow(title: "Estimated Heartbeats", value: "\((daysLived * 24 * 60 * 80).formatted())", icon: "heart.fill")
                    StatRow(title: "Breaths Taken", value: "\((daysLived * 24 * 60 * 12).formatted())", icon: "lungs.fill")
                    StatRow(title: "Hours Slept", value: "\((daysLived * 8).formatted())", icon: "moon.fill")
                    StatRow(title: "Meals Eaten", value: "\((daysLived * 3).formatted())", icon: "fork.knife")
                }
                .padding()
                .background(Color(hex: "#fbf8ee").opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color(hex: "#fbf8ee"), lineWidth: 1)
                )
            }
            .padding()
        }
        
        .background(Color(hex: "#0d1824"))
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.custom("BebasNeue", size: 30))
                .foregroundColor(color)
            Text(title)
                .font(.custom("BebasNeue", size: 16))
                .foregroundColor(color.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.2))
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(color.opacity(0.5), lineWidth: 1)
        )
    }
}

struct StatRow: View {
    let title: String
    let value: String
    let icon: String
    
    private var iconColor: Color {
        switch icon {
        case "heart.fill":
            return .red
        case "lungs.fill":
            return .blue
        case "moon.fill":
            return .yellow
        case "fork.knife":
            return .orange
        default:
            return Color(hex: "#fbf8ee")
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 30)
            
            Text(title)
                .foregroundColor(Color(hex: "#fbf8ee").opacity(0.7))
            
            Spacer()
            
            Text(value)
                .foregroundColor(Color(hex: "#fbf8ee"))
        }
    }
}
