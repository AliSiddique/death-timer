//
//  Onboardingview.swift
//  death-timer
//
//  Created by Ali Siddique on 11/13/24.
//

import SwiftUI
struct Question{
    let text: String
    let options: [String]
}
struct QuizView: View {
    var onQuizComplete: (Date) -> Void
    @Environment(\.modelContext) private var modelContext
    @State private var answers: [String] = []
    @State private var currentQuestionIndex = 0 
    @State private var progress: CGFloat = 0
    @State private var offset: CGFloat = 0
    @State private var selectedCountry = ""
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    static let averageLifeExpectancy: [String: Int] = [
        "Afghanistan": 65,
        "Albania": 79,
        "Algeria": 77,
        "Andorra": 84,
        "Angola": 62,
        "Antigua and Barbuda": 77,
        "Argentina": 77,
        "Armenia": 75,
        "Australia": 83,
        "Austria": 82,
        "Azerbaijan": 73,
        "Bahamas": 73,
        "Bahrain": 79,
        "Bangladesh": 73,
        "Barbados": 79,
        "Belarus": 75,
        "Belgium": 82,
        "Belize": 75,
        "Benin": 62,
        "Bhutan": 72,
        "Bolivia": 71,
        "Bosnia and Herzegovina": 78,
        "Botswana": 70,
        "Brazil": 76,
        "Brunei": 77,
        "Bulgaria": 75,
        "Burkina Faso": 62,
        "Burundi": 63,
        "Cabo Verde": 74,
        "Cambodia": 71,
        "Cameroon": 60,
        "Canada": 83,
        "Central African Republic": 55,
        "Chad": 55,
        "Chile": 80,
        "China": 77,
        "Colombia": 77,
        "Comoros": 65,
        "Congo (Congo-Brazzaville)": 65,
        "Costa Rica": 80,
        "Croatia": 79,
        "Cuba": 79,
        "Cyprus": 82,
        "Czech Republic": 80,
        "Denmark": 81,
        "Djibouti": 67,
        "Dominica": 78,
        "Dominican Republic": 74,
        "Ecuador": 77,
        "Egypt": 72,
        "El Salvador": 74,
        "Equatorial Guinea": 58,
        "Eritrea": 66,
        "Estonia": 79,
        "Eswatini": 60,
        "Ethiopia": 66,
        "Fiji": 67,
        "Finland": 82,
        "France": 82,
        "Gabon": 66,
        "Gambia": 62,
        "Georgia": 74,
        "Germany": 81,
        "Ghana": 64,
        "Greece": 82,
        "Grenada": 73,
        "Guatemala": 74,
        "Guinea": 61,
        "Guinea-Bissau": 59,
        "Guyana": 69,
        "Haiti": 65,
        "Honduras": 75,
        "Hungary": 77,
        "Iceland": 83,
        "India": 71,
        "Indonesia": 72,
        "Iran": 77,
        "Iraq": 71,
        "Ireland": 82,
        "Israel": 83,
        "Italy": 83,
        "Jamaica": 74,
        "Japan": 85,
        "Jordan": 74,
        "Kazakhstan": 73,
        "Kenya": 67,
        "Kiribati": 68,
        "Kuwait": 76,
        "Kyrgyzstan": 72,
        "Laos": 67,
        "Latvia": 75,
        "Lebanon": 79,
        "Lesotho": 59,
        "Liberia": 65,
        "Libya": 73,
        "Lithuania": 75,
        "Luxembourg": 82,
        "Madagascar": 67,
        "Malawi": 65,
        "Malaysia": 76,
        "Maldives": 78,
        "Mali": 60,
        "Malta": 83,
        "Marshall Islands": 71,
        "Mauritania": 65,
        "Mauritius": 74,
        "Mexico": 75,
        "Micronesia": 67,
        "Moldova": 71,
        "Monaco": 85,
        "Mongolia": 70,
        "Montenegro": 77,
        "Morocco": 76,
        "Mozambique": 60,
        "Myanmar": 68,
        "Namibia": 65,
        "Nepal": 71,
        "Netherlands": 82,
        "New Zealand": 82,
        "Nicaragua": 75,
        "Niger": 62,
        "Nigeria": 55,
        "North Korea": 72,
        "North Macedonia": 76,
        "Norway": 83,
        "Oman": 77,
        "Pakistan": 67,
        "Palau": 74,
        "Panama": 78,
        "Papua New Guinea": 64,
        "Paraguay": 74,
        "Peru": 77,
        "Philippines": 71,
        "Poland": 78,
        "Portugal": 82,
        "Qatar": 80,
        "Romania": 76,
        "Russia": 72,
        "Rwanda": 69,
        "Saint Kitts and Nevis": 75,
        "Saint Lucia": 76,
        "Saint Vincent and the Grenadines": 73,
        "Samoa": 74,
        "San Marino": 85,
        "Sao Tome and Principe": 67,
        "Saudi Arabia": 75,
        "Senegal": 67,
        "Serbia": 76,
        "Seychelles": 73,
        "Sierra Leone": 54,
        "Singapore": 84,
        "Slovakia": 77,
        "Slovenia": 82,
        "Solomon Islands": 72,
        "Somalia": 57,
        "South Africa": 64,
        "South Korea": 84,
        "South Sudan": 58,
        "Spain": 84,
        "Sri Lanka": 77,
        "Sudan": 66,
        "Suriname": 72,
        "Sweden": 83,
        "Switzerland": 84,
        "Syria": 71,
        "Taiwan": 81,
        "Tajikistan": 71,
        "Tanzania": 66,
        "Thailand": 77,
        "Timor-Leste": 69,
        "Togo": 61,
        "Tonga": 71,
        "Trinidad and Tobago": 73,
        "Tunisia": 77,
        "Turkey": 78,
        "Turkmenistan": 68,
        "Tuvalu": 67,
        "Uganda": 63,
        "Ukraine": 71,
        "United Arab Emirates": 78,
        "United Kingdom": 81,
        "United States": 79,
        "Uruguay": 78,
        "Uzbekistan": 72,
        "Vanuatu": 71,
        "Vatican City": 84,
        "Venezuela": 72,
        "Vietnam": 75,
        "Yemen": 66,
        "Zambia": 65,
        "Zimbabwe": 62
    ]

