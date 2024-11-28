import SwiftUI
import SwiftData
struct ReflectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var reflections: [Reflection]
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(reflections) { reflection in
                    NavigationLink(destination: ReflectionDetailView(reflection: reflection)) {
                        VStack(alignment: .leading) {
                            Text(reflection.type.rawValue.capitalized)
                                .font(.headline)
                            Text(reflection.date.formatted())
                                .font(.subheadline)
                            if !reflection.content.isEmpty {
                                Text(reflection.content)
                                    .lineLimit(2)
                                    .font(.caption)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Reflections")
            .toolbar {
                Button("Add Reflection") {
                    showingAddSheet.toggle()
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddReflectionView()
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(reflections[index])
        }
    }
}

struct AddReflectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var content = ""
    @State private var type = ReflectionType.daily
    @State private var tags: String = ""
    @State private var energyLevel: Double = 5
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Content", text: $content, axis: .vertical)
                    .lineLimit(5...10)
                
                Picker("Type", selection: $type) {
                    ForEach(ReflectionType.allCases, id: \.self) { type in
                        Text(type.rawValue.capitalized)
                    }
                }
                
                TextField("Tags (comma separated)", text: $tags)
                
                Section("Energy Level: \(Int(energyLevel))") {
                    Slider(value: $energyLevel, in: 1...10, step: 1)
                }
            }
            .navigationTitle("New Reflection")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        HapticsManager.shared.impact(.heavy)

                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        HapticsManager.shared.impact(.heavy)

                        let reflection = Reflection(content: content, type: type)
                        reflection.tags = tags.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
                        reflection.energyLevel = Int(energyLevel)
                        modelContext.insert(reflection)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ReflectionDetailView: View {
    @Bindable var reflection: Reflection
    
    var body: some View {
        Form {
            TextField("Content", text: $reflection.content, axis: .vertical)
                .lineLimit(5...10)
            
            Text("Date: \(reflection.date.formatted())")
            
            if let energyLevel = reflection.energyLevel {
                Text("Energy Level: \(energyLevel)")
            }
            
            Section("Tags") {
                ForEach(reflection.tags, id: \.self) { tag in
                    Text(tag)
                }
            }
        }
        .navigationTitle("Edit Reflection")
    }
} 
