import SwiftUI
import UIKit

struct HomeView: View {
    var model: AppModel

    var body: some View {
        List {
            Section {
                headerView
                    .listRowInsets(EdgeInsets(top: 16, leading: 20, bottom: 8, trailing: 16))
            }

            if !model.hasSeenSwipeHint {
                Section {
                    swipeHintView
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 8, trailing: 20))
                }
            }

            Section(header: sectionHeader(model.strings.systemEmergencyTitle, color: .red)) {
                emergencySection
            }

            Section(header: sectionHeader(model.strings.familyTitle, color: .orange)) {
                familySection
            }

            Section(header: sectionHeader(model.strings.othersTitle, color: .blue)) {
                othersSection
            }
        }
        .listStyle(.insetGrouped)
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(model.strings.appTitle)
                .font(.system(size: 56, weight: .bold, design: .default))
            Text(model.strings.subtitle)
                .font(.system(size: 38, weight: .regular, design: .default))
                .foregroundStyle(.secondary)
        }
    }

    private var swipeHintView: some View {
        HStack(spacing: 12) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 36, weight: .regular, design: .default))
                .foregroundStyle(.orange)
                .accessibilityHidden(true)
            
            Text(model.strings.swipeHint)
                .font(.system(size: 34, weight: .semibold, design: .default))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.orange.opacity(0.4), lineWidth: 2)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .onTapGesture {
            withAnimation {
                model.markSwipeHintSeen()
            }
        }
    }

    private func sectionHeader(_ title: String, color: Color) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 40, weight: .bold, design: .default))
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
            Text(model.strings.noFamilyPlaceholder)
                .font(.system(size: 30, weight: .regular, design: .default))
                .foregroundStyle(.secondary)
                .padding(.vertical, 16)
        } else {
            ForEach(model.familyContacts) { contact in
                ContactRow(contact: contact, model: model)
            }
        }

        Button(action: { withAnimation { model.startNewFamilyContact() } }) {
            Label(model.strings.addFamilyButton, systemImage: "plus.circle.fill")
                .font(.title2).bold()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundStyle(.orange)
        }
        .buttonStyle(.borderedProminent)
        .tint(.orange.opacity(0.2))
        .accessibilityLabel(model.strings.addFamilyButton)
    }

    @ViewBuilder
    private var othersSection: some View {
        if model.otherContacts.isEmpty {
            Text(model.strings.noOtherPlaceholder)
                .font(.system(size: 30, weight: .regular, design: .default))
                .foregroundStyle(.secondary)
                .padding(.vertical, 16)
        } else {
            ForEach(model.otherContacts) { contact in
                ContactRow(contact: contact, model: model)
            }
        }

        Button(action: { withAnimation { model.startNewOtherContact() } }) {
            Label(model.strings.addOtherButton, systemImage: "plus.circle.fill")
                .font(.title2).bold()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundStyle(.blue)
        }
        .buttonStyle(.borderedProminent)
        .tint(.blue.opacity(0.2))
        .accessibilityLabel(model.strings.addOtherButton)
    }
}

// MARK: - Contact Row

struct ContactRow: View {
    let contact: Contact
    var model: AppModel

    var body: some View {
        Button(action: { withAnimation { model.showConfirmation(for: contact) } }) {
            HStack(spacing: 16) {
                ZStack {
                    if let data = contact.avatarImageData,
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                    } else if let emoji = contact.defaultEmoji {
                        Circle()
                            .fill(Color.orange.opacity(0.3))
                            .frame(width: 60, height: 60)
                            .overlay {
                                Text(emoji)
                                    .font(.largeTitle)
                            }
                    } else {
                        Image(systemName: contact.iconName)
                            .font(.title)
                            .foregroundStyle(.white)
                            .frame(width: 60, height: 60)
                            .background(contact.iconColor.gradient)
                            .clipShape(Circle())
                    }
                }
                .accessibilityLabel(model.strings.contactDisplayName(for: contact))

                VStack(alignment: .leading, spacing: 4) {
                    Text(model.strings.contactDisplayName(for: contact))
                        .font(.system(size: 38, weight: .bold, design: .default))
                        .foregroundStyle(.primary)
                    if contact.category == .systemEmergency {
                        Text(contact.phoneNumber)
                            .font(.system(size: 38, weight: .bold, design: .default))
                            .foregroundStyle(contact.iconColor)
                    } else if let sub = model.strings.contactSubtitle(for: contact) {
                        Text(sub)
                            .font(.system(size: 32, weight: .regular, design: .default))
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if contact.category != .systemEmergency {
                    Text(contact.phoneNumber)
                        .font(.system(size: 30, weight: .regular, design: .default))
                        .foregroundStyle(.secondary)
                }

                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(contact.category == .systemEmergency
                          ? contact.iconColor.opacity(0.1)
                          : Color(.secondarySystemBackground))
            )
        }
        .accessibilityElement(children: .combine)
        .accessibilityHint(model.strings.confirmCallTitle)
        .swipeActions(edge: .trailing) {
            if contact.category != .systemEmergency {
                Button(role: .destructive) {
                    withAnimation {
                        model.deleteContact(contact)
                    }
                } label: {
                    Label(model.strings.deleteButton, systemImage: "trash")
                }
            }
        }
        .swipeActions(edge: .leading) {
            if contact.category != .systemEmergency {
                Button {
                    withAnimation { model.startEditing(contact: contact) }
                } label: {
                    Label(model.strings.editButton, systemImage: "pencil")
                }
                .tint(.blue)
            }
        }
    }
}