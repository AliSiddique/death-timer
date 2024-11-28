import SwiftUI
import SwiftUI
import SwiftData
import StoreKit
import SwiftUI
import SwiftData
import SwiftUI
import SwiftData
import SuperwallKit
struct BucketListItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [BucketListItem]
    @State private var showingAddSheet = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#0d1824")
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                            NavigationLink(destination: BucketListItemDetailView(item: item)) {
                                ItemCard(item: item, number: index + 1)
                            }
                        }
                        .onMove { from, to in
                            var updatedItems = items
                            updatedItems.move(fromOffsets: from, toOffset: to)
                            // Update order in the database
                            for (index, item) in updatedItems.enumerated() {
                                item.order = index
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Bucket List")
            .navigationBarTitleDisplayMode(.large)
            .foregroundColor(.white)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
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
                AddBucketListItemView()
                    .presentationDetents([.medium])
                    .presentationCornerRadius(32)
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(items[index])
        }
    }
}

struct ItemCard: View {
    let item: BucketListItem
    let number: Int
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Text("\(number)")
                .font(.system(.headline, design: .rounded))
                .foregroundColor(Color(hex: "#fbf8ee"))
                .frame(width: 24)
            
            Circle()
                .fill(item.isCompleted ? Color.green : Color(hex: "#fbf8ee"))
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                
                HStack(spacing: 12) {
                    Label(item.category.rawValue.capitalized, systemImage: "folder.fill")
                    Label(item.priority.rawValue.capitalized, systemImage: "flag.fill")
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

struct AddBucketListItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var items: [BucketListItem]
    
    @State private var title = ""
    @State private var content = ""
    @State private var category = BucketListCategory.personal
    @State private var priority = Priority.medium
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#0d1824")
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        RoundedInputField(title: "Title", text: $title, icon: "pencil.line")
                        RoundedInputField(title: "Content", text: $content, icon: "text.justify")
                        
                        RoundedPicker(title: "Category", selection: $category, icon: "folder.fill") {
                            ForEach(BucketListCategory.allCases, id: \.self) { category in
                                Text(category.rawValue.capitalized)
                                    .tag(category)
                                    .foregroundStyle(.white)
                            }
                        }
                        
                        RoundedPicker(title: "Priority", selection: $priority, icon: "flag.fill") {
                            ForEach(Priority.allCases, id: \.self) { priority in
                                Text(priority.rawValue.capitalized)
                                    .tag(priority)
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .padding(.horizontal)
                    if items.count > 1 && Superwall.shared.subscriptionStatus == .inactive {
                        Button(action: {
                            Superwall.shared.register(event: "paid")
                        }) {
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
                    } else{
                        Button(action: saveItem) {
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
                  
                }
                .padding(.top, 20)
            }
            .navigationTitle("New Item")
            .navigationBarTitleDisplayMode(.inline)
            .foregroundColor(.white)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                        HapticsManager.shared.impact(.heavy)
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
    
    private func saveItem() {
        HapticsManager.shared.impact(.heavy)

        if items.count == 0 {
            // Show review request on first item
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
            // Show Superwall paywall
       
        

        let item = BucketListItem(title: title, content: content, category: category, priority: priority)
        modelContext.insert(item)
        dismiss()
    }
}

struct RoundedPicker<SelectionValue: Hashable, Content: View>: View {
    let title: String
    @Binding var selection: SelectionValue
    let icon: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 24)
            
            Picker(title, selection: $selection) {
                content()
            }
            .pickerStyle(.menu)
            .tint(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }
}

struct RoundedInputField: View {
    let title: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.secondary)
                .frame(width: 24)
            
            TextField(title, text: $text)
                .textFieldStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }
}



struct BucketListItemDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var item: BucketListItem
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                RoundedInputField(title: "Title", text: $item.title, icon: "pencil.line")
                RoundedInputField(title: "Content", text: $item.content, icon: "text.justify")
                
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Completed", isOn: $item.isCompleted)
                        .tint(.blue)
                    
                    if item.isCompleted {
                        Text("Completed: \(item.completedDate?.formatted() ?? "N/A")")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(uiColor: .secondarySystemBackground))
                )
            }
            .padding()
        }
        .navigationTitle("Edit Item")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(uiColor: .systemBackground))
    }
}

#Preview {
    BucketListItemView()
        
}
