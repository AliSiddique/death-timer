import SwiftUI
struct StartQuizView: View {
    var onStartQuiz: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Disclaimer: This is app does not accurately predict your death, it is based on the average life expectancy based on your country and other factors and should not be taken literally .")
                .font(.custom("BebasNeue", size: 24))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                
            Text("Your Life in Perspective")
                .font(.custom("BebasNeue", size: 50))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
            
            Text("Take this brief assessment to gain a new perspective on the time you have.")
                .font(.custom("BebasNeue", size: 24))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: {
                HapticsManager.shared.impact(.heavy)
                onStartQuiz()
            }) {
                Text("Begin Assessment")
                    .font(.custom("BebasNeue", size: 24))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex:"#fbf8ee").opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 40))
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(Color(hex:"#fbf8ee"), lineWidth: 2)
                    )
            }
            .padding()
        }
        .padding()
        .background(Color(hex: "#0A0A1E"))
    }
} 
