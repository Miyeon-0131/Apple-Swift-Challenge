import SwiftUI
import PhotosUI

struct AvatarView: View {
    @Binding var avatarImageData: Data?
    @State private var selectedItem: PhotosPickerItem?
    @State private var avatarImage: UIImage?
    
    var body: some View {
        VStack(spacing: 8) {
            // 头像显示
            if let image = avatarImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.white, lineWidth: 3)
                    )
            } else {
                Circle()
                    .fill(Color(.tertiarySystemBackground))
                    .frame(width: 120, height: 120)
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    }
            }
            
            // 相册选择按钮
            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Text("Add Photo")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(.blue)
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        avatarImage = image
                        avatarImageData = data
                        SpeechAssistant.shared.speak("Photo selected")
                    }
                }
            }
            .onAppear {
                // Load existing image if data is already set
                if let data = avatarImageData,
                   let image = UIImage(data: data) {
                    avatarImage = image
                }
            }
        }
        .frame(maxWidth: .infinity)
        .onTapGesture { SpeechAssistant.shared.speak("Add Photo") }
    }
}
