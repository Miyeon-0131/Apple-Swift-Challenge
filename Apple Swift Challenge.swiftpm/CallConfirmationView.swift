import SwiftUI
import UIKit

struct CallConfirmationView: View {
    var model: AppModel

    var body: some View {
        if let contact = model.selectedContact {
            VStack(spacing: 32) {
                Spacer()

                ZStack {
                    if let data = contact.avatarImageData,
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 140, height: 140)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color.white, lineWidth: 4)
                            )
                    } else if let emoji = contact.defaultEmoji {
                        Circle()
                            .fill(contact.iconColor.opacity(0.3))
                            .frame(width: 160, height: 160)
                            .overlay {
                                Text(emoji)
                                    .font(.system(size: 70))
                            }
                    } else {
                        Image(systemName: contact.iconName)
                            .font(.system(size: 70))
                            .foregroundStyle(.white)
                            .frame(width: 140, height: 140)
                            .background(contact.iconColor.gradient)
                            .clipShape(Circle())
                    }
                }
                .accessibilityLabel(model.strings.contactDisplayName(for: contact))

                Text(model.strings.contactDisplayName(for: contact))
                    .font(.system(size: 44, weight: .bold))

                if let subtitle = model.strings.contactSubtitle(for: contact) {
                    Text(subtitle)
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }

                Text(contact.phoneNumber)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.secondary)

                Spacer()

                Button(action: {
                    withAnimation { model.startCall() }
                }) {
                    Text(model.strings.callButton)
                        .font(.title).bold()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(.green)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .accessibilityLabel(model.strings.callButton)
                .accessibilityHint(model.strings.confirmCallTitle)

                Button(action: {
                    withAnimation { model.showHome() }
                }) {
                    Text(model.strings.cancelButton)
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(.secondarySystemBackground))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .accessibilityLabel(model.strings.cancelButton)

                if contact.category != .systemEmergency {
                    Button(action: {
                        withAnimation { model.startEditing(contact: contact) }
                    }) {
                        Text(model.strings.editButton)
                            .font(.title3)
                            .foregroundStyle(.blue)
                    }
                    .padding(.top, 8)
                }
            }
            .padding(32)
        }
    }
}
