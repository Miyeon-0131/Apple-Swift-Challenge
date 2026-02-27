import SwiftUI
import UIKit

fileprivate func announce(_ text: String) {
    SpeechAssistant.shared.speak(text)
}

struct HomeView: View {
    var model: AppModel
    @State private var longPressProgress: CGFloat = 0
    @State private var isLongPressing = false
    
    var body: some View {
        ZStack {
            List {
                Section {
                    headerView
                        .listRowInsets(EdgeInsets(top: 16, leading: 20, bottom: 8, trailing: 16))
                }
                
                // Swipe hint only shown in setup mode
                if !model.hasSeenSwipeHint && model.currentMode == .setup {
                    Section {
                        swipeHintView
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 8, trailing: 20))
                    }
                }
                
                Section(header: sectionHeader("Emergency", color: Color(red: 0.9, green: 0.25, blue: 0.25))) {
                    emergencySection
                }
                
                Section(header: sectionHeader("Family", color: Color(red: 0.95, green: 0.55, blue: 0.2))) {
                    familySection
                }
                
                Section(header: sectionHeader("Others", color: Color(red: 0.3, green: 0.55, blue: 0.85))) {
                    othersSection
                }
            }
            .listStyle(.insetGrouped)
            
            // Mode indicator and switcher (bottom-left corner)
            VStack {
                Spacer()
                HStack {
                    modeIndicator
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.bottom, 60)
            }
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Emergency Contacts")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.8)
                .lineLimit(1)
                .accessibilityAddTraits(.isHeader)
            
            Text(model.currentMode == .use 
                 ? "Tap a contact to call" 
                 : "Setup Mode - Edit contacts")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(model.currentMode == .use ? .secondary : Color.orange)
        }
    }
    
    private var swipeHintView: some View {
        HStack(spacing: 10) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(Color.orange)
                .accessibilityHidden(true)
            
            Text("Swipe left to delete, right to edit")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.orange.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Tap to dismiss this hint")
        .onTapGesture {
            withAnimation {
                model.markSwipeHintSeen()
            }
            SpeechAssistant.shared.speak("Hint dismissed")
        }
    }
    
    private func sectionHeader(_ title: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Spacer()
        }
        .accessibilityAddTraits(.isHeader)
    }
    
    private var emergencySection: some View {
        ForEach(model.systemEmergencyContacts) { contact in
            ContactRow(contact: contact, model: model)
        }
    }
    
    @ViewBuilder
    private var familySection: some View {
        if model.familyContacts.isEmpty {
            Text("No family contacts yet.")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.vertical, 12)
        } else {
            ForEach(model.familyContacts) { contact in
                ContactRow(contact: contact, model: model)
            }
        }
        
        // Add button only in setup mode
        if model.currentMode == .setup {
            Button(action: { 
                SpeechAssistant.shared.speak("Add Family Contact")
                withAnimation { model.startNewFamilyContact() } 
            }) {
                Label("Add Family Contact", systemImage: "plus.circle.fill")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .foregroundStyle(Color(red: 0.95, green: 0.55, blue: 0.2))
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.orange.opacity(0.2))
            .accessibilityLabel("Add Family Contact")
            .accessibilityHint("Opens form to add a new family member contact")
        }
    }
    
    @ViewBuilder
    private var othersSection: some View {
        if model.otherContacts.isEmpty {
            Text("No other contacts yet.")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.vertical, 12)
        } else {
            ForEach(model.otherContacts) { contact in
                ContactRow(contact: contact, model: model)
            }
        }
        
        // Add button only in setup mode
        if model.currentMode == .setup {
            Button(action: { 
                SpeechAssistant.shared.speak("Add Other Contact")
                withAnimation { model.startNewOtherContact() } 
            }) {
                Label("Add Other Contact", systemImage: "plus.circle.fill")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .foregroundStyle(Color(red: 0.3, green: 0.55, blue: 0.85))
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue.opacity(0.2))
            .accessibilityLabel("Add Other Contact")
            .accessibilityHint("Opens form to add a new contact like doctor or caregiver")
        }
    }
    
    private var modeIndicator: some View {
        VStack(spacing: 6) {
            ZStack {
                // Progress ring during long press
                if isLongPressing {
                    Circle()
                        .trim(from: 0, to: longPressProgress)
                        .stroke(Color.orange, lineWidth: 3)
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                }
                
                // Mode button
                Button(action: {}) {
                    Image(systemName: model.currentMode == .use ? "lock.fill" : "lock.open.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(model.currentMode == .use ? .secondary : Color.orange)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                        )
                }
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 3.0)
                        .onChanged { _ in
                            isLongPressing = true
                            withAnimation(.linear(duration: 3.0)) {
                                longPressProgress = 1.0
                            }
                        }
                        .onEnded { _ in
                            toggleMode()
                            resetLongPress()
                        }
                )
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { _ in
                            if !isLongPressing {
                                // Short tap - show hint
                                showModeHint()
                            } else {
                                resetLongPress()
                            }
                        }
                )
                .accessibilityLabel(model.currentMode == .use 
                    ? "Use Mode - Long press for 3 seconds to enter Setup Mode" 
                    : "Setup Mode - Long press for 3 seconds to return to Use Mode")
                .accessibilityHint("Long press and hold for 3 seconds to switch modes")
            }
            Text(model.currentMode == .use ? "Hold 3s to edit" : "Hold 3s to lock")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }
    
    private func toggleMode() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            if model.currentMode == .use {
                model.switchToSetupMode()
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                announce("Setup mode")
            } else {
                model.switchToUseMode()
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                announce("Use mode")
            }
        }
    }

    private func resetLongPress() {
        withAnimation {
            isLongPressing = false
            longPressProgress = 0
        }
    }
    
    private func showModeHint() {
        // Could show a tooltip or alert here
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        SpeechAssistant.shared.speak("Long press for 3 seconds to switch modes")
    }
}