    let questions: [Question] = [
        Question(text: "What is your birthdate?",
                options: ["DatePicker"]),
        
        Question(text: "Which country do you live in?",
                options: Array(QuizView.averageLifeExpectancy.keys).sorted()),
        
        Question(text: "What is your biological sex?",
                options: ["Male", "Female"]),
        
        Question(text: "How would you rate your overall health?",
                options: ["Excellent", "Good", "Fair", "Poor"]),
        
        // Lifestyle Questions
        Question(text: "How often do you exercise?",
                options: ["Daily", "3-4 times a week", "1-2 times a week", "Rarely"]),
        
        Question(text: "How would you describe your diet?",
                options: ["Very healthy", "Moderately healthy", "Somewhat unhealthy", "Very unhealthy"]),
        
        Question(text: "How many hours of sleep do you typically get?",
                options: ["8+ hours", "6-7 hours", "4-5 hours", "Less than 4 hours"]),
        
        Question(text: "Do you smoke?",
                options: ["Never", "Occasionally", "Regularly", "Heavy smoker"]),
        
        Question(text: "How often do you consume alcohol?",
                options: ["Never", "Occasionally", "Weekly", "Daily"]),
        
        Question(text: "How would you rate your stress levels?",
                options: ["Very low", "Moderate", "High", "Very high"]),
        
        Question(text: "Do you have any chronic health conditions?",
                options: ["None", "One", "Two", "Three or more"]),
        
        Question(text: "Is there a history of longevity in your family?",
                options: ["Yes, many lived past 90", "Yes, most lived past 80", "Average lifespan", "Below average lifespan"])
    ]
    
