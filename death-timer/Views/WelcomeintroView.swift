//
//  WelcomeintroView.swift
//  death-timer
//
//  Created by Ali Siddique on 11/17/24.
//

import SwiftUI

import SwiftUI
struct SmoothlyAnimatedText: View {
    let text: String
    let delay: Double
    @State private var opacity: Double = 0
    @State private var offset: CGFloat = 20
    
    var body: some View {
        Text(text)
            .opacity(opacity)
            .offset(y: offset)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8).delay(delay)) {
                    opacity = 1
                    offset = 0
                }
            }
    }
}

struct TypewriterText: View {
    let text: String
    let onComplete: () -> Void
    @State private var displayedText = ""
    @State private var currentIndex = 0
    
    var body: some View {
        Text(displayedText)
            .font(.custom("BebasNeue", size: 50))
            .foregroundColor(Color(hex:"#fbf8ee"))
            .multilineTextAlignment(.leading)
            .minimumScaleFactor(0.7) // Allow text to scale down if needed
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 40)
            .frame(maxWidth: UIScreen.main.bounds.width - 48) // Ensure text stays within screen
            .onAppear {
                displayedText = ""
                currentIndex = 0
                startTyping()
            }
    }
    
     func startTyping() {
        let characters = Array(text)
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if currentIndex < characters.count {
                displayedText += String(characters[currentIndex])
                HapticsManager.shared.impact(.heavy)
                currentIndex += 1
            } else {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    onComplete()
                }
            }
        }
    }
}

struct WelcomeIntroView: View {
    var onContinue: () -> Void
    let predictedDeathDate: Date
    let timeRemaining: TimeInterval
    
    private var formattedTimeRemaining: String {
        let years = Int(timeRemaining / (365.25 * 24 * 60 * 60))
        return "\(years) years"
    }
    
    private var phrases: [String] {
        [
            "You have approximately \(formattedTimeRemaining) left to live",
            "This isn't meant to frighten you",
            "It's a reminder to cherish every moment",
            "To pursue what truly matters",
            "To live authentically and purposefully",
            "Make every second count"
        ]
    }
    
    @State private var currentPhraseIndex = 0
    @State var position: CGSize = .zero
    @State private var showStartButton = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top padding
                Color.clear.frame(height: geometry.safeAreaInsets.top + 60)
                
                // Text content
                if currentPhraseIndex < phrases.count {
                    TypewriterText(
                        text: phrases[currentPhraseIndex],
                        onComplete: {
                            if currentPhraseIndex < phrases.count - 1 {
                                withAnimation {
                                    currentPhraseIndex += 1
                                }
                            } else {
                                // Show start button when all phrases are done
                                withAnimation(.easeIn(duration: 0.5)) {
                                    showStartButton = true
                                }
                            }
                        }
                    )
                    .id(currentPhraseIndex)
                }
                Text("Disclaimer: This is app does not accurately predict your death, it is based on the average life expectancy based on your country and other factors and should not be taken literally .")
                    .font(.custom("BebasNeue", size: 15))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                if showStartButton {
                    Spacer()
                    Button(action: {
                        HapticsManager.shared.impact(.heavy)
                        onContinue()
                    }) {
                        Text("Start Living")
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
                    Spacer()
                }
                
                Spacer()
            }
            .background(Color(hex: "#0d1824"))
        }
    }
    

    
}
