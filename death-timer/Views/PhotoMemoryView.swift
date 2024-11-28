import SwiftUI
import SwiftData
import SuperwallKit
struct PhotoMemoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var memories: [PhotoMemory]
    @State private var showingAddSheet = false
    @State private var showingSlideshowView = false
    @State private var currentSlideIndex = 0
    @State private var isPlaying = false
    @State private var timer: Timer?
    @Environment(\.dismiss) private var dismiss
    var sortedMemories: [PhotoMemory] {
        memories.sorted { $0.date > $1.date }
    }
    @State private var showingFullscreenSlideshow = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#0d1824")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        if !memories.isEmpty {
                            slideshowSection
                            
                            Button(action: { showingFullscreenSlideshow = true }) {
                                HStack {
                                    Image(systemName: "play.rectangle.fill")
                                    Text("Full Screen Slideshow")
                                        .font(.custom("BebasNeue", size: 20))
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex:"#fbf8ee").opacity(0.2))
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 40))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 40)
                                        .stroke(Color(hex:"#fbf8ee"), lineWidth: 2)
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle("Photo Memories")
            .navigationBarTitleDisplayMode(.large)
            .foregroundColor(.white)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                   Button {
                       HapticsManager.shared.impact(.heavy)

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
            .fullScreenCover(isPresented: $showingFullscreenSlideshow) {
                FullscreenSlideshowView(memories: sortedMemories)
            }

            .sheet(isPresented: $showingAddSheet) {
                AddPhotoMemoryView()
                    .presentationDetents([.large])
                    .presentationCornerRadius(32)
            }
        }
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
    }
    
     var slideshowSection: some View {
        VStack(spacing: 16) {
            TabView(selection: $currentSlideIndex) {
                ForEach(Array(sortedMemories.enumerated()), id: \.element.id) { index, memory in
                    if let uiImage = UIImage(data: memory.imageData) {
                        ZStack(alignment: .bottom) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 400)
                                .clipShape(RoundedRectangle(cornerRadius: 25))
                            
                            LinearGradient(
                                colors: [.clear, .black.opacity(0.7)],
                                startPoint: .center,
                                endPoint: .bottom
                            )
                            .frame(height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(memory.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.system(.title3, design: .rounded))
                                    .bold()
                                
                                if !memory.tags.isEmpty {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            ForEach(memory.tags, id: \.self) { tag in
                                                Text(tag)
                                                    .font(.caption)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 6)
                                                    .background(
                                                        Capsule()
                                                            .fill(Color(hex: "#fbf8ee").opacity(0.3))
                                                    )
                                                    .overlay(
                                                        Capsule()
                                                            .stroke(Color(hex: "#fbf8ee"), lineWidth: 1)
                                                    )
                                            }
                                        }
                                    }
                                }
                            }
                            .padding()
                            .foregroundStyle(.white)
                        }
                        .tag(index)
                    }
                }
            }
            .tabViewStyle(.page)
            .frame(height: 400)
            
            HStack {
                Button(action: { playPreviousSlide() }) {
                    Image(systemName: "backward.fill")
                        .font(.title3)
                }
                .disabled(currentSlideIndex == 0)
                
                Button(action: { toggleSlideshow() }) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.title3)
                }
                
                Button(action: { playNextSlide() }) {
                    Image(systemName: "forward.fill")
                        .font(.title3)
                }
                .disabled(currentSlideIndex == sortedMemories.count - 1)
            }
            .foregroundStyle(Color(hex: "#fbf8ee"))
            .padding(.bottom)
        }
    }
    
     func toggleSlideshow() {
        isPlaying.toggle()
        if isPlaying {
            startSlideshow()
        } else {
            stopSlideshow()
        }
    }
    
     func startSlideshow() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            playNextSlide()
        }
    }
    
     func stopSlideshow() {
        timer?.invalidate()
        timer = nil
    }
    
     func playNextSlide() {
        withAnimation {
            if currentSlideIndex < sortedMemories.count - 1 {
                currentSlideIndex += 1
            } else {
                currentSlideIndex = 0
            }
        }
    }
    
     func playPreviousSlide() {
        withAnimation {
            currentSlideIndex = max(0, currentSlideIndex - 1)
        }
    }
    
     func deleteItems(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(memories[index])
        }
    }
}


