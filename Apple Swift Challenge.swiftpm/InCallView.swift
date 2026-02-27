import SwiftUI
import UIKit

struct InCallView: View {
    var model: AppModel
    @State private var elapsed: TimeInterval = 0
    @State private var isConnected = false
    @State private var showEndingMessage = false
    @State private var connectTask: Task<Void, Never>? = nil
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        if let call = model.currentCall {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 24) {
                    if !showEndingMessage {
                        if isConnected {
                            Text(formatDuration(elapsed))
                                .font(.system(size: 58, weight: .light, design: .monospaced))
                                .foregroundStyle(.primary)
                                .accessibilityLabel("Call duration: \(formatDurationForVoiceOver(elapsed))")
                        } else {
                            Text("Connecting…")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                                .accessibilityLabel("Connecting to \(call.contact.displayName)")
                        }
                    }
                    
                    Spacer()
                    
                    // Different animations based on contact type
                    if call.contact.category == .family {
                        HeartbeatView(contact: call.contact, model: model)
                    } else if call.contact.category == .systemEmergency {
                        EmergencyCallView(contact: call.contact, model: model)
                    } else {
                        SimpleCallView(contact: call.contact)
                    }
                    
                    Text(call.contact.displayName)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .accessibilityLabel("Calling \(call.contact.displayName)")

                    // Demo text between avatar and hang-up
                    Text("Demo mode — calls are simulated")
                        .font(.title.weight(.semibold))
                        .foregroundStyle(.primary)
                        .accessibilityLabel("Demo mode. Calls are simulated.")

                    Spacer()

                    // Hang up button - minimum 44x44 touch target
                    Button(action: {
                        // Immediately stop any pending connect and reset connected state
                        connectTask?.cancel()
                        connectTask = nil
                        isConnected = false
                        withAnimation { 
                            showEndingMessage = true
                        }
                        announce("Call ended")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation {
                                model.endCall()
                            }
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "phone.down.fill")
                                .font(.system(size: 30))
                            Text("Hang Up")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(.red)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .accessibilityLabel("Hang up call with \(call.contact.displayName)")
                    .accessibilityHint("Tap to end the call")
                }
                .padding(32)
                .onReceive(timer) { _ in
                    if isConnected {
                        elapsed = Date().timeIntervalSince(call.startDate)
                    }
                }
                .onAppear {
                    if call.contact.category == .family {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                    announce("Calling \(call.contact.displayName)")
                    // Start a cancellable connect task
                    connectTask?.cancel()
                    connectTask = Task {
                        try? await Task.sleep(for: .seconds(2))
                        if Task.isCancelled { return }
                        await MainActor.run {
                            withAnimation { isConnected = true }
                            announce("Connected to \(call.contact.displayName)")
                        }
                    }
                }
                .onDisappear {
                    connectTask?.cancel()
                    connectTask = nil
                }
                
                // Emotional ending message overlay
                if showEndingMessage {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                            Image(systemName: "heart.circle.fill")
                                .font(.system(size: 80))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.orange, .pink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            Text(call.contact.category == .family 
                                 ? "Every call she makes\nis a moment she's not alone."
                                 : "Help is always just\none tap away.")
                                .font(.system(size: 28, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                                .lineSpacing(8)
                        }
                        .padding(40)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(.ultraThinMaterial)
                        )
                        .padding(40)
                    }
                    .transition(.scale.combined(with: .opacity))
                    .accessibilityLabel(call.contact.category == .family 
                        ? "Every call she makes is a moment she's not alone"
                        : "Help is always just one tap away")
                }
            }
        }
    }
    
    private func formatDuration(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func formatDurationForVoiceOver(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        if minutes == 0 {
            return "\(seconds) seconds"
        } else if seconds == 0 {
            return "\(minutes) minutes"
        } else {
            return "\(minutes) minutes and \(seconds) seconds"
        }
    }

    private func announce(_ text: String) {
        SpeechAssistant.shared.speak(text)
    }
}

// MARK: - Heartbeat View (Family only)

struct HeartbeatView: View {
    let contact: Contact
    var model: AppModel
    @State private var isFloating = false
    @State private var isGlowing = false
    @State private var heartbeatScale: CGFloat = 1.0
    @State private var rotationAngle: Double = 0
    @State private var ambientGlow1 = false
    @State private var ambientGlow2 = false
    @State private var ambientGlow3 = false
    