// MARK: - Contact Row

struct ContactRow: View {
    let contact: Contact
    var model: AppModel
    
    var body: some View {
        Button(action: { 
            withAnimation { 
                model.showConfirmation(for: contact) 
            }
            announce("Selected \(contact.displayName)")
        }) {
            HStack(spacing: 12) {
                // Avatar
                ZStack {
                    if let data = contact.avatarImageData,
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 48, height: 48)
                            .clipShape(Circle())
                    } else if let emoji = contact.defaultEmoji {
                        Circle()
                            .fill(contact.iconColor.opacity(0.12))
                            .frame(width: 48, height: 48)
                            .overlay {
                                Text(emoji)
                                    .font(.system(size: 26))
                            }
                    } else {
                        Image(systemName: contact.iconName)
                            .font(.system(size: 22))
                            .foregroundStyle(.white)
                            .frame(width: 48, height: 48)
                            .background(contact.iconColor.gradient)
                            .clipShape(Circle())
                    }
                }
                .accessibilityHidden(true)
                
                // Contact info
                VStack(alignment: .leading, spacing: 2) {
                    Text(contact.displayName)
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .minimumScaleFactor(0.75)
                        .lineLimit(1)
                        .foregroundColor(.black)
                    
                    if contact.category == .systemEmergency {
                        Text(contact.phoneNumber)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .minimumScaleFactor(0.75)
                            .lineLimit(1)
                            .foregroundStyle(contact.iconColor)
                    } else if let sub = contact.subtitle {
                        Text(sub)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .minimumScaleFactor(0.75)
                            .lineLimit(1)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(.tertiaryLabel))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(contact.category == .systemEmergency
                          ? contact.iconColor.opacity(0.06)
                          : Color(.secondarySystemBackground))
            )
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(contact.displayName), \(contact.subtitle ?? ""), \(contact.phoneNumber)")
        .accessibilityHint("Tap to confirm and call this contact")
        .accessibilityAddTraits(.isButton)
        // Swipe actions only in setup mode
        .swipeActions(edge: .trailing) {
            if contact.category != .systemEmergency && model.currentMode == .setup {
                Button(role: .destructive) {
                    withAnimation {
                        model.deleteContact(contact)
                    }
                    announce("Deleted \(contact.displayName)")
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .accessibilityLabel("Delete \(contact.displayName)")
            }
        }
        .swipeActions(edge: .leading) {
            if contact.category != .systemEmergency && model.currentMode == .setup {
                Button {
                    withAnimation { model.startEditing(contact: contact) }
                    announce("Editing \(contact.displayName)")
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                .tint(.blue)
                .accessibilityLabel("Edit \(contact.displayName)")
            }
        }
    }

}
