import Foundation
import Observation
import SwiftUI
import CoreLocation

enum ContactCategory: String, Codable, CaseIterable {
    case systemEmergency
    case family
    case other
}

enum AppLanguage: String, Codable, CaseIterable {
    case chinese
    case english
    case japanese
    case spanish
    case french
    case german
    case italian
    case portuguese
    case korean
}

enum AppRegion: String, Codable, CaseIterable {
    case china
    case japan
    case unitedStates
    case spain
    case france
    case germany
    case italy
    case portugal
    case brazil
    case southKorea
    case unitedKingdom
    case canada
    case australia
    case singapore
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
    case other

    var id: String { rawValue }
}

enum EmergencyService: String, Codable, CaseIterable, Identifiable {
    case medical
    case police
    case fire
    case traffic

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

    var defaultEmoji: String? {
        guard category == .family else { return nil }

        switch relationship {
        case .some(.daughter): return "👧"
        case .some(.son): return "👦"
        case .some(.spouse): return "❤️"
        case .some(.grandson): return "👦"
        case .some(.granddaughter): return "👧"
        case .some(.grandchild): return "🧒"
        case .some(.nephew): return "👦"
        case .some(.niece): return "👧"
        case .some(.other), .none: return "🧑"
        }
    }

    var iconName: String {
        switch category {
        case .systemEmergency:
            switch emergencyService {
            case .medical: return "cross.case.fill"
            case .police: return "shield.lefthalf.filled"
            case .fire: return "flame.fill"
            case .traffic: return "car.fill"
            case nil: return "phone.fill"
            }
        case .family: return "person.fill"
        case .other:
            switch otherType {
            case .doctor: return "stethoscope"
            case .caregiver: return "heart.circle.fill"
            case .neighbor: return "house.fill"
            case .propertyManager: return "building.2.fill"
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
            case .traffic: return .green
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

struct CallState: Equatable {
    var contact: Contact
    var startDate: Date
    var phase: CallPhase = .connecting
}

enum AppScreen: Equatable {
    case home
    case confirm
    case newFamily
    case newOther
    case editContact(Contact)
    case inCall
}

struct LocalizedStrings {
    let language: AppLanguage

    var appTitle: String {
        switch language {
        case .chinese: return "紧急联系人"
        case .english: return "Emergency Contacts"
        case .japanese: return "緊急連絡先"
        case .spanish: return "Contactos de Emergencia"
        case .french: return "Contacts d'Urgence"
        case .german: return "Notfallkontakte"
        case .italian: return "Contatti di Emergenza"
        case .portuguese: return "Contatos de Emergência"
        case .korean: return "긴급 연락처"
        }
    }

    var subtitle: String {
        switch language {
        case .chinese: return "点选联系人，再按拨打。"
        case .english: return "Tap a contact, then press Call."
        case .japanese: return "連絡先をタップして、発信を押してください。"
        case .spanish: return "Toque un contacto y presione Llamar."
        case .french: return "Appuyez sur un contact, puis sur Appeler."
        case .german: return "Tippen Sie auf einen Kontakt und dann auf Anrufen."
        case .italian: return "Tocca un contatto, poi premi Chiama."
        case .portuguese: return "Toque em um contato e pressione Ligar."
        case .korean: return "연락처를 탭한 다음 통화를 누르세요."
        }
    }

    var systemEmergencyTitle: String {
        switch language {
        case .chinese: return "系统紧急电话"
        case .english: return "System Emergency"
        case .japanese: return "緊急電話"
        case .spanish: return "Emergencia"
        case .french: return "Urgence"
        case .german: return "Notfall"
        case .italian: return "Emergenza"
        case .portuguese: return "Emergência"
        case .korean: return "긴급 전화"
        }
    }

    var familyTitle: String {
        switch language {
        case .chinese: return "家人"
        case .english: return "Family"
        case .japanese: return "家族"
        case .spanish: return "Familia"
        case .french: return "Famille"
        case .german: return "Familie"
        case .italian: return "Famiglia"
        case .portuguese: return "Família"
        case .korean: return "가족"
        }
    }

    var othersTitle: String {
        switch language {
        case .chinese: return "其他联系人"
        case .english: return "Others"
        case .japanese: return "その他の連絡先"
        case .spanish: return "Otros"
        case .french: return "Autres"
        case .german: return "Andere"
        case .italian: return "Altri"
        case .portuguese: return "Outros"
        case .korean: return "기타 연락처"
        }
    }

    var addFamilyButton: String {
        switch language {
        case .chinese: return "添加家人联系人"
        case .english: return "Add Family Contact"
        case .japanese: return "家族を追加"
        case .spanish: return "Añadir Familiar"
        case .french: return "Ajouter Famille"
        case .german: return "Familie Hinzufügen"
        case .italian: return "Aggiungi Famiglia"
        case .portuguese: return "Adicionar Família"
        case .korean: return "가족 추가"
        }
    }

    var addOtherButton: String {
        switch language {
        case .chinese: return "添加其他联系人"
        case .english: return "Add Other Contact"
        case .japanese: return "連絡先を追加"
        case .spanish: return "Añadir Contacto"
        case .french: return "Ajouter Contact"
        case .german: return "Kontakt Hinzufügen"
        case .italian: return "Aggiungi Contatto"
        case .portuguese: return "Adicionar Contato"
        case .korean: return "연락처 추가"
        }
    }

    var noFamilyPlaceholder: String {
        switch language {
        case .chinese: return "还没有家人联系人。"
        case .english: return "No family contacts yet."
        case .japanese: return "家族の連絡先がまだありません。"
        default: return "No family contacts yet."
        }
    }

    var noOtherPlaceholder: String {
        switch language {
        case .chinese: return "还没有其他联系人。"
        case .english: return "No other contacts yet."
        case .japanese: return "その他の連絡先がまだありません。"
        default: return "No other contacts yet."
        }
    }

    var confirmCallTitle: String {
        switch language {
        case .chinese: return "确认拨号"
        case .english: return "Confirm Call"
        case .japanese: return "発信確認"
        default: return "Confirm Call"
        }
    }

    var callButton: String {
        switch language {
        case .chinese: return "拨打"
        case .english: return "Call"
        case .japanese: return "発信"
        case .spanish: return "Llamar"
        case .french: return "Appeler"
        case .german: return "Anrufen"
        case .italian: return "Chiama"
        case .portuguese: return "Ligar"
        case .korean: return "통화"
        }
    }

    var cancelButton: String {
        switch language {
        case .chinese: return "取消"
        case .english: return "Cancel"
        case .japanese: return "キャンセル"
        case .spanish: return "Cancelar"
        case .french: return "Annuler"
        case .german: return "Abbrechen"
        case .italian: return "Annulla"
        case .portuguese: return "Cancelar"
        case .korean: return "취소"
        }
    }

    var hangUpButton: String {
        switch language {
        case .chinese: return "挂断"
        case .english: return "Hang Up"
        case .japanese: return "終了"
        default: return "Hang Up"
        }
    }

    var callDurationLabel: String {
        switch language {
        case .chinese: return "通话时间"
        case .english: return "Call Duration"
        case .japanese: return "通話時間"
        default: return "Call Duration"
        }
    }

    var languageToggleLabel: String {
        switch language {
        case .chinese: return "English"
        case .english: return "中文"
        default: return "English"
        }
    }

    func displayName(for relationship: FamilyRelationship) -> String {
        switch (language, relationship) {
        case (.chinese, .daughter): return "女儿"
        case (.chinese, .son): return "儿子"
        case (.chinese, .spouse): return "配偶"
        case (.chinese, .grandson): return "孙子"
        case (.chinese, .granddaughter): return "孙女"
        case (.chinese, .grandchild): return "孙辈"
        case (.chinese, .nephew): return "外甥"
        case (.chinese, .niece): return "外甥女"
        case (.chinese, .other): return "家人"
        case (.english, .daughter): return "Daughter"
        case (.english, .son): return "Son"
        case (.english, .spouse): return "Spouse"
        case (.english, .grandson): return "Grandson"
        case (.english, .granddaughter): return "Granddaughter"
        case (.english, .grandchild): return "Grandchild"
        case (.english, .nephew): return "Nephew"
        case (.english, .niece): return "Niece"
        case (.english, .other): return "Family"
        case (.japanese, .daughter): return "娘"
        case (.japanese, .son): return "息子"
        case (.japanese, .spouse): return "配偶者"
        case (.japanese, .grandson): return "孫"
        case (.japanese, .granddaughter): return "孫娘"
        case (.japanese, .grandchild): return "孫"
        case (.japanese, .nephew): return "甥"
        case (.japanese, .niece): return "姪"
        case (.japanese, .other): return "家族"
        default:
            // Fallback to English for other languages
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
    }

    func displayName(for type: OtherContactType) -> String {
        switch (language, type) {
        case (.chinese, .doctor): return "医生"
        case (.chinese, .caregiver): return "护工"
        case (.chinese, .neighbor): return "邻居"
        case (.chinese, .propertyManager): return "物业"
        case (.chinese, .other): return "常用联系人"
        case (.english, .doctor): return "Doctor"
        case (.english, .caregiver): return "Caregiver"
        case (.english, .neighbor): return "Neighbor"
        case (.english, .propertyManager): return "Property Manager"
        case (.english, .other): return "Contact"
        case (.japanese, .doctor): return "医師"
        case (.japanese, .caregiver): return "介護者"
        case (.japanese, .neighbor): return "隣人"
        case (.japanese, .propertyManager): return "管理人"
        case (.japanese, .other): return "連絡先"
        default:
            // Fallback to English for other languages
            switch type {
            case .doctor: return "Doctor"
            case .caregiver: return "Caregiver"
            case .neighbor: return "Neighbor"
            case .propertyManager: return "Property Manager"
            case .other: return "Contact"
            }
        }
    }

    var connectingLabel: String {
        switch language {
        case .chinese: return "正在连接…"
        case .english: return "Connecting…"
        case .japanese: return "接続中…"
        default: return "Connecting…"
        }
    }

    var nameField: String {
        switch language {
        case .chinese: return "姓名"
        case .english: return "Name"
        case .japanese: return "名前"
        default: return "Name"
        }
    }

    var phoneField: String {
        switch language {
        case .chinese: return "电话号码"
        case .english: return "Phone Number"
        case .japanese: return "電話番号"
        default: return "Phone Number"
        }
    }

    var relationshipField: String {
        switch language {
        case .chinese: return "关系"
        case .english: return "Relationship"
        case .japanese: return "続柄"
        default: return "Relationship"
        }
    }

    var typeField: String {
        switch language {
        case .chinese: return "类型"
        case .english: return "Type"
        case .japanese: return "種類"
        default: return "Type"
        }
    }

    var saveButton: String {
        switch language {
        case .chinese: return "保存"
        case .english: return "Save"
        case .japanese: return "保存"
        default: return "Save"
        }
    }

    var deleteButton: String {
        switch language {
        case .chinese:
            return "确认删除此联系人"
        case .english:
            return "Delete This Contact"
        case .japanese:
            return "この連絡先を削除"
        default:
            return "Delete This Contact"
        }
    }

    var editButton: String {
        switch language {
        case .chinese: return "编辑"
        case .english: return "Edit"
        case .japanese: return "編集"
        default: return "Edit"
        }
    }

    var addFamilyTitle: String {
        switch language {
        case .chinese: return "添加家人"
        case .english: return "Add Family Contact"
        case .japanese: return "家族を追加"
        default: return "Add Family Contact"
        }
    }

    var addOtherTitle: String {
        switch language {
        case .chinese: return "添加联系人"
        case .english: return "Add Other Contact"
        case .japanese: return "連絡先を追加"
        default: return "Add Other Contact"
        }
    }

    var editContactTitle: String {
        switch language {
        case .chinese: return "编辑联系人"
        case .english: return "Edit Contact"
        case .japanese: return "連絡先を編集"
        default: return "Edit Contact"
        }
    }

    var choosePhotoButton: String {
        switch language {
        case .chinese: return "添加照片"
        case .english: return "Add Photo"
        case .japanese: return "写真を追加"
        default: return "Add Photo"
        }
    }

    var swipeHint: String {
        switch language {
        case .chinese:
            return "左滑可删除，右滑可编辑"
        case .english:
            return "Swipe left to delete, right to edit"
        case .japanese:
            return "左スワイプで削除、右スワイプで編集"
        default:
            return "Swipe left to delete, right to edit"
        }
    }

    var invalidPhoneMessage: String {
        switch language {
        case .chinese:
            return "电话号码只能包含数字"
        case .english:
            return "Phone number can only contain digits"
        case .japanese:
            return "電話番号は数字のみ入力できます"
        default:
            return "Phone number can only contain digits"
        }
    }

    var invalidPhoneLengthMessage: String {
        switch language {
        case .chinese:
            return "电话号码位数不正确"
        case .english:
            return "Phone number has invalid length"
        case .japanese:
            return "電話番号の桁数が正しくありません"
        default:
            return "Phone number has invalid length"
        }
    }

    func displayName(for service: EmergencyService) -> String {
        switch (language, service) {
        case (.chinese, .medical): return "急救电话"
        case (.chinese, .police): return "报警电话"
        case (.chinese, .fire): return "火警电话"
        case (.chinese, .traffic): return "交通事故报警"
        case (.english, .medical): return "Emergency"
        case (.english, .police): return "Police"
        case (.english, .fire): return "Fire"
        case (.english, .traffic): return "Traffic"
        case (.japanese, .medical): return "救急"
        case (.japanese, .police): return "警察"
        case (.japanese, .fire): return "消防"
        case (.japanese, .traffic): return "交通事故"
        default:
            // Fallback to English for other languages
            switch service {
            case .medical: return "Emergency"
            case .police: return "Police"
            case .fire: return "Fire"
            case .traffic: return "Traffic"
            }
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

@Observable
class AppModel: NSObject, CLLocationManagerDelegate {
    private let storageKey = "userContacts"
    private let swipeHintSeenKey = "hasSeenSwipeHint"
    private let regionKey = "currentRegion"
    private let locationManager = CLLocationManager()

    var language: AppLanguage = .chinese
    var region: AppRegion = .china
    var userContacts: [Contact] = []
    var currentScreen: AppScreen = .home
    var selectedContact: Contact?
    var currentCall: CallState?
    var hasSeenSwipeHint: Bool = false

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        loadContacts()
        hasSeenSwipeHint = UserDefaults.standard.bool(forKey: swipeHintSeenKey)
        loadRegion()
        requestInitialRegion()
    }

    var strings: LocalizedStrings {
        LocalizedStrings(language: language)
    }

    var systemEmergencyContacts: [Contact] {
        let config: [(EmergencyService, String)]
        switch region {
        case .china:
            config = [
                (.medical, "120"),
                (.police, "110"),
                (.fire, "119"),
                (.traffic, "122")
            ]
        case .japan:
            config = [
                (.police, "110"),
                (.fire, "119"),
                (.medical, "119")
            ]
        case .southKorea:
            config = [
                (.police, "112"),
                (.fire, "119"),
                (.medical, "119")
            ]
        case .unitedStates, .canada:
            config = [(.medical, "911"), (.police, "911"), (.fire, "911")]
        case .spain, .france, .germany, .italy, .portugal, .unitedKingdom:
            // Most European countries use 112 as universal emergency number
            config = [(.medical, "112"), (.police, "112"), (.fire, "112")]
        case .brazil:
            config = [
                (.medical, "192"),
                (.police, "190"),
                (.fire, "193")
            ]
        case .australia:
            config = [(.medical, "000"), (.police, "000"), (.fire, "000")]
        case .singapore:
            config = [
                (.police, "999"),
                (.fire, "995"),
                (.medical, "995")
            ]
        case .other:
            config = [(.medical, "112"), (.police, "112"), (.fire, "112")]
        }

        return config.map { service, number in
            Contact(
                id: UUID(),
                name: "",
                phoneNumber: number,
                category: .systemEmergency,
                relationship: nil,
                otherType: nil,
                emergencyService: service,
                avatarImageData: nil
            )
        }
    }

    var familyContacts: [Contact] {
        userContacts.filter { $0.category == .family }
    }

    var otherContacts: [Contact] {
        userContacts.filter { $0.category == .other }
    }

    var phonePrefix: String {
        switch region {
        case .china: return "+86"
        case .japan: return "+81"
        case .southKorea: return "+82"
        case .unitedStates, .canada: return "+1"
        case .spain: return "+34"
        case .france: return "+33"
        case .germany: return "+49"
        case .italy: return "+39"
        case .portugal: return "+351"
        case .brazil: return "+55"
        case .unitedKingdom: return "+44"
        case .australia: return "+61"
        case .singapore: return "+65"
        case .other: return "+1"
        }
    }

    var expectedPhoneDigits: Int {
        switch region {
        case .china: return 11
        case .japan, .southKorea: return 10
        case .unitedStates, .canada: return 10
        case .spain: return 9
        case .france: return 9
        case .germany: return 11
        case .italy: return 10
        case .portugal: return 9
        case .brazil: return 11
        case .unitedKingdom: return 10
        case .australia: return 9
        case .singapore: return 8
        case .other: return 10
        }
    }

    func toggleLanguage() {
        switch language {
        case .chinese:
            language = .english
        case .english:
            language = .chinese
        default:
            language = .english
        }
    }

    func showHome() {
        currentScreen = .home
        selectedContact = nil
        checkForRegionChange()
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

    func checkForRegionChange() {
        requestRegionRefresh()
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

    // MARK: - Region & Location

    private func loadRegion() {
        if let raw = UserDefaults.standard.string(forKey: regionKey),
           let saved = AppRegion(rawValue: raw) {
            // Previously saved from a real location lookup or confirmed by user
            region = saved
        } else {
            // First launch: make a best guess from system region but do NOT persist yet.
            // We'll overwrite with real GPS-based region once we get a location fix.
            region = fallbackRegionFromLocale()
        }
        applyLanguageForRegion()
        ensureDefaultsForCurrentRegion()
    }

    private func fallbackRegionFromLocale() -> AppRegion {
        // Default to United States (English) on first launch
        // GPS will override this once location is detected
        return .unitedStates
    }

    private func applyLanguageForRegion() {
        switch region {
        case .china:
            language = .chinese
        case .japan:
            language = .japanese
        case .southKorea:
            language = .korean
        case .spain:
            language = .spanish
        case .france:
            language = .french
        case .germany:
            language = .german
        case .italy:
            language = .italian
        case .portugal:
            language = .portuguese
        case .brazil:
            language = .portuguese
        case .unitedStates, .canada, .unitedKingdom, .australia, .singapore, .other:
            language = .english
        }
    }

    private func ensureDefaultsForCurrentRegion() {
        switch region {
        case .china:
            ensureChineseDefaultHotlines()
        case .unitedStates:
            ensureUSDefaultEmergency()
        default:
            break
        }
    }

    private func ensureChineseDefaultHotlines() {
        func hasNumber(_ number: String) -> Bool {
            userContacts.contains { $0.phoneNumber == number }
        }

        var changed = false

        if !hasNumber("12333") {
            let contact = Contact(
                id: UUID(),
                name: "社保服务电话",
                phoneNumber: "12333",
                category: .other,
                relationship: nil,
                otherType: .other,
                emergencyService: nil,
                avatarImageData: nil
            )
            userContacts.append(contact)
            changed = true
        }

        if !hasNumber("12345") {
            let contact = Contact(
                id: UUID(),
                name: "政务服务热线",
                phoneNumber: "12345",
                category: .other,
                relationship: nil,
                otherType: .other,
                emergencyService: nil,
                avatarImageData: nil
            )
            userContacts.append(contact)
            changed = true
        }

        if changed {
            saveContacts()
        }
    }

    private func ensureUSDefaultEmergency() {
        func hasNumber(_ number: String) -> Bool {
            userContacts.contains { $0.phoneNumber == number }
        }

        var changed = false

        // Add 911 if not present
        if !hasNumber("911") {
            let contact = Contact(
                id: UUID(),
                name: "Emergency",
                phoneNumber: "911",
                category: .systemEmergency,
                relationship: nil,
                otherType: nil,
                emergencyService: .medical,
                avatarImageData: nil
            )
            userContacts.append(contact)
            changed = true
        }

        if changed {
            saveContacts()
        }
    }

    private func requestInitialRegion() {
        guard CLLocationManager.locationServicesEnabled() else { return }

        switch locationManager.authorizationStatus {
        case .notDetermined:
            // This will trigger the system prompt asking for location permission.
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
            startMonitoringSignificantChanges()
        default:
            break
        }
    }

    private func requestRegionRefresh() {
        guard CLLocationManager.locationServicesEnabled() else { return }

        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }

    private func startMonitoringSignificantChanges() {
        if CLLocationManager.significantLocationChangeMonitoringAvailable() {
            locationManager.startMonitoringSignificantLocationChanges()
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
            startMonitoringSignificantChanges()
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        let newRegion = region(for: location)
        let hadSavedRegion = UserDefaults.standard.string(forKey: regionKey) != nil

        // First fix: on first launch, trust the real GPS region.
        // Later, whenever the detected country differs from the saved one,
        // immediately update region, language, and emergency numbers.
        if !hadSavedRegion || newRegion != region {
            region = newRegion
            UserDefaults.standard.set(newRegion.rawValue, forKey: regionKey)
            applyLanguageForRegion()
            ensureDefaultsForCurrentRegion()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let hasSavedRegion = UserDefaults.standard.string(forKey: regionKey) != nil
        if !hasSavedRegion {
            // As a last resort, fall back to system region settings
            let fallback = fallbackRegionFromLocale()
            region = fallback
            UserDefaults.standard.set(fallback.rawValue, forKey: regionKey)
            applyLanguageForRegion()
            ensureDefaultsForCurrentRegion()
        }
    }

    private func region(for location: CLLocation) -> AppRegion {
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude

        // China
        if (18.0...54.0).contains(lat) && (73.0...135.0).contains(lon) {
            return .china
        }

        // Japan
        if (24.0...46.0).contains(lat) && (123.0...146.0).contains(lon) {
            return .japan
        }

        // South Korea
        if (33.0...39.0).contains(lat) && (124.0...132.0).contains(lon) {
            return .southKorea
        }

        // Spain
        if (36.0...44.0).contains(lat) && (-10.0...5.0).contains(lon) {
            return .spain
        }

        // France
        if (41.0...51.0).contains(lat) && (-5.0...10.0).contains(lon) {
            return .france
        }

        // Germany
        if (47.0...55.0).contains(lat) && (6.0...15.0).contains(lon) {
            return .germany
        }

        // Italy
        if (36.0...47.0).contains(lat) && (6.0...19.0).contains(lon) {
            return .italy
        }

        // Portugal
        if (37.0...42.0).contains(lat) && (-10.0...(-6.0)).contains(lon) {
            return .portugal
        }

        // Brazil
        if ((-34.0)...6.0).contains(lat) && ((-74.0)...(-34.0)).contains(lon) {
            return .brazil
        }

        // United Kingdom
        if (49.0...61.0).contains(lat) && ((-8.0)...2.0).contains(lon) {
            return .unitedKingdom
        }

        // Canada
        if (41.0...84.0).contains(lat) && ((-141.0)...(-52.0)).contains(lon) {
            return .canada
        }

        // United States (including Alaska and Hawaii)
        if ((25.0...50.0).contains(lat) && ((-125.0)...(-66.0)).contains(lon)) ||
           ((19.0...22.0).contains(lat) && ((-161.0)...(-154.0)).contains(lon)) ||
           ((51.0...72.0).contains(lat) && ((-180.0)...(-130.0)).contains(lon)) {
            return .unitedStates
        }

        // Australia
        if ((-44.0)...(-10.0)).contains(lat) && (113.0...154.0).contains(lon) {
            return .australia
        }

        // Singapore
        if (1.0...2.0).contains(lat) && (103.0...104.0).contains(lon) {
            return .singapore
        }

        // Everything else defaults to .other (uses 112 emergency number)
        return .other
    }

    private func loadContacts() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            userContacts = []
            return
        }
        do {
            let decoded = try JSONDecoder().decode([Contact].self, from: data)
            userContacts = decoded
        } catch {
            userContacts = []
        }
    }

    private func saveContacts() {
        do {
            let data = try JSONEncoder().encode(userContacts)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
        }
    }
}