    var body: some View {
        ZStack {
            // Ambient volumetric lighting
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.pink.opacity(0.15),
                            Color.orange.opacity(0.08),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 80,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .scaleEffect(ambientGlow1 ? 1.2 : 0.9)
                .opacity(ambientGlow1 ? 0.3 : 0.6)
                .blur(radius: 20)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.orange.opacity(0.2),
                            Color.pink.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 60,
                        endRadius: 160
                    )
                )
                .frame(width: 320, height: 320)
                .scaleEffect(ambientGlow2 ? 1.15 : 0.85)
                .opacity(ambientGlow2 ? 0.4 : 0.7)
                .blur(radius: 15)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.pink.opacity(0.25),
                            Color.orange.opacity(0.15),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 40,
                        endRadius: 120
                    )
                )
                .frame(width: 240, height: 240)
                .scaleEffect(ambientGlow3 ? 1.1 : 0.9)
                .opacity(ambientGlow3 ? 0.5 : 0.8)
                .blur(radius: 10)
            
            // 3D Frosted Glass Heart
            ZStack {
                Image(systemName: "heart.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 320, height: 280)
                    .foregroundStyle(.black.opacity(0.1))
                    .blur(radius: 8)
                    .offset(y: 8)
                
                Image(systemName: "heart.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 320, height: 280)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.4, blue: 0.5),
                                Color(red: 1.0, green: 0.6, blue: 0.4),
                                Color(red: 1.0, green: 0.5, blue: 0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .opacity(0.85)
                    .shadow(color: .pink.opacity(0.3), radius: 20, x: 0, y: 10)
                    .shadow(color: .orange.opacity(0.2), radius: 30, x: 0, y: 15)
                
                Image(systemName: "heart.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 320, height: 280)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.1),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .center
                        )
                    )
                    .blur(radius: 1)
                
                Image(systemName: "heart.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 320, height: 280)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(isGlowing ? 0.6 : 0.3),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                    .blur(radius: 2)
                
                // Avatar in center
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 150, height: 150)
                    .overlay {
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.6),
                                        Color.pink.opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                    }
                    .overlay {
                        if let data = contact.avatarImageData,
                           let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 140, height: 140)
                                .clipShape(Circle())
                                .animation(nil, value: contact.avatarImageData)
                                .animation(nil, value: isFloating)
                                .animation(nil, value: isGlowing)
                                .animation(nil, value: heartbeatScale)
                        } else if let emoji = contact.defaultEmoji {
                            Text(emoji)
                                .font(.system(size: 96))
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: 72))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.pink, .orange],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        }
                    }
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            }
            .scaleEffect(heartbeatScale * (isFloating ? 1.03 : 1.0))
            .rotation3DEffect(
                .degrees(rotationAngle),
                axis: (x: 0.1, y: 1.0, z: 0.0)
            )
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Calling \(contact.displayName). Animated heart showing connection and care.")
        .onAppear {
            animateHeartbeat()
            
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                isFloating = true
            }
            
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isGlowing = true
            }
            
            withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
                rotationAngle = 5
            }
            
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                ambientGlow1 = true
            }
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true).delay(0.5)) {
                ambientGlow2 = true
            }
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true).delay(1.0)) {
                ambientGlow3 = true
            }
        }
    }
    
    private func animateHeartbeat() {
        withAnimation(.easeIn(duration: 0.2)) {
            heartbeatScale = 1.12
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeOut(duration: 0.2)) {
                heartbeatScale = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeIn(duration: 0.16)) {
                    heartbeatScale = 1.08
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                    withAnimation(.easeOut(duration: 0.16)) {
                        heartbeatScale = 1.0
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.68) {
                        animateHeartbeat()
                    }
                }
            }
        }
    }
}

// MARK: - Emergency Call View

struct EmergencyCallView: View {
    let contact: Contact
    var model: AppModel
    @State private var urgentPulse = false
    @State private var flashAlert1 = false
    @State private var flashAlert2 = false
    @State private var flashAlert3 = false
    @State private var rotateWarning: Double = 0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.red.opacity(0.4), lineWidth: 4)
                .frame(width: 320, height: 320)
                .scaleEffect(flashAlert1 ? 1.4 : 1.0)
                .opacity(flashAlert1 ? 0 : 0.8)
            
            Circle()
                .stroke(Color.red.opacity(0.3), lineWidth: 3)
                .frame(width: 280, height: 280)
                .scaleEffect(flashAlert2 ? 1.5 : 1.0)
                .opacity(flashAlert2 ? 0 : 0.7)
            
            Circle()
                .stroke(Color.orange.opacity(0.3), lineWidth: 3)
                .frame(width: 240, height: 240)
                .scaleEffect(flashAlert3 ? 1.6 : 1.0)
                .opacity(flashAlert3 ? 0 : 0.6)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.red.opacity(urgentPulse ? 0.4 : 0.2),
                            Color.orange.opacity(urgentPulse ? 0.2 : 0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 360)
                .blur(radius: 20)
            
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.red,
                                Color.red.opacity(0.8)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 220, height: 220)
                    .shadow(color: .red.opacity(0.6), radius: 30, x: 0, y: 10)
                    .shadow(color: .red.opacity(0.4), radius: 50, x: 0, y: 20)
                
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
                    .frame(width: 220, height: 220)
                    .rotationEffect(.degrees(rotateWarning))
                
                Image(systemName: contact.iconName)
                    .font(.system(size: 90, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
            }
            .scaleEffect(urgentPulse ? 1.15 : 1.0)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Emergency call to \(contact.displayName). Urgent alert animation showing immediate help is being contacted.")
        .onAppear {
            withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
                urgentPulse = true
            }
            
            withAnimation(.easeOut(duration: 0.8).repeatForever(autoreverses: false)) {
                flashAlert1 = true
            }
            withAnimation(.easeOut(duration: 0.8).repeatForever(autoreverses: false).delay(0.2)) {
                flashAlert2 = true
            }
            withAnimation(.easeOut(duration: 0.8).repeatForever(autoreverses: false).delay(0.4)) {
                flashAlert3 = true
            }
            
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                rotateWarning = 360
            }
        }
    }
}

// MARK: - Simple Call View

struct SimpleCallView: View {
    let contact: Contact
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(contact.iconColor.opacity(0.15))
                .frame(width: 220, height: 220)
                .scaleEffect(isPulsing ? 1.05 : 0.95)
            
            if let data = contact.avatarImageData,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 160, height: 160)
                    .clipShape(Circle())
            } else if let emoji = contact.defaultEmoji {
                Circle()
                    .fill(contact.iconColor.opacity(0.2))
                    .frame(width: 180, height: 180)
                    .overlay {
                        Text(emoji)
                            .font(.system(size: 90))
                    }
            } else {
                Image(systemName: contact.iconName)
                    .font(.system(size: 60))
                    .foregroundStyle(contact.iconColor)
            }
        }
        .accessibilityLabel("Calling \(contact.name)")
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}
