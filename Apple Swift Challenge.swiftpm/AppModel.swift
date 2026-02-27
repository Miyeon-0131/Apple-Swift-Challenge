import Foundation
import Observation
import SwiftUI

enum ContactCategory: String, Codable, CaseIterable {
    case systemEmergency
    case family
    case other
}


enum FamilyRelationship: String, Codable, CaseIterable, Identifiable {
    case daughter
    case son
    case spouse
    case grandson
    case granddaughter
    case grandchild
    case nephew
    case niece
    case other

    var id: String { rawValue }
}

enum OtherContactType: String, Codable, CaseIterable, Identifiable {
    case doctor
    case caregiver
    case neighbor
    case propertyManager
    case cableTv
    case waterCompany
    case powerCompany
    case gasCompany
    case communityRestaurant
    case seniorUniversity
    case friend
    case other

    var id: String { rawValue }
}

enum EmergencyService: String, Codable, CaseIterable, Identifiable {
    case medical
    case police
    case fire

    var id: String { rawValue }
}

struct Contact: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var name: String
    var phoneNumber: String
    var category: ContactCategory
    var relationship: FamilyRelationship?
    var otherType: OtherContactType?
    var emergencyService: EmergencyService?
    var avatarImageData: Data?

    // English-only display helpers used across views
    var displayName: String {
        if let service = emergencyService {
            switch service {
            case .medical: return "Emergency"
            case .police: return "Police"
            case .fire: return "Fire"
            }
        }
        return name
    }

    var isDefaultContact: Bool {
        return phoneNumber == "1234567890"
    }

    var subtitle: String? {
        // Hide subtitle for ALL default demo contacts
        if isDefaultContact {
            return nil
        }
        
        switch category {
        case .systemEmergency:
            return phoneNumber
        case .family:
            if let r = relationship {
                switch r {
                case .daughter: return "Daughter"
                case .son: return "Son"
                case .spouse: return "Spouse"
                case .grandson: return "Grandson"
                case .granddaughter: return "Granddaughter"
                case .grandchild: return "Grandchild"
                case .nephew: return "Nephew"
                case .niece: return "Niece"
                case .other: return "Family"
                }
            }
            return nil
        case .other:
            if let t = otherType {
                switch t {
                case .doctor: return "Family Doctor"
                case .caregiver: return "Caregiver"
                case .neighbor: return "Neighbor"
                case .propertyManager: return "Property Repair"
                case .cableTv: return "Cable TV"
                case .waterCompany: return "Water Company"
                case .powerCompany: return "Power Company"
                case .gasCompany: return "Gas Company"
                case .communityRestaurant: return "Community Restaurant"
                case .seniorUniversity: return "Senior University"
                case .friend: return "Friend"
                case .other: return "Contact"
                }
            }
            return nil
        }
    }

    var defaultEmoji: String? {
        switch category {
        case .family:
            switch relationship {
            case .some(.daughter): return "👩🏻\u{200D}🦰"
            case .some(.son): return "👨"
            case .some(.spouse): return "❤️"
            case .some(.grandson): return "👦🏼"
            case .some(.granddaughter): return "🧒🏼"
            case .some(.grandchild): return "🧒"
            case .some(.nephew): return "👦"
            case .some(.niece): return "👧"
            case .some(.other), .none: return "🧑"
            }
        case .other:
            switch otherType {
            case .cableTv: return "📺"
            case .propertyManager: return "🛠️"
            case .doctor: return "🩺"
            case .waterCompany: return "🚰"
            case .powerCompany: return "💡"
            case .communityRestaurant: return "🍱"
            case .gasCompany: return "🔥"
            case .friend: return "👭"
            case .seniorUniversity: return "🎼"
            case .caregiver: return "🤝"
            case .neighbor: return "🏠"
            case .other, nil: return nil
            }
        case .systemEmergency:
            return nil
        }
    }

    var iconName: String {
        switch category {
        case .systemEmergency:
            switch emergencyService {
            case .medical: return "cross.case.fill"
            case .police: return "shield.lefthalf.filled"
            case .fire: return "flame.fill"
            case nil: return "phone.fill"
            }
        case .family: return "person.fill"
        case .other:
            switch otherType {
            case .doctor: return "stethoscope"
            case .caregiver: return "heart.circle.fill"
            case .neighbor: return "house.fill"
            case .propertyManager: return "wrench.and.screwdriver.fill"
            case .cableTv: return "tv.fill"
            case .waterCompany: return "drop.fill"
            case .powerCompany: return "bolt.fill"
            case .gasCompany: return "flame.fill"
            case .communityRestaurant: return "fork.knife"
            case .seniorUniversity: return "music.note"
            case .friend: return "person.2.fill"
            case .other, nil: return "person.crop.circle"
            }
        }
    }

    var iconColor: Color {
        switch category {
        case .systemEmergency:
            switch emergencyService {
            case .medical: return .red
            case .police: return .blue
            case .fire: return .orange
            case nil: return .red
            }
        case .family: return .orange
        case .other: return .blue
        }
    }
}

