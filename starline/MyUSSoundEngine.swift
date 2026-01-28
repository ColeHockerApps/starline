import SwiftUI
import Combine
import AVFoundation

@MainActor
final class MyUSSoundEngine: ObservableObject {

    static let shared = MyUSSoundEngine()

    @Published var isEnabled: Bool = true

    private var players: [String: AVAudioPlayer] = [:]
    private let enabledKey = "myus.sound.enabled"

    private init() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: enabledKey) != nil {
            isEnabled = defaults.bool(forKey: enabledKey)
        } else {
            isEnabled = true
        }
    }

    func setEnabled(_ value: Bool) {
        isEnabled = value
        UserDefaults.standard.set(value, forKey: enabledKey)
        if !value {
            stopAll()
        }
    }

    func preload(_ name: String, ext: String = "wav") {
        guard players[name] == nil else { return }
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else { return }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            players[name] = player
        } catch {
            // silent stub
        }
    }

    func play(_ name: String) {
        guard isEnabled else { return }
        guard let player = players[name] else { return }

        player.currentTime = 0
        player.play()
    }

    func stop(_ name: String) {
        guard let player = players[name] else { return }
        player.stop()
    }

    func stopAll() {
        players.values.forEach { $0.stop() }
    }

    func clear() {
        stopAll()
        players.removeAll()
    }
}
