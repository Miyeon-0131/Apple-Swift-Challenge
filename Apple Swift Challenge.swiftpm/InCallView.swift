import SwiftUI
import UIKit

struct InCallView: View {
    var model: AppModel
    @State private var elapsed: TimeInterval = 0
    @State private var isConnected = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        if let call = model.currentCall {
            VStack(spacing: 24) {
                if isConnected {
                    Text(formatDuration(elapsed))
                        .font(.system(size: 54, weight: .light, design: .monospaced))
                        .foregroundStyle(.primary)
                        .accessibilityLabel(model.strings.callDurationLabel + " " + formatDuration(elapsed))
                } else {
                    Text(model.strings.connectingLabel)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if call.contact.category == .family {
                    HeartbeatView(contact: call.contact, model: model)
                } else if call.contact.category == .systemEmergency {
                    EmergencyCallView(contact: call.contact, model: model)
                } else {
                    SimpleCallView(contact: call.contact)
                }

                Text(model.strings.contactDisplayName(for: call.contact))
                    .font(.system(size: 44, weight: .bold))

                Spacer()

                Button(action: {
                    withAnimation { model.endCall() }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "phone.down.fill")
                            .font(.title)
                        Text(model.strings.hangUpButton)
                            .font(.system(size: 32, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(.red)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .accessibilityLabel(model.strings.hangUpButton)
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
            }
            .task {
                try? await Task.sleep(for: .seconds(2))
                withAnimation { isConnected = true }
            }
        }
    }

    private func formatDuration(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
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
            // Ambient volumetric lighting - outer glow
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
            
            // Mid-range soft glow
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
            
            // Inner warm glow
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
                // Heart shadow for depth
                Image(systemName: "heart.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 320, height: 280)
                    .foregroundStyle(.black.opacity(0.1))
                    .blur(radius: 8)
                    .offset(y: 8)
                
                // Main frosted glass heart with gradient
                Image(systemName: "heart.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 320, height: 280)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.4, blue: 0.5),  // Warm pink
                                Color(red: 1.0, green: 0.6, blue: 0.4),  // Soft orange
                                Color(red: 1.0, green: 0.5, blue: 0.6)   // Light pink
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .opacity(0.85)
                    .shadow(color: .pink.opacity(0.3), radius: 20, x: 0, y: 10)
                    .shadow(color: .orange.opacity(0.2), radius: 30, x: 0, y: 15)
                
                // Frosted glass overlay effect
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
                
                // Shimmer highlight
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

                // Avatar in center with frosted background
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
        .accessibilityLabel(model.strings.connectingLabel + " " + model.strings.contactDisplayName(for: contact))
        .onAppear {
            // Realistic heartbeat animation (lub-dub pattern)
            animateHeartbeat()
            
            // Gentle floating animation
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                isFloating = true
            }
            
            // Soft glow pulsing
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isGlowing = true
            }
            
            // Subtle 3D rotation
            withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
                rotationAngle = 5
            }
            
            // Ambient glow animations
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
    
    // Realistic heartbeat animation with slower, calmer lub-dub pattern (50 BPM)
    private func animateHeartbeat() {
        // First beat (lub) - stronger
        withAnimation(.easeIn(duration: 0.2)) {
            heartbeatScale = 1.12
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeOut(duration: 0.2)) {
                heartbeatScale = 1.0
            }
            
            // Second beat (dub) - slightly weaker
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeIn(duration: 0.16)) {
                    heartbeatScale = 1.08
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                    withAnimation(.easeOut(duration: 0.16)) {
                        heartbeatScale = 1.0
                    }
                    
                    // Longer pause for calmer rhythm (50 BPM)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.68) {
                        animateHeartbeat()
                    }
                }
            }
        }
    }
}

// MARK: - Emergency Call View (System Emergency only)

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
            // Urgent flashing alert rings
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
            
            // Urgent red glow background
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
            
            // Main emergency icon with intense pulsing
            ZStack {
                // Warning background circle
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
                
                // Rotating warning stripes effect
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
                    .frame(width: 220, height: 220)
                    .rotationEffect(.degrees(rotateWarning))
                
                // Emergency icon
                Image(systemName: contact.iconName)
                    .font(.system(size: 90, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
            }
            .scaleEffect(urgentPulse ? 1.15 : 1.0)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(model.strings.connectingLabel + " " + model.strings.contactDisplayName(for: contact))
        .onAppear {
            // Rapid urgent pulsing (fast heartbeat under stress)
            withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
                urgentPulse = true
            }
            
            // Fast flashing alert rings
            withAnimation(.easeOut(duration: 0.8).repeatForever(autoreverses: false)) {
                flashAlert1 = true
            }
            withAnimation(.easeOut(duration: 0.8).repeatForever(autoreverses: false).delay(0.2)) {
                flashAlert2 = true
            }
            withAnimation(.easeOut(duration: 0.8).repeatForever(autoreverses: false).delay(0.4)) {
                flashAlert3 = true
            }
            
            // Rotating warning effect
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                rotateWarning = 360
            }
        }
    }
}

// MARK: - Simple Call View (Non-family)

struct SimpleCallView: View {
    let contact: Contact
    @State private var isPulsing = false

    var body: some View {
        ZStack {
            Circle()
                .fill(contact.iconColor.opacity(0.15))
                .frame(width: 180, height: 180)
                .scaleEffect(isPulsing ? 1.05 : 0.95)

            Image(systemName: contact.iconName)
                .font(.system(size: 60))
                .foregroundStyle(contact.iconColor)
        }
        .accessibilityLabel(contact.name)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}