struct FullscreenSlideshowView: View {
    let memories: [PhotoMemory]
    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex = 0
    @State private var isPlaying = false
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            TabView(selection: $currentIndex) {
                ForEach(Array(memories.enumerated()), id: \.element.id) { index, memory in
                    if let uiImage = UIImage(data: memory.imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .tag(index)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Controls overlay
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(Color(hex: "#fbf8ee"))
                    }
                    .padding()
                }
                
                Spacer()
                
                // Playback controls
                HStack(spacing: 40) {
                    Button(action: { previousSlide() }) {
                        Image(systemName: "backward.fill")
                            .font(.title2)
                    }
                    .disabled(currentIndex == 0)
                    
                    Button(action: { toggleSlideshow() }) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 44))
                    }
                    
                    Button(action: { nextSlide() }) {
                        Image(systemName: "forward.fill")
                            .font(.title2)
                    }
                    .disabled(currentIndex == memories.count - 1)
                }
                .foregroundStyle(Color(hex: "#fbf8ee"))
                .padding(.bottom, 40)
            }
        }
        .onDisappear {
            stopSlideshow()
        }
    }
    
    private func toggleSlideshow() {
        isPlaying.toggle()
        if isPlaying {
            startSlideshow()
        } else {
            stopSlideshow()
        }
    }
    
    private func startSlideshow() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            nextSlide()
        }
    }
    
    private func stopSlideshow() {
        timer?.invalidate()
        timer = nil
    }
    
    private func nextSlide() {
        withAnimation {
            if currentIndex < memories.count - 1 {
                currentIndex += 1
            } else {
                currentIndex = 0
            }
        }
    }
    
    private func previousSlide() {
        withAnimation {
            currentIndex = max(0, currentIndex - 1)
        }
    }
}
struct MemoryCard: View {
    let memory: PhotoMemory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let uiImage = UIImage(data: memory.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(memory.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                
                HStack(spacing: 12) {
                    Label(memory.date.formatted(date: .abbreviated, time: .omitted),
                          systemImage: "calendar")
                    if !memory.tags.isEmpty {
                        Label("\(memory.tags.count) tags", systemImage: "tag.fill")
                    }
                }
                .font(.footnote)
                .foregroundStyle(Color(hex: "#fbf8ee").opacity(0.7))
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
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

struct AddPhotoMemoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var memories: [PhotoMemory]
    
    @State private var title = ""
    @State private var description = ""
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var tags: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#0d1824")
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        if let selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                .overlay(alignment: .topTrailing) {
                                    Button {
                                        showingImagePicker = true
                                    } label: {
                                        Image(systemName: "pencil.circle.fill")
                                            .font(.title)
                                            .foregroundStyle(Color(hex: "#fbf8ee"))
                                            .shadow(radius: 2)
                                    }
                                    .padding(8)
                                }
                        } else {
                            Button {
                                showingImagePicker = true
                            } label: {
                                VStack(spacing: 12) {
                                    Image(systemName: "photo.fill")
                                        .font(.largeTitle)
                                    Text("Select Photo")
                                        .font(.headline)
                                }
                                .foregroundStyle(Color(hex: "#fbf8ee"))
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(Color(hex: "#fbf8ee").opacity(0.2))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 24)
                                                .strokeBorder(Color(hex: "#fbf8ee"), style: StrokeStyle(lineWidth: 2, dash: [8]))
                                        )
                                )
                            }
                        }
                        
                        RoundedInputField(title: "Title", text: $title, icon: "pencil.line")
                        RoundedInputField(title: "Description", text: $description, icon: "text.justify")
                        RoundedInputField(title: "Tags (comma separated)", text: $tags, icon: "tag")
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Button(action: saveMemory) {
                        Text("Save Memory")
                            .font(.custom("BebasNeue", size: 20))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                selectedImage != nil ?
                                Color(hex:"#fbf8ee").opacity(0.3) :
                                Color.gray.opacity(0.3)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 28))
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(Color(hex:"#fbf8ee"), lineWidth: 2)
                            )
                    }
                    .disabled(selectedImage == nil)
                    .padding(.horizontal)
                }
                .padding(.top, 20)
            }
            .navigationTitle("New Photo Memory")
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
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
        }
    }
    
    private func saveMemory() {
        guard let imageData = selectedImage?.jpegData(compressionQuality: 0.8) else { return }
        
        if memories.count >= 1 {
            // Show Superwall paywall
            Superwall.shared.register(event:"paid")
        }
        
        let memory = PhotoMemory(title: title, imageData: imageData)
        memory.tags = tags.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
        modelContext.insert(memory)
        dismiss()
    }
}
struct PhotoMemoryDetailView: View {
    @Bindable var memory: PhotoMemory
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let uiImage = UIImage(data: memory.imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(alignment: .bottomTrailing) {
                            Button {
                                showingImagePicker = true
                            } label: {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.title)
                                    .foregroundStyle(.white)
                                    .shadow(radius: 2)
                            }
                            .padding(12)
                        }
                }
                
                VStack(spacing: 16) {
                    RoundedInputField(title: "Title", text: $memory.title, icon: "pencil.line")
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date: \(memory.date.formatted())")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(uiColor: .secondarySystemBackground))
                    )
                    
                    if !memory.tags.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tags")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(memory.tags, id: \.self) { tag in
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
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Edit Photo Memory")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(uiColor: .systemBackground))
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .onChange(of: selectedImage) {
            if let image = selectedImage,
               let imageData = image.jpegData(compressionQuality: 0.8) {
                memory.imageData = imageData
            }
        }
    }
}
#Preview{
    PhotoMemoryView()
        .preferredColorScheme(.dark)
        .modelContainer(for: PhotoMemory.self)
}
