import AudioToolbox

@Observable
final class SoundService {
    static let shared = SoundService()

    var isSoundEnabled: Bool {
        didSet { UserDefaults.standard.set(isSoundEnabled, forKey: "soundEnabled") }
    }

    private let normalResetSoundID: SystemSoundID = 1104
    private let shinyFoundSoundID: SystemSoundID = 1016

    private init() {
        let stored = UserDefaults.standard.object(forKey: "soundEnabled")
        isSoundEnabled = stored != nil ? UserDefaults.standard.bool(forKey: "soundEnabled") : true
    }

    func playNormalReset() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(normalResetSoundID)
    }

    func playShinyFound() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(shinyFoundSoundID)
    }
}