    var body: some View {
      ZStack {
            BackgroundView()
            
            VStack(spacing: 20) {
                ProgressHeader(
                    currentQuestionIndex: $currentQuestionIndex,
                    progress: $progress,
                    totalQuestions: questions.count,
                    updateProgress: updateProgress
                )
                
                QuestionPager(
                    questions: questions,
                    currentQuestionIndex: $currentQuestionIndex,
                    answers: $answers,
                    selectedCountry: $selectedCountry,
                    selectAnswer: selectAnswer
                )
                NextButton(
                    currentQuestionIndex: currentQuestionIndex,
                    totalQuestions: questions.count
                ) {
                    if currentQuestionIndex < questions.count - 1 {
                        withAnimation {
                            currentQuestionIndex += 1
                        }
                    }
                }
            }
            .padding()
        }
        .onAppear { updateProgress() }
    }
    
    
    private func selectAnswer(_ answer: String) {
        answers.append(answer)
        if currentQuestionIndex < questions.count - 1 {
            withAnimation {
                currentQuestionIndex += 1
                updateProgress()
            }
        } else {
            // Calculate and save death date when quiz completes
            let predictedDate = calculateDeathDate(answers: answers, country: selectedCountry)
            saveUserData(predictedDeathDate: predictedDate)
            onQuizComplete(predictedDate)
        }
    }
    
    private func saveUserData(predictedDeathDate: Date) {
        guard let birthDate = answers.first.flatMap({ DateFormatter.birthDateFormatter.date(from: $0) }) else { return }
        
        let userData = UserData(
            name: "",
            birthDate: birthDate,
            timerStartDate: Date()
        )
        userData.predictedDeathDate = predictedDeathDate
        userData.country = selectedCountry
        userData.quizResponses = answers.enumerated().map { index, answer in
            QuizResponse(
                question: questions[index].text,
                answer: answer,
                category: .lifestyle
            )
        }
        modelContext.insert(userData)
    }
    
    private func updateProgress() {
        withAnimation(.easeInOut(duration: 0.3)) {
            progress = CGFloat(currentQuestionIndex) / CGFloat(questions.count - 1)
        }
    }
    
    private func calculateDeathDate(answers: [String], country: String) -> Date {
        var lifeExpectancy = QuizView.averageLifeExpectancy[country] ?? 75
        
        for (index, answer) in answers.enumerated() {
            switch index {
            case 2: // Biological sex
                if answer == "Female" { lifeExpectancy += 8 } // Increased from 5
                
            case 3: // Overall health
                switch answer {
                case "Excellent": lifeExpectancy += 10
                case "Good": lifeExpectancy += 5
                case "Fair": lifeExpectancy -= 5
                case "Poor": lifeExpectancy -= 10
                default: break
                }
                
            case 4: // Exercise
                switch answer {
                case "Daily": lifeExpectancy += 8
                case "3-4 times a week": lifeExpectancy += 5
                case "1-2 times a week": lifeExpectancy += 2
                case "Rarely": lifeExpectancy -= 5
                default: break
                }
                
            case 5: // Diet
                switch answer {
                case "Very healthy": lifeExpectancy += 8
                case "Moderately healthy": lifeExpectancy += 4
                case "Somewhat unhealthy": lifeExpectancy -= 4
                case "Very unhealthy": lifeExpectancy -= 8
                default: break
                }
                
            case 6: // Sleep
                switch answer {
                case "8+ hours": lifeExpectancy += 6
                case "6-7 hours": lifeExpectancy += 2
                case "4-5 hours": lifeExpectancy -= 4
                case "Less than 4 hours": lifeExpectancy -= 8
                default: break
                }
                
            case 7: // Smoking
                switch answer {
                case "Never": lifeExpectancy += 5
                case "Occasionally": lifeExpectancy -= 5
                case "Regularly": lifeExpectancy -= 10
                case "Heavy smoker": lifeExpectancy -= 15
                default: break
                }
                
            case 8: // Alcohol
                switch answer {
                case "Never": lifeExpectancy += 5
                case "Occasionally": lifeExpectancy += 0
                case "Weekly": lifeExpectancy -= 5
                case "Daily": lifeExpectancy -= 10
                default: break
                }
                
            case 9: // Stress
                switch answer {
                case "Very low": lifeExpectancy += 6
                case "Moderate": lifeExpectancy += 0
                case "High": lifeExpectancy -= 4
                case "Very high": lifeExpectancy -= 8
                default: break
                }
                
            case 10: // Chronic conditions
                switch answer {
                case "None": lifeExpectancy += 5
                case "One": lifeExpectancy -= 4
                case "Two": lifeExpectancy -= 8
                case "Three or more": lifeExpectancy -= 12
                default: break
                }
                
            case 11: // Family history
                switch answer {
                case "Yes, many lived past 90": lifeExpectancy += 10
                case "Yes, most lived past 80": lifeExpectancy += 6
                case "Average lifespan": lifeExpectancy += 0
                case "Below average lifespan": lifeExpectancy -= 6
                default: break
                }
                
            default:
                break
            }
        }
        
        // Calculate death date based on birthdate and adjusted life expectancy
        guard let birthDate = answers.first.flatMap({ DateFormatter.birthDateFormatter.date(from: $0) }) else {
            return Date().addingTimeInterval(TimeInterval(Int(lifeExpectancy) * 365 * 24 * 60 * 60))
        }
        
        let calendar = Calendar.current
        let yearsToAdd = Int(lifeExpectancy)
        
        if let deathDate = calendar.date(byAdding: .year, value: yearsToAdd, to: birthDate) {
            return deathDate
        }
        
        return Date().addingTimeInterval(TimeInterval(yearsToAdd * 365 * 24 * 60 * 60))
    }
}