enum CallPhase: Equatable {
    case connecting
    case active
}

enum AppMode: Equatable {
    case use
    case setup
}

struct CallState: Equatable {
    var contact: Contact
    var startDate: Date
    var phase: CallPhase = .connecting
}

enum AppScreen: Equatable {
    case hero
    case home
    case confirm
    case newFamily
    case newOther
    case editContact(Contact)
    case inCall
}

struct LocalizedStrings {

    var appTitle: String { "Emergency Contacts" }

    var subtitle: String { "Tap a contact, then press Call." }

    var systemEmergencyTitle: String { "System Emergency" }

    var familyTitle: String { "Family" }

    var othersTitle: String { "Others" }

    var addFamilyButton: String { "Add Family Contact" }

    var addOtherButton: String { "Add Other Contact" }

    var noFamilyPlaceholder: String { "No family contacts yet." }

    var noOtherPlaceholder: String { "No other contacts yet." }

    var confirmCallTitle: String { "Confirm Call" }

    var callButton: String { "Call" }

    var cancelButton: String { "Cancel" }

    var hangUpButton: String { "Hang Up" }

    var callDurationLabel: String { "Call Duration" }


    func displayName(for relationship: FamilyRelationship) -> String {
        switch relationship {
        case .daughter: return "Daughter"
        case .son: return "Son"
        case .spouse: return "Spouse"
        case .grandson: return "Grandson"
        case .granddaughter: return "Granddaughter"
        case .grandchild: return "Grandchild"
        case .nephew: return "Nephew"
        case .niece: return "Niece"
        case .other: return "Family"
        }
    }

    func emoji(for relationship: FamilyRelationship) -> String {
        switch relationship {
        case .daughter: return "👩🏻‍🦰"
        case .son: return "👨"
        case .spouse: return "❤️"
        case .grandson: return "👦🏼"
        case .granddaughter: return "🧒🏼"
        case .grandchild: return "🧒"
        case .nephew: return "👦"
        case .niece: return "👧"
        case .other: return "🧑"
        }
    }

    func displayName(for type: OtherContactType) -> String {
        switch type {
        case .doctor: return "Family Doctor"
        case .caregiver: return "Caregiver"
        case .neighbor: return "Neighbor"
        case .propertyManager: return "Property Repair"
        case .cableTv: return "Cable TV"
        case .waterCompany: return "Water Company"
        case .powerCompany: return "Power Company"
        case .gasCompany: return "Gas Company"
        case .communityRestaurant: return "Community Restaurant"
        case .seniorUniversity: return "Senior University"
        case .friend: return "Friend"
        case .other: return "Contact"
        }
    }

    func emoji(for type: OtherContactType) -> String {
        switch type {
        case .cableTv: return "📺"
        case .propertyManager: return "🛠️"
        case .doctor: return "🩺"
        case .waterCompany: return "🚰"
        case .powerCompany: return "💡"
        case .communityRestaurant: return "🍱"
        case .gasCompany: return "🔥"
        case .friend: return "👭"
        case .seniorUniversity: return "🎼"
        case .caregiver: return "🤝"
        case .neighbor: return "🏠"
        case .other: return "📋"
        }
    }

    var connectingLabel: String { "Connecting…" }

    var nameField: String { "Name" }

    var phoneField: String { "Phone Number" }

    var relationshipField: String { "Relationship" }

    var typeField: String { "Type" }

