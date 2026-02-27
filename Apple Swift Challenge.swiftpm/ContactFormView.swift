import SwiftUI
import PhotosUI
import UIKit

enum ContactFormMode: Equatable {
    case newFamily
    case newOther
    case edit(Contact)
}

@MainActor
struct ContactFormView: View {
    var model: AppModel
    let mode: ContactFormMode

    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var relationship: FamilyRelationship = .daughter
    @State private var otherType: OtherContactType = .doctor
    @State private var avatarImageData: Data?

    private var isFamily: Bool {
        switch mode {
        case .newFamily: return true
        case .newOther: return false
        case .edit(let c): return c.category == .family
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private var canSave: Bool {
        !name.isEmpty && !phoneNumber.isEmpty && isDigitsOnly && isLengthValid
    }

    private var isDigitsOnly: Bool {
        phoneNumber.allSatisfy { $0.isNumber }
    }

    private var isLengthValid: Bool {
        guard isDigitsOnly else { return false }
        return phoneNumber.count == model.expectedPhoneDigits
    }

    private var phoneErrorText: String? {
        guard !phoneNumber.isEmpty else { return nil }
        if !isDigitsOnly {
            return model.strings.invalidPhoneMessage
        }
        if !isLengthValid {
            return model.strings.invalidPhoneLengthMessage
        }
        return nil
    }

    private var title: String {
        switch mode {
        case .newFamily: return model.strings.addFamilyTitle
        case .newOther: return model.strings.addOtherTitle
        case .edit: return model.strings.editContactTitle
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text(title)
                    .font(.system(size: 56, weight: .bold, design: .default))
                    .frame(maxWidth: .infinity, alignment: .leading)

                AvatarView(avatarImageData: $avatarImageData)

                VStack(alignment: .leading, spacing: 8) {
                    Text(model.strings.nameField)
                        .font(.system(size: 42, weight: .bold, design: .default))
                    TextField(model.strings.nameField, text: $name)
                        .font(.system(size: 38, weight: .regular, design: .default))
                        .padding(16)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .onTapGesture { SpeechAssistant.shared.speak("Editing name") }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(model.strings.phoneField)
                        .font(.system(size: 42, weight: .bold, design: .default))
                    HStack(spacing: 8) {
                        Text(model.phonePrefix)
                            .font(.system(size: 38, weight: .bold, design: .default))
                            .padding(.leading, 12)
                        Divider()
                        TextField(model.strings.phoneField, text: $phoneNumber)
                            .font(.system(size: 38, weight: .regular, design: .default))
                            .keyboardType(.phonePad)
                            .onTapGesture { SpeechAssistant.shared.speak("Editing phone number") }
                    }
                    .padding(16)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                if let error = phoneErrorText {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, -8)
                }

                if isFamily {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(model.strings.relationshipField)
                            .font(.system(size: 42, weight: .bold, design: .default))
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 180))], spacing: 12) {
                            ForEach(FamilyRelationship.allCases.filter { $0 != .grandchild && $0 != .other }) { r in
                                Button(action: { 
                                    SpeechAssistant.shared.speak(model.strings.displayName(for: r))
                                    relationship = r 
                                }) {
                                    VStack(spacing: 4) {
                                        Text(model.strings.emoji(for: r))
                                            .font(.system(size: 30))
                                        Text(model.strings.displayName(for: r))
                                            .font(.callout.weight(.bold))
                                            .lineLimit(1)
                                            .allowsTightening(true)
                                            .minimumScaleFactor(0.7)
                                    }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 12)
                                        .frame(maxWidth: .infinity)
                                        .background(relationship == r ? Color.orange : Color(.tertiarySystemBackground))
                                        .foregroundStyle(relationship == r ? .white : .primary)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .accessibilityLabel(model.strings.displayName(for: r))
                            }
                        }
                    }
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(model.strings.typeField)
                            .font(.system(size: 42, weight: .bold, design: .default))
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 180))], spacing: 12) {
                            ForEach(OtherContactType.allCases.filter { $0 != .other }) { t in
                                Button(action: { 
                                    SpeechAssistant.shared.speak(model.strings.displayName(for: t))
                                    otherType = t 
                                }) {
                                    VStack(spacing: 4) {
                                        Text(model.strings.emoji(for: t))
                                            .font(.system(size: 28))
                                        Text(model.strings.displayName(for: t))
                                            .font(.callout.weight(.bold))
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.7)
                                    }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 10)
                                        .frame(maxWidth: .infinity)
                                        .background(otherType == t ? Color.blue : Color(.tertiarySystemBackground))
                                        .foregroundStyle(otherType == t ? .white : .primary)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .accessibilityLabel(model.strings.displayName(for: t))
                            }
                        }
                    }
                }

                Button(action: saveContact) {
                    Text(model.strings.saveButton)
                        .font(.system(size: 34, weight: .bold, design: .default))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(canSave ? .green : .gray)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(!canSave)
                .accessibilityLabel(model.strings.saveButton)

                Button(action: { 
                    SpeechAssistant.shared.speak("Cancelled, back to list")
                    withAnimation { model.showHome() } 
                }) {
                    Text(model.strings.cancelButton)
                        .font(.system(size: 28, weight: .regular, design: .default))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.secondarySystemBackground))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .accessibilityLabel(model.strings.cancelButton)
            }
            .padding(32)
        }
        .onAppear { 
            loadExistingData()
            switch mode {
            case .newFamily: SpeechAssistant.shared.speak("Add Family Contact form")
            case .newOther: SpeechAssistant.shared.speak("Add Other Contact form")
            case .edit: break
            }
        }
    }

    @MainActor
    private func loadExistingData() {
        if case .edit(let contact) = mode {
            name = contact.name
            phoneNumber = contact.phoneNumber
            relationship = contact.relationship ?? .daughter
            otherType = contact.otherType ?? .doctor
            avatarImageData = contact.avatarImageData
            SpeechAssistant.shared.speak("Editing contact \(contact.displayName)")
        }
    }

    @MainActor
    private func saveContact() {
        switch mode {
        case .newFamily:
            let contact = Contact(id: UUID(), name: name, phoneNumber: phoneNumber, category: .family, relationship: relationship, otherType: nil, emergencyService: nil, avatarImageData: avatarImageData)
            model.addContact(contact)
            SpeechAssistant.shared.speak("Saved contact \(name)")
        case .newOther:
            let contact = Contact(id: UUID(), name: name, phoneNumber: phoneNumber, category: .other, relationship: nil, otherType: otherType, emergencyService: nil, avatarImageData: avatarImageData)
            model.addContact(contact)
            SpeechAssistant.shared.speak("Saved contact \(name)")
        case .edit(var contact):
            contact.name = name
            contact.phoneNumber = phoneNumber
            if contact.category == .family {
                contact.relationship = relationship
            } else {
                contact.otherType = otherType
            }
            contact.avatarImageData = avatarImageData
            model.updateContact(contact)
            SpeechAssistant.shared.speak("Updated contact \(name)")
        }
        withAnimation { model.showHome() }
    }
}
