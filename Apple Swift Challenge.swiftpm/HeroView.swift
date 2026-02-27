import SwiftUI

struct HeroView: View {
    var model: AppModel
    private let cornerRadius: CGFloat = 28
    @State private var showHeartTransition = false
    @State private var heartScale: CGFloat = 1
    @State private var heartOpacity: Double = 1
    @State private var bgOpacity: Double = 0
    @State private var whiteFadeOpacity: Double = 0

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        
                        Spacer(minLength: geometry.size.height * 0.1)

                        // ── Brand block ──────────────────────────────────────
                        VStack(alignment: .center, spacing: 8) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: geometry.size.width > 600 ? 56 : 38))
                            .foregroundStyle(Color(red: 0.92, green: 0.35, blue: 0.45))

                        Text("Heartline")
                            .font(.system(size: geometry.size.width > 600 ? 56 : 38, weight: .heavy, design: .rounded))
                            .minimumScaleFactor(0.8)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .center)

                        Text("No numbers. Just names.")
                            .font(.system(size: geometry.size.width > 600 ? 22 : 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .minimumScaleFactor(0.8)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                        .padding(.horizontal, geometry.size.width > 600 ? 60 : 28)
                        
                        Spacer(minLength: geometry.size.width > 600 ? 40 : 20)

                        // ── Divider ──────────────────────────────────────────
                        Divider()
                            .padding(.horizontal, geometry.size.width > 600 ? 60 : 28)
                            .padding(.vertical, geometry.size.width > 600 ? 24 : 16)

                    // ── Story ────────────────────────────────────────────
                    VStack(alignment: .leading, spacing: geometry.size.width > 600 ? 16 : 10) {
                        Text("A story behind this app")
                            .font(.system(size: geometry.size.width > 600 ? 18 : 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .kerning(0.6)

                        Text("My grandmother often couldn't remember the property office number and would ask my mom for help each time.")
                            .font(.system(size: geometry.size.width > 600 ? 22 : 16, weight: .regular, design: .rounded))
                            .lineSpacing(geometry.size.width > 600 ? 6 : 4)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("I realized many seniors share the same worry. Heartline lets her—and anyone—reach family or get help with a single tap.")
                            .font(.system(size: geometry.size.width > 600 ? 22 : 16, weight: .regular, design: .rounded))
                            .lineSpacing(geometry.size.width > 600 ? 6 : 4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 60 : 28)
                    
                    Spacer(minLength: geometry.size.width > 600 ? 32 : 16)

                    // ── Feature list ─────────────────────────────────────
                    VStack(alignment: .leading, spacing: geometry.size.width > 600 ? 12 : 8) {
                        featureRow(icon: "hand.tap.fill",   color: .blue,   text: "One-tap calls — no number to remember", isIPad: geometry.size.width > 600)
                        featureRow(icon: "textformat.size", color: .orange, text: "Large text and high contrast", isIPad: geometry.size.width > 600)
                        featureRow(icon: "speaker.wave.2.fill", color: .pink, text: "Voice guidance on every action", isIPad: geometry.size.width > 600)
                    }
                    .padding(.horizontal, geometry.size.width > 600 ? 60 : 28)
                    .padding(.top, geometry.size.width > 600 ? 32 : 20)

                    // ── Dedication ────────────────────────────────────────
                    Text("Dedicated with love to all grandparents — may this app be a helping hand whenever they need it. 💗")
                        .font(.system(size: geometry.size.width > 600 ? 20 : 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.7, green: 0.1, blue: 0.3))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, geometry.size.width > 600 ? 32 : 20)
                        .padding(.vertical, geometry.size.width > 600 ? 18 : 12)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: geometry.size.width > 600 ? 18 : 14)
                                .fill(Color.pink.opacity(0.12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: geometry.size.width > 600 ? 18 : 14)
                                        .strokeBorder(Color.pink.opacity(0.35), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, geometry.size.width > 600 ? 60 : 28)
                        .padding(.top, geometry.size.width > 600 ? 24 : 16)
                    
                    Spacer(minLength: geometry.size.width > 600 ? 48 : 24)

                    // ── Start button ──────────────────────────────────────
                    Button(action: {
                        SpeechAssistant.shared.speak("Start. Go to contact list")
                        showHeartTransition = true
                    }) {
                        Text("Get Started")
                            .font(.system(size: geometry.size.width > 600 ? 26 : 19, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, geometry.size.width > 600 ? 20 : 16)
                            .background(Color(red: 0.92, green: 0.35, blue: 0.45))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: geometry.size.width > 600 ? 20 : 16))
                    }
                    .accessibilityLabel("Get Started. Go to contact list")
                    .padding(.horizontal, geometry.size.width > 600 ? 60 : 28)
                    .padding(.top, geometry.size.width > 600 ? 32 : 24)
                    .padding(.bottom, max(geometry.size.width > 600 ? 60 : 40, geometry.size.height * 0.08))
                    }
                }
            }
            // ── Heart zoom-OUT transition overlay ──────────────────
            if showHeartTransition {
                GeometryReader { geo in
                    ZStack {
                        Color(red: 0.92, green: 0.35, blue: 0.45)
                            .opacity(bgOpacity)
                            .ignoresSafeArea()

                        Image(systemName: "heart.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.white)
                            // heart starts at 100pt, zooms to fill longest side + buffer
                            .frame(width: 100, height: 100)
                            .scaleEffect(heartScale)
                            .opacity(heartOpacity)
                            .position(x: geo.size.width / 2, y: geo.size.height / 2)

                        Color.white
                            .opacity(whiteFadeOpacity)
                            .ignoresSafeArea()
                    }
                }
                // Clip so the heart never overflows the screen
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .ignoresSafeArea()
                .onAppear {
                    // Step 1: bg fades in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        withAnimation(.easeOut(duration: 0.6)) {
                            bgOpacity = 1
                        }
                        // Heart zooms to ~12× its size (fills a phone screen from 100pt)
                        withAnimation(.easeInOut(duration: 1.0)) {
                            heartScale = 12
                        }
                    }
                    // Step 2: heart fades out as it fills screen
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                        withAnimation(.easeIn(duration: 0.55)) {
                            heartOpacity = 0
                        }
                    }
                    // Step 3: white fade-out
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation(.easeInOut(duration: 0.45)) {
                            whiteFadeOpacity = 1
                        }
                    }
                    // Step 4: navigate
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.35) {
                        model.startExperience()
                    }
                }
            }
        }
    }

    private func featureRow(icon: String, color: Color, text: String, isIPad: Bool) -> some View {
        HStack(alignment: .top, spacing: isIPad ? 16 : 12) {
            Image(systemName: icon)
                .font(.system(size: isIPad ? 22 : 17))
                .foregroundStyle(color)
                .frame(width: isIPad ? 32 : 24)
            Text(text)
                .font(.system(size: isIPad ? 20 : 15, weight: .regular, design: .rounded))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct HeroView_Previews: PreviewProvider {
    static var previews: some View {
        HeroView(model: AppModel())
    }
}
