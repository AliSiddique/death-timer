//
//  RatingView.swift
//  death-timer
//
//  Created by Ali Siddique on 11/17/24.
//

import SwiftUI

//
//  ReviewsView.swift
//  no-nut
//
//  Created by Ali Siddique on 11/7/24.
//

import SwiftUI

import SwiftUI
import StoreKit

struct RatingView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var rating: Int = 5
    @State private var isAnimated = false
    @State private var hasShownReview = false
    @State private var showRatingView = false
    let reviewData = [
     
        ReviewData(
            name: "Sarah Johnson",
            image: "person3",
            username: "@sarahj",
            text: "\"I’ve tried other apps, but Unbound's insights into my screen habits make a real difference. It’s like having a coach with me every step of the way.\""
        ),
        ReviewData(
            name: "Daniel Evans",
            image: "person4",
            username: "@dan_evans",
            text: "\"Unbound helped me regain control and focus. The daily Stoic reminders keep me motivated and grounded—highly recommend!\""
        ),
        ReviewData(
            name: "Emma Fitzgerald",
            image: "person5",
            username: "@emma_fitzy",
            text: "\"I didn’t realise how much screen time impacted me until I used Unbound. The community support feature has also been great to connect with others on a similar journey.\""
        ),
        ReviewData(
            name: "James Parker",
            image: "person6",
            username: "@jparker88",
            text: "\"The tracking tools in Unbound keep me accountable, and I love the privacy-focused approach. It's empowering to see my progress every day.\""
        ),
        ReviewData(
            name: "Linda Thompson",
            image: "person1",
            username: "@lindat",
            text: "\"The Stoic quotes and advice Unbound sends really help me stay focused. It's more than an app; it’s a guide.\""
        ),
        ReviewData(
            name: "Alex Morgan",
            image: "person2",
            username: "@alexmorgan",
            text: "\"I was struggling to stay motivated, but Unbound’s features make it easier to resist temptation and stay committed to my goals.\""
        ),
        ReviewData(
            name: "Rebecca Lee",
            image: "person3",
            username: "@rebecca_lee",
            text: "\"Unbound’s insights have been eye-opening, and the progress tracker keeps me moving forward. It’s a solid tool for anyone serious about making a change.\""
        ),
        ReviewData(
            name: "Chris Davies",
            image: "person4",
            username: "@chrisd",
            text: "\"This app changed my life. The combination of Stoic wisdom, community support, and practical tools make it truly unique and effective.\""
        )
    ]

    
    var body: some View {
        ZStack {
          
        
                VStack(spacing: 0) {
                    // Back button
                
                    
                    Spacer(minLength: 20)
                    
                    // Title section
                    VStack(spacing: 16) {
                        Text("Give us a rating")
                            .font(.custom("BebasNeue", size: 40))
                            .foregroundColor(Color(hex:"#fbf8ee"))
                        
                        // Stars with laurel wreath
                        HStack(spacing: 0) {
//                            Text("🌿")
//                                .font(.system(size: 32))
//                                .rotationEffect(.degrees(180))
                            
                            HStack(spacing: 4) {
                                ForEach(1...5, id: \.self) { star in
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(.yellow)
                                        .scaleEffect(isAnimated ? 1.0 : 0.8)
                                }
                            }
                            .padding(.horizontal, 8)
                            
//                            Text("🌿")
//                                .font(.system(size: 32))
                        }
                    }
                    .padding(.bottom, 20)
                    
                    // Subtitle and user count
                    VStack(spacing: 16) {
                        Text("This app was designed for people\nlike you.")
                            .font(.custom("BebasNeue", size: 25))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(hex:"#fbf8ee"))
                        
//                        HStack(spacing: -8) {
//                            ForEach(0..<3) { index in
//                                Circle()
//                                    .fill(Color.gray.opacity(0.3))
//                                    .frame(width: 28, height: 28)
//                                    .overlay(
//                                        Circle()
//                                            .stroke(Color(hex: "#0A0A1E"), lineWidth: 2)
//                                    )
//                            }
//                            Text("+ 100,000 people")
//                                .font(.system(size: 16))
//                                .foregroundColor(.gray)
//                                .padding(.leading, 16)
//                        }
                    }
                    .padding(.bottom, 20)
                    
                    Spacer(minLength: 20)
                    
                    // Reviews
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            ForEach(reviewData) { review in
                                ReviewCards(
                                    name: review.name,
                                    image: review.image,
                                    username: review.username,
                                    text: review.text
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 20)
                    
                    // Next button make it sticky
                    VStack {
                                   Button(action: {
                                       if hasShownReview {
                                           HapticsManager.shared.impact(.medium)
                                           onContinue()
                                       } else {
                                           requestReview()
                                       }
                                   }) {
                                       Text("Next")
                                           .font(.system(size: 17, weight: .semibold))
                                           .foregroundColor(.black)
                                           .frame(maxWidth: .infinity)
                                           .frame(height: 44)
                                           .background(hasShownReview ? Color.white : Color.white.opacity(0.5))
                                           .cornerRadius(22)
                                   }
                                   .disabled(!hasShownReview)
                                   .padding(.horizontal, 20)
                                   .padding(.vertical, 16)
                               }
                    
                }
            }
        
        .background(Color(hex: "#0d1824"))
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).repeatCount(1)) {
                isAnimated = true
            }
            requestReview()
        }
    }
  
    
    private func requestReview() {
        guard let scene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene else { return }
        SKStoreReviewController.requestReview(in: scene)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            hasShownReview = true
        }
    }
    
    private func onContinue() {
        dismiss()
    }
}

struct ReviewCards: View {
    let name: String
    let image:String
     let username: String
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Text(username)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                HStack(spacing: 1) {
                    ForEach(0..<5) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.yellow)
                    }
                }
            }
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(2)
                .lineLimit(4)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 25/255, green: 25/255, blue: 45/255).opacity(0.7))
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .opacity(0.5)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
struct ReviewData: Identifiable {
    let id = UUID()
    let name: String
    let image: String

    let username: String
    let text: String
}
#Preview{
    RatingView()
}