class HapticsManager {
    static let shared = HapticsManager()
    
    private init() { }
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
}

// Add this extension for date formatting
extension DateFormatter {
    static let birthDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

// Background View
struct BackgroundView: View {
    var body: some View {
        Color(hex: "#0A0A1E").edgesIgnoringSafeArea(.all)
    }
}

// Progress Header
struct ProgressHeader: View {
    @Binding var currentQuestionIndex: Int
    @Binding var progress: CGFloat
    let totalQuestions: Int
    let updateProgress: () -> Void
    
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                BackButton(currentQuestionIndex: $currentQuestionIndex, updateProgress: updateProgress)
                ProgressBar(progress: progress)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            Text("Question \(currentQuestionIndex + 1) of \(totalQuestions)")
                .foregroundColor(.white.opacity(0.6))
                .font(.custom("BebasNeue", size: 20))
                .multilineTextAlignment(.leading)
                .padding(.top)
        }
    }
}

// Back Button
struct BackButton: View {
    @Binding var currentQuestionIndex: Int
    let updateProgress: () -> Void
    
    var body: some View {
        Button(action: {
            if currentQuestionIndex > 0 {
                withAnimation {
                    currentQuestionIndex -= 1
                    updateProgress()
                }
            }
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.white)
                .imageScale(.large)
                .frame(width: 32, height: 32)
        }
        .opacity(currentQuestionIndex > 0 ? 1 : 0)
    }
}


// Progress Bar
struct ProgressBar: View {
    let progress: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(Color(.systemGray6))
                    .frame(height: 4)
                    .cornerRadius(20)
                
                Rectangle()
                    .foregroundColor(Color.accentColor)
                    .frame(width: geometry.size.width * progress, height: 4)
                    .cornerRadius(20)
            }
        }
        .frame(height: 4)
    }
}



// Question Pager
struct QuestionPager: View {
    let questions: [Question]
    @Binding var currentQuestionIndex: Int
    @Binding var answers: [String]
    @Binding var selectedCountry: String
    let selectAnswer: (String) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                // Questions Container
                VStack {
                    HStack(spacing: 0) {
                        ForEach(0..<questions.count, id: \.self) { index in
                            QuestionView(
                                question: questions[index],
                                answers: $answers,
                                currentQuestionIndex: $currentQuestionIndex,
                                selectedCountry: $selectedCountry,
                                selectAnswer: selectAnswer
                            )
                            .frame(width: geometry.size.width)
                        }
                    }
                    .offset(x: -CGFloat(currentQuestionIndex) * geometry.size.width)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentQuestionIndex)
                }
                .frame(height: geometry.size.height * 0.8)
                
                Spacer()
                
                // Next Button
                // Usage in QuestionPager:
                NextButton(
                    currentQuestionIndex: currentQuestionIndex,
                    totalQuestions: questions.count
                ) {
                    if currentQuestionIndex < questions.count - 1 {
                        withAnimation {
                            currentQuestionIndex += 1
                        }
                    }
                }
                Button(action: {
                    if currentQuestionIndex < questions.count - 1 {
                        withAnimation {
                            currentQuestionIndex += 1
                        }
                    }
                }) {
                    Text("Next")
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
                .padding(.horizontal)
                .opacity(currentQuestionIndex < questions.count - 1 ? 1 : 0)
            }
        }
    }
}
struct NextButton: View {
    let currentQuestionIndex: Int
    let totalQuestions: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text("Next")
                    .font(.custom("BebasNeue", size: 20))
                Image(systemName: "chevron.right")
            }
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
        .padding(.horizontal)
        .opacity(currentQuestionIndex < totalQuestions - 1 ? 1 : 0)
    }
}



