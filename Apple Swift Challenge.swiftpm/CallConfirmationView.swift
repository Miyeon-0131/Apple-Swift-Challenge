import SwiftUI
import UIKit

struct CallConfirmationView: View {
    var model: AppModel
    
    var body: some View {
        if let contact = model.selectedContact {
            VStack(spacing: 32) {
                Spacer()
                
                // Contact avatar - large and clear
                ZStack {
                    if let data = contact.avatarImageData,
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 160, height: 160)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color.white, lineWidth: 4)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    } else if let emoji = contact.defaultEmoji {
                        Circle()
                            .fill(contact.iconColor.opacity(0.3))
                            .frame(width: 180, height: 180)
                            .overlay {
                                Text(emoji)
                                    .font(.system(size: 80))
                            }
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    } else {
                        Image(systemName: contact.iconName)
                            .font(.system(size: 80))
                            .foregroundStyle(.white)
                            .frame(width: 160, height: 160)
                            .background(contact.iconColor.gradient)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                }
                .accessibilityLabel("Contact photo for \(contact.displayName)")
                
                // Contact name - large and bold
                Text(contact.displayName)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
                    .lineLimit(2)
                    .allowsTightening(true)
                    .accessibilityAddTraits(.isHeader)
                
                // Relationship or type
                if let subtitle = contact.subtitle {
                    Text(subtitle)
                        .font(.system(size: 32, weight: .regular, design: .rounded))
                        .foregroundColor(.black)
                }
                
                // Phone number - clear and readable
                Text(contact.phoneNumber)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Phone number: \(formatPhoneNumberForVoiceOver(contact.phoneNumber))")
                
                Spacer()
                
                // Call button - large touch target (minimum 64pt height)
                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    SpeechAssistant.shared.speak("Calling \(contact.displayName)")
                    withAnimation { model.startCall() }
                }) {
                    HStack(spacing: 16) {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 32))
                        Text("Call")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 70)
                    .background(
                        LinearGradient(
                            colors: [.green, .green.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .green.opacity(0.3), radius: 15, x: 0, y: 8)
                }
                .accessibilityLabel("Call \(contact.displayName) at \(formatPhoneNumberForVoiceOver(contact.phoneNumber))")
                .accessibilityHint("Double tap to start calling this contact. This is a simulated call for demonstration purposes.")
                
                // Cancel button - clear secondary action (minimum 60pt height)
                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    SpeechAssistant.shared.speak("Cancelled, back to list")
                    withAnimation { model.showHome() }
                }) {
                    Text("Cancel")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color(.secondarySystemBackground))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .accessibilityLabel("Cancel")
                .accessibilityHint("Double tap to return to the contact list without calling")
                
                // Edit button only in setup mode
                if contact.category != .systemEmergency && model.currentMode == .setup {
                    Button(action: {
                        SpeechAssistant.shared.speak("Editing \(contact.displayName)")
                        withAnimation { model.startEditing(contact: contact) }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "pencil")
                                .font(.system(size: 20))
                            Text("Edit Contact")
                                .font(.system(size: 24, weight: .medium, design: .rounded))
                        }
                        .foregroundStyle(.blue)
                        .frame(height: 44)
                    }
                    .padding(.top, 8)
                    .accessibilityLabel("Edit \(contact.displayName)")
                    .accessibilityHint("Double tap to edit this contact's information")
                }
            }
            .padding(32)
        }
    }
    
    private func formatPhoneNumberForVoiceOver(_ number: String) -> String {
        // Format for VoiceOver to read digits clearly
        // e.g., "911" becomes "9 1 1"
        return number.map { String($0) }.joined(separator: " ")
    }
}
