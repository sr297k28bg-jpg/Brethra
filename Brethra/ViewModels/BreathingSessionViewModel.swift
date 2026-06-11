import Foundation
import AudioToolbox
import SwiftUI

enum BreathingPhase {
    case inhale
    case exhale

    var label: String {
        switch self {
        case .inhale: return "Inhale"
        case .exhale: return "Exhale"
        }
    }

    mutating func toggle() {
        self = self == .inhale ? .exhale : .inhale
    }
}

class BreathingSessionViewModel: ObservableObject {
    @Published var phase: BreathingPhase = .inhale
    @Published var phaseProgress: Double = 0.0
    @Published var sessionDuration: TimeInterval = 0
    @Published var animationScale: Double = 1.0
    @Published var isRunning: Bool = false

    let breathingPattern: BreathingPattern
    let intervalSettings: IntervalSettings
    var soundEnabled: Bool
    var vibrationEnabled: Bool

    private var activePattern: BreathingPattern
    private var sessionTimer: Timer?
    private var phaseTimer: Timer?
    private var intervalTimer: Timer?
    private var phaseElapsed: Double = 0
    private var intervalElapsed: Int = 0
    private var isHighIntensity: Bool = true
    private var tapTimes: [Date] = []

    init(
        breathingPattern: BreathingPattern,
        intervalSettings: IntervalSettings,
        soundEnabled: Bool,
        vibrationEnabled: Bool
    ) {
        self.breathingPattern = breathingPattern
        self.intervalSettings = intervalSettings
        self.soundEnabled = soundEnabled
        self.vibrationEnabled = vibrationEnabled
        self.activePattern = breathingPattern
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        sessionDuration = 0
        phase = .inhale
        activePattern = breathingPattern
        isHighIntensity = true

        sessionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.sessionDuration += 1
        }

        if intervalSettings.isEnabled {
            intervalElapsed = 0
            startIntervalCycle()
        }

        beginPhase()
    }

    func stop() {
        isRunning = false
        sessionTimer?.invalidate()
        phaseTimer?.invalidate()
        intervalTimer?.invalidate()
        sessionTimer = nil
        phaseTimer = nil
        intervalTimer = nil
    }

    func handleTap() {
        let now = Date()
        tapTimes.append(now)
        tapTimes = tapTimes.filter { now.timeIntervalSince($0) < 6 }
        guard tapTimes.count >= 2 else { return }

        let intervals = zip(tapTimes, tapTimes.dropFirst()).map { $1.timeIntervalSince($0) }
        let avg = intervals.reduce(0, +) / Double(intervals.count)
        let secs = max(1, min(6, Int(avg.rounded())))
        activePattern = .custom(inhale: secs, exhale: secs)
    }

    private func beginPhase() {
        phaseTimer?.invalidate()
        phaseElapsed = 0
        let duration = phaseDuration

        withAnimation(.easeInOut(duration: duration)) {
            animationScale = phase == .inhale ? 1.45 : 0.85
        }

        if vibrationEnabled { triggerHaptic() }
        if soundEnabled { playTone() }

        phaseTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.phaseElapsed += 0.05
            self.phaseProgress = min(self.phaseElapsed / self.phaseDuration, 1.0)
            if self.phaseElapsed >= self.phaseDuration {
                self.phase.toggle()
                self.beginPhase()
            }
        }
    }

    private var phaseDuration: Double {
        phase == .inhale ? Double(activePattern.inhale) : Double(activePattern.exhale)
    }

    private func startIntervalCycle() {
        intervalElapsed = 0
        intervalTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.intervalElapsed += 1
            let limit = self.isHighIntensity
                ? self.intervalSettings.highIntensityDuration
                : self.intervalSettings.lowIntensityDuration
            if self.intervalElapsed >= limit {
                self.isHighIntensity.toggle()
                self.intervalElapsed = 0
                self.activePattern = self.isHighIntensity
                    ? self.breathingPattern
                    : BreathingPattern.threeThree
            }
        }
    }

    private func triggerHaptic() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }

    private func playTone() {
        let soundID: SystemSoundID = phase == .inhale ? 1057 : 1103
        AudioServicesPlaySystemSound(soundID)
    }

    var formattedDuration: String {
        let m = Int(sessionDuration) / 60
        let s = Int(sessionDuration) % 60
        return String(format: "%02d:%02d", m, s)
    }
}