// Individual Question View
struct QuestionView: View {
    let question: Question
    @Binding var answers: [String]
    @Binding var currentQuestionIndex: Int
    @Binding var selectedCountry: String
    let selectAnswer: (String) -> Void
    
    var body: some View {
        VStack {
            if question.text.contains("birthdate") {
                BirthDatePicker(answers: $answers, currentQuestionIndex: $currentQuestionIndex)
            } else if question.text.contains("country") {
                CountryPicker(selectedCountry: $selectedCountry)
            } else {
                StandardQuestion(question: question, selectAnswer: selectAnswer)
            }
            
        }
    }
}


// Birth Date Picker
struct BirthDatePicker: View {
    @Binding var answers: [String]
    @Binding var currentQuestionIndex: Int
    
    var body: some View {
        DatePicker("Select your birthdate",
                  selection: .init(get: {
                      answers.indices.contains(0) ?
                          DateFormatter.birthDateFormatter.date(from: answers[0]) ?? Date() :
                          Date()
                  }, set: { newDate in
                      if answers.isEmpty {
                          answers.append(DateFormatter.birthDateFormatter.string(from: newDate))
                      } else {
                          answers[0] = DateFormatter.birthDateFormatter.string(from: newDate)
                      }
                  }),
                  in: ...Date(),
                  displayedComponents: .date)
            .datePickerStyle(.wheel)
            .accentColor(.mint)
            .padding()
    }
}


// Country Picker
struct CountryPicker: View {
    @Binding var selectedCountry: String
    
    var body: some View {
        Picker("Select your country", selection: $selectedCountry) {
            ForEach(Array(QuizView.averageLifeExpectancy.keys).sorted(), id: \.self) { country in
                Text(country)
                    .foregroundColor(.white)
            }
        }
        .pickerStyle(.wheel)
        .accentColor(.mint)
        .padding()
    }
}

// Standard Question
struct StandardQuestion: View {
    let question: Question
    let selectAnswer: (String) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text(question.text)
                .font(.custom("BebasNeue", size: 40))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)
                .lineLimit(2)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                ForEach(question.options, id: \.self) { option in
                    AnswerButton(option: option, selectAnswer: selectAnswer)
                }
            }
            .padding()
        }
    }
}


// Answer Button
struct AnswerButton: View {
    let option: String
    let selectAnswer: (String) -> Void
    
    var body: some View {
        Button(action: {
            HapticsManager.shared.impact(.medium)
            selectAnswer(option)
        }) {
            Text(option)
                .font(.custom("BebasNeue", size: 20))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.3))
                .cornerRadius(10)
            
            
        }
    }
}

struct OnboardingView: View {
    @State private var currentStep: OnboardingStep = .start
    @State private var predictedDeathDate: Date?
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    
    enum OnboardingStep {
        case start
        case quiz
        case welcome
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            switch currentStep {
            case .start:
                StartQuizView {
                    withAnimation {
                        currentStep = .quiz
                    }
                }
                
            case .quiz:
                QuizView(onQuizComplete: { deathDate in
                    predictedDeathDate = deathDate
                    withAnimation {
                        currentStep = .welcome
                    }
                })
                
            case .welcome:
                if let deathDate = predictedDeathDate {
                    WelcomeIntroView(
                        onContinue: {
                            isOnboarding = false // Proceed to main app
                        },
                        predictedDeathDate: deathDate,
                        timeRemaining: deathDate.timeIntervalSince(Date())
                    )
                }
            }
        }
    }
}
