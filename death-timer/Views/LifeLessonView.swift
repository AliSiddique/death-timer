import SwiftUI
import SwiftData

import SwiftUI
import SwiftData

struct LifeLessonView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var lessons: [LifeLesson]
    @State private var showingAddSheet = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#0d1824")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(lessons) { lesson in
                            NavigationLink(destination: LifeLessonDetailView(lesson: lesson)) {
                                LessonCard(lesson: lesson)
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Life Lessons")
            .navigationBarTitleDisplayMode(.large)
            .foregroundColor(.white)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticsManager.shared.impact(.heavy)

                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundStyle(Color(hex: "#fbf8ee"))
                            .frame(width: 32, height: 32)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
            }
            
            .overlay(alignment: .bottomTrailing) {
                Button(action: { showingAddSheet.toggle() }) {
                    Image(systemName: "plus")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(
                            Circle()
                                .fill(Color(hex:"#fbf8ee").opacity(0.3))
                                .overlay(
                                    Circle()
                                        .stroke(Color(hex:"#fbf8ee"), lineWidth: 2)
                                )
                        )
                }
                .padding(24)
            }
            .sheet(isPresented: $showingAddSheet) {
                AddLifeLessonView()
                    .presentationDetents([.large])
                    .presentationCornerRadius(32)
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        HapticsManager.shared.impact(.heavy)

        for index in offsets {
            modelContext.delete(lessons[index])
        }
    }
}

struct LessonCard: View {
    let lesson: LifeLesson
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Circle()
                .fill(Color(hex: "#fbf8ee"))
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(lesson.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                
                HStack(spacing: 12) {
                    Label(lesson.category.rawValue.capitalized, systemImage: "folder.fill")
                    Label(lesson.impact.rawValue.capitalized, systemImage: "flag.fill")
                }
                .font(.footnote)
                .foregroundStyle(Color(hex: "#fbf8ee").opacity(0.7))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(Color(hex: "#fbf8ee").opacity(0.7))
                .font(.footnote)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(hex: "#fbf8ee").opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(hex: "#fbf8ee"), lineWidth: 1)
                )
        )
    }
}

struct AddLifeLessonView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var content = ""
    @State private var category = LessonCategory.mindset
    @State private var impact = ImpactLevel.moderate
    @State private var tags: String = ""
    @State private var actionSteps: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#0d1824")
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        RoundedInputField(title: "Title", text: $title, icon: "pencil.line")
                        RoundedInputField(title: "Content", text: $content, icon: "text.justify")
                        RoundedInputField(title: "Tags (comma separated)", text: $tags, icon: "tag")
                        RoundedInputField(title: "Action Steps (comma separated)", text: $actionSteps, icon: "list.bullet")
                        
                        RoundedPicker(title: "Category", selection: $category, icon: "folder.fill") {
                            ForEach(LessonCategory.allCases, id: \.self) { category in
                                Text(category.rawValue.capitalized)
                                    .tag(category)
                                    .foregroundStyle(.white)
                            }
                        }
                        
                        RoundedPicker(title: "Impact", selection: $impact, icon: "flag.fill") {
                            ForEach(ImpactLevel.allCases, id: \.self) { impact in
                                Text(impact.rawValue.capitalized)
                                    .tag(impact)
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Button(action: saveLesson) {
                        Text("Add")
                            .font(.custom("BebasNeue", size: 20))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(hex:"#fbf8ee").opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 28))
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(Color(hex:"#fbf8ee"), lineWidth: 2)
                            )
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 20)
            }
            .navigationTitle("New Life Lesson")
            .navigationBarTitleDisplayMode(.inline)
            .foregroundColor(.white)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundStyle(Color(hex: "#fbf8ee"))
                            .frame(width: 32, height: 32)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
            }
        }
    }
    
    private func saveLesson() {
        let lesson = LifeLesson(title: title, content: content, category: category, impact: impact)
        lesson.tags = tags.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
        lesson.actionSteps = actionSteps.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
        modelContext.insert(lesson)
        dismiss()
    }
}
struct LifeLessonDetailView: View {
    @Bindable var lesson: LifeLesson
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                RoundedInputField(title: "Title", text: $lesson.title, icon: "pencil.line")
                RoundedInputField(title: "Content", text: $lesson.content, icon: "text.justify")
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Date: \(lesson.date.formatted())")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(uiColor: .secondarySystemBackground))
                )
                
                if !lesson.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(lesson.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color(uiColor: .tertiarySystemBackground))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(uiColor: .secondarySystemBackground))
                    )
                }
                
                if let actionSteps = lesson.actionSteps, !actionSteps.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Action Steps")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(actionSteps, id: \.self) { step in
                                HStack(spacing: 12) {
                                    Image(systemName: "circle")
                                        .font(.caption)
                                    Text(step)
                                        .font(.subheadline)
                                }
                                .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(uiColor: .secondarySystemBackground))
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Edit Life Lesson")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(uiColor: .systemBackground))
    }
}

// Helper view for tag layout
struct FlowLayout: Layout {
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, line) in result.lines.enumerated() {
            let yOffset = result.lineOffsets[index]
            var xOffset = bounds.minX
            
            for item in line {
                let itemSize = item.sizeThatFits(.unspecified)
                item.place(at: CGPoint(x: xOffset, y: yOffset), proposal: .unspecified)
                xOffset += itemSize.width + spacing
            }
        }
    }
    
    struct FlowResult {
        var lines: [[LayoutSubview]] = [[]]
        var lineOffsets: [CGFloat] = [0]
        var size: CGSize = .zero
        
        init(in width: CGFloat, subviews: LayoutSubviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var maxHeight: CGFloat = 0
            var lineIndex = 0
            
            for subview in subviews {
                let itemSize = subview.sizeThatFits(.unspecified)
                
                if currentX + itemSize.width > width && !lines[lineIndex].isEmpty {
                    currentX = 0
                    currentY += maxHeight + spacing
                    maxHeight = 0
                    lineIndex += 1
                    lines.append([])
                    lineOffsets.append(currentY)
                }
                
                lines[lineIndex].append(subview)
                currentX += itemSize.width + spacing
                maxHeight = max(maxHeight, itemSize.height)
            }
            
            size = CGSize(width: width, height: currentY + maxHeight)
        }
    }
}

#Preview {
    LifeLessonView()
        
}