    var saveButton: String { "Save" }

    var deleteButton: String { "Delete This Contact" }

    var editButton: String { "Edit" }

    var addFamilyTitle: String { "Add Family Contact" }

    var addOtherTitle: String { "Add Other Contact" }

    var editContactTitle: String { "Edit Contact" }

    var choosePhotoButton: String { "Add Photo" }

    var swipeHint: String { "Swipe left to delete, right to edit" }

    var invalidPhoneMessage: String { "Phone number can only contain digits" }

    var invalidPhoneLengthMessage: String { "Phone number has invalid length" }

    func displayName(for service: EmergencyService) -> String {
        switch service {
        case .medical: return "Emergency"
        case .police: return "Police"
        case .fire: return "Fire"
        }
    }

    func contactDisplayName(for contact: Contact) -> String {
        if let service = contact.emergencyService {
            return displayName(for: service)
        }
        return contact.name
    }

    func contactSubtitle(for contact: Contact) -> String? {
        switch contact.category {
        case .systemEmergency: return contact.phoneNumber
        case .family:
            if let r = contact.relationship { return displayName(for: r) }
            return nil
        case .other:
            if let t = contact.otherType { return displayName(for: t) }
            return nil
        }
    }
}

@MainActor
@Observable
class AppModel {
    private let storageKey = "userContacts"
    private let swipeHintSeenKey = "hasSeenSwipeHint"
    private let dataVersionKey = "contactsDataVersion"
    private let currentDataVersion = 2

    var userContacts: [Contact] = []
    var currentScreen: AppScreen = .hero
    var currentMode: AppMode = .use
    var selectedContact: Contact?
    var currentCall: CallState?
    var hasSeenSwipeHint: Bool = false

    init() {
        loadContacts()
        hasSeenSwipeHint = UserDefaults.standard.bool(forKey: swipeHintSeenKey)
    }

    var strings: LocalizedStrings {
        LocalizedStrings()
    }

    var systemEmergencyContacts: [Contact] {
        let contact = Contact(
            id: UUID(),
            name: "911 Emergency",
            phoneNumber: "911",
            category: .systemEmergency,
            relationship: nil,
            otherType: nil,
            emergencyService: .medical,
            avatarImageData: nil
        )
        return [contact]
    }

    var familyContacts: [Contact] {
        userContacts.filter { $0.category == .family }
    }

    var otherContacts: [Contact] {
        userContacts.filter { $0.category == .other }
    }

    var phonePrefix: String {
        return "+1"
    }

    var expectedPhoneDigits: Int {
        return 10
    }


    func showHome() {
        currentScreen = .home
        selectedContact = nil
    }

    func startExperience() {
        currentScreen = .home
    }

    func showConfirmation(for contact: Contact) {
        selectedContact = contact
        currentScreen = .confirm
    }

    func startNewFamilyContact() {
        currentScreen = .newFamily
    }

    func startNewOtherContact() {
        currentScreen = .newOther
    }

    func startEditing(contact: Contact) {
        currentScreen = .editContact(contact)
        selectedContact = contact
    }

    func startCall() {
        guard let contact = selectedContact else { return }
        currentCall = CallState(contact: contact, startDate: Date())
        currentScreen = .inCall
    }

    func endCall() {
        currentCall = nil
        selectedContact = nil
        currentScreen = .home
    }

    func addContact(_ contact: Contact) {
        userContacts.append(contact)
        saveContacts()
    }

    func switchToSetupMode() {
        currentMode = .setup
    }

    func switchToUseMode() {
        currentMode = .use
    }

    func updateContact(_ contact: Contact) {
        if let index = userContacts.firstIndex(where: { $0.id == contact.id }) {
            userContacts[index] = contact
            saveContacts()
        }
    }

    func deleteContact(_ contact: Contact) {
        userContacts.removeAll { $0.id == contact.id }
        saveContacts()
    }

    func markSwipeHintSeen() {
        guard !hasSeenSwipeHint else { return }
        hasSeenSwipeHint = true
        UserDefaults.standard.set(true, forKey: swipeHintSeenKey)
    }


    func moveFamilyContacts(from source: IndexSet, to destination: Int) {
        let current = familyContacts
        var reordered = current
        reordered.move(fromOffsets: source, toOffset: destination)
        applyReorderedContacts(reordered, for: .family)
    }

