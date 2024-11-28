import SwiftUI
import SwiftData
struct QuizResponseView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var responses: [QuizResponse]
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(responses) { response in
                    NavigationLink(destination: QuizResponseDetailView(response: response)) {
                        VStack(alignment: .leading) {
                            Text(response.category.rawValue.capitalized)
                                .font(.headline)
                            Text(response.date.formatted())
                                .font(.subheadline)
                            if !response.answer.isEmpty {
                                Text(response.answer)
                                    .lineLimit(2)
                                    .font(.caption)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Quiz Responses")
            .toolbar {
                Button("Add Response") {
                    showingAddSheet.toggle()
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddQuizResponseView()
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(responses[index])
        }
    }
}

struct AddQuizResponseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var question = ""
    @State private var answer = ""
    @State private var category = QuizCategory.motivation
    @State private var tags: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Question", text: $question)
                TextField("Answer", text: $answer, axis: .vertical)
                    .lineLimit(3...8)
                
                Picker("Category", selection: $category) {
                    ForEach(QuizCategory.allCases, id: \.self) { category in
                        Text(category.rawValue.capitalized)
                    }
                }
                
                TextField("Tags (comma separated)", text: $tags)
            }
            .navigationTitle("New Quiz Response")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let response = QuizResponse(question: question, answer: answer, category: category)
                        modelContext.insert(response)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct QuizResponseDetailView: View {
    @Bindable var response: QuizResponse
    
    var body: some View {
        Form {
            TextField("Question", text: $response.question)
            TextField("Answer", text: $response.answer, axis: .vertical)
                .lineLimit(3...8)
            
            Text("Date: \(response.date.formatted())")
            
           
        }
        .navigationTitle("Edit Quiz Response")
    }
} 
