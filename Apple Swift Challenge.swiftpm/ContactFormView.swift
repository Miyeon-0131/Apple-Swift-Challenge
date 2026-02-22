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
    @State private var showDeleteConfirm = false
    @State private var avatarItem: PhotosPickerItem?
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
                    .font(.system(size: 48, weight: .bold, design: .default))
                    .frame(maxWidth: .infinity, alignment: .leading)

                PhotosPicker(selection: $avatarItem, matching: .images) {
                    VStack(spacing: 8) {
                        ZStack {
                            if let data = avatarImageData,
                               let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
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
                        }

                        Text(model.strings.choosePhotoButton)
                            .font(.system(size: 32, weight: .regular, design: .default))
                            .foregroundStyle(.blue)
                    }
                    .frame(maxWidth: .infinity)
                }
                .accessibilityLabel(model.strings.choosePhotoButton)
                .onChange(of: avatarItem, initial: false) { _, newItem in
                    guard let newItem else { return }
                    Task { @MainActor in
                        if let data = try? await newItem.loadTransferable(type: Data.self) {
                            avatarImageData = data
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(model.strings.nameField)
                        .font(.system(size: 36, weight: .bold, design: .default))
                    TextField(model.strings.nameField, text: $name)
                        .font(.system(size: 32, weight: .regular, design: .default))
                        .padding(16)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(model.strings.phoneField)
                        .font(.system(size: 36, weight: .bold, design: .default))
                    HStack(spacing: 8) {
                        Text(model.phonePrefix)
                            .font(.system(size: 32, weight: .bold, design: .default))
                            .padding(.leading, 12)
                        Divider()
                        TextField(model.strings.phoneField, text: $phoneNumber)
                            .font(.system(size: 32, weight: .regular, design: .default))
                            .keyboardType(.phonePad)
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
                            .font(.system(size: 36, weight: .bold, design: .default))
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                            ForEach(FamilyRelationship.allCases.filter { $0 != .grandchild && $0 != .other }) { r in
                                Button(action: { relationship = r }) {
                                    Text(model.strings.displayName(for: r))
                                        .font(.system(size: 30, weight: .bold, design: .default))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .frame(maxWidth: .infinity)
                                        .background(relationship == r ? .orange : Color(.tertiarySystemBackground))
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
                            .font(.system(size: 36, weight: .bold, design: .default))
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                            ForEach(OtherContactType.allCases.filter { $0 != .other }) { t in
                                Button(action: { otherType = t }) {
                                    Text(model.strings.displayName(for: t))
                                        .font(.system(size: 30, weight: .bold, design: .default))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .frame(maxWidth: .infinity)
                                        .background(otherType == t ? .blue : Color(.tertiarySystemBackground))
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
                        .font(.title).bold()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(canSave ? .green : .gray)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(!canSave)
                .accessibilityLabel(model.strings.saveButton)

                Button(action: { withAnimation { model.showHome() } }) {
                    Text(model.strings.cancelButton)
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.secondarySystemBackground))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .accessibilityLabel(model.strings.cancelButton)

                if isEditing {
                    Button(action: { showDeleteConfirm = true }) {
                        Text(model.strings.deleteButton)
                            .font(.title3)
                            .foregroundStyle(.red)
                    }
                    .padding(.top, 16)
                    .alert(model.strings.deleteButton, isPresented: $showDeleteConfirm) {
                        Button(model.strings.cancelButton, role: .cancel) { }
                        Button(model.strings.deleteButton, role: .destructive) { deleteContact() }
                    }
                }
            }
            .padding(32)
        }
        .onAppear { loadExistingData() }
    }

    private func loadExistingData() {
        if case .edit(let contact) = mode {
            name = contact.name
            phoneNumber = contact.phoneNumber
            relationship = contact.relationship ?? .daughter
            otherType = contact.otherType ?? .doctor
            avatarImageData = contact.avatarImageData
        }
    }

    private func saveContact() {
        switch mode {
        case .newFamily:
            let contact = Contact(id: UUID(), name: name, phoneNumber: phoneNumber, category: .family, relationship: relationship, otherType: nil, emergencyService: nil, avatarImageData: avatarImageData)
            model.addContact(contact)
        case .newOther:
            let contact = Contact(id: UUID(), name: name, phoneNumber: phoneNumber, category: .other, relationship: nil, otherType: otherType, emergencyService: nil, avatarImageData: avatarImageData)
            model.addContact(contact)
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
        }
        withAnimation { model.showHome() }
    }

    private func deleteContact() {
        if case .edit(let contact) = mode {
            model.deleteContact(contact)
        }
        withAnimation { model.showHome() }
    }
}