    func moveOtherContacts(from source: IndexSet, to destination: Int) {
        let current = otherContacts
        var reordered = current
        reordered.move(fromOffsets: source, toOffset: destination)
        applyReorderedContacts(reordered, for: .other)
    }

    private func applyReorderedContacts(_ reordered: [Contact], for category: ContactCategory) {
        var newUser = userContacts
        let indices = newUser.indices.filter { newUser[$0].category == category }
        guard indices.count == reordered.count else { return }
        for (newPosition, contact) in reordered.enumerated() {
            let idx = indices[newPosition]
            newUser[idx] = contact
        }
        userContacts = newUser
        saveContacts()
    }


    private func loadContacts() {
        let savedVersion = UserDefaults.standard.integer(forKey: dataVersionKey)
        // Reset to defaults when data version is outdated
        if savedVersion < currentDataVersion {
            userContacts = defaultDemoContacts()
            saveContacts()
            UserDefaults.standard.set(currentDataVersion, forKey: dataVersionKey)
            return
        }
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            userContacts = defaultDemoContacts()
            saveContacts()
            return
        }
        do {
            let decoded = try JSONDecoder().decode([Contact].self, from: data)
            let bannedNumbers: Set<String> = ["12333", "12345"]
            userContacts = decoded.filter { !bannedNumbers.contains($0.phoneNumber) }
        } catch {
            userContacts = defaultDemoContacts()
            saveContacts()
        }
    }

    private func defaultDemoContacts() -> [Contact] {
        let phone = "1234567890"
        return [
            // Family
            Contact(id: UUID(), name: "Daughter",   phoneNumber: phone, category: .family, relationship: .daughter,    otherType: nil, emergencyService: nil, avatarImageData: nil),
            Contact(id: UUID(), name: "Son",         phoneNumber: phone, category: .family, relationship: .son,         otherType: nil, emergencyService: nil, avatarImageData: nil),
            Contact(id: UUID(), name: "Granddaughter", phoneNumber: phone, category: .family, relationship: .granddaughter, otherType: nil, emergencyService: nil, avatarImageData: nil),
            Contact(id: UUID(), name: "Grandson",    phoneNumber: phone, category: .family, relationship: .grandson,   otherType: nil, emergencyService: nil, avatarImageData: nil),
            // Others
            Contact(id: UUID(), name: "Cable TV",            phoneNumber: phone, category: .other, relationship: nil, otherType: .cableTv,             emergencyService: nil, avatarImageData: nil),
            Contact(id: UUID(), name: "Property Repair",     phoneNumber: phone, category: .other, relationship: nil, otherType: .propertyManager,     emergencyService: nil, avatarImageData: nil),
            Contact(id: UUID(), name: "Family Doctor",       phoneNumber: phone, category: .other, relationship: nil, otherType: .doctor,               emergencyService: nil, avatarImageData: nil),
            Contact(id: UUID(), name: "Water Company",       phoneNumber: phone, category: .other, relationship: nil, otherType: .waterCompany,         emergencyService: nil, avatarImageData: nil),
            Contact(id: UUID(), name: "Power Company",       phoneNumber: phone, category: .other, relationship: nil, otherType: .powerCompany,         emergencyService: nil, avatarImageData: nil),
            Contact(id: UUID(), name: "Community Restaurant",phoneNumber: phone, category: .other, relationship: nil, otherType: .communityRestaurant,  emergencyService: nil, avatarImageData: nil),
            Contact(id: UUID(), name: "Gas Company",         phoneNumber: phone, category: .other, relationship: nil, otherType: .gasCompany,           emergencyService: nil, avatarImageData: nil),
            Contact(id: UUID(), name: "Friend",              phoneNumber: phone, category: .other, relationship: nil, otherType: .friend,               emergencyService: nil, avatarImageData: nil),
            Contact(id: UUID(), name: "Senior University",   phoneNumber: phone, category: .other, relationship: nil, otherType: .seniorUniversity,     emergencyService: nil, avatarImageData: nil),
        ]
    }

    private func saveContacts() {
        do {
            let data = try JSONEncoder().encode(userContacts)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
        }
    }
}
