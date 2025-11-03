//
//  ContentView.swift
//  Sound
//
//  Created by Ella Wang on 9/23/25.
//


//

import SwiftUI
import AudioToolbox

// Haptics + System Sounds

enum Haptics {
    static func light() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    static func error() { UINotificationFeedbackGenerator().notificationOccurred(.error) }
    static func select() { UISelectionFeedbackGenerator().selectionChanged() }
}

enum SystemSound {
    case tap, success, error
    var id: SystemSoundID {
        switch self {
        case .tap:     return 1104  // Tock
        case .success: return 1114  // Tweet Sent
        case .error:   return 1053  // Failed
        }
    }
    static func play(_ s: SystemSound) { AudioServicesPlaySystemSound(s.id) }
}

// Data models

struct Award: Identifiable {
    let id = UUID()
    let title: String
    let emoji: String
    let threshold: Int
}

struct OnboardingCard: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let emoji: String
}

// Reusable button sprite

struct SpriteButtonLabel: View {
    let text: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
            Text(text).bold()
        }
        .font(.headline)
        .padding(.horizontal, 18).padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(colors: [.blue, .purple],
                                     startPoint: .leading, endPoint: .trailing))
        )
        .foregroundStyle(.white)
        .shadow(radius: 4, y: 2)
    }
}

struct NoteSprite: View {
    var size: CGFloat = 120
    @State private var float = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.16, style: .continuous)
                .fill(LinearGradient(colors: [.yellow.opacity(0.95), .yellow.opacity(0.8)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: .black.opacity(0.12), radius: 10, y: 6)

            // face
            VStack(spacing: size * 0.06) {
                HStack(spacing: size * 0.18) {
                    Circle().fill(.black.opacity(0.9)).frame(width: size*0.12, height: size*0.12)
                    Circle().fill(.black.opacity(0.9)).frame(width: size*0.12, height: size*0.12)
                }
                .offset(y: size * 0.05)

                // smile
                ArcSmile()
                    .stroke(.black.opacity(0.9), style: StrokeStyle(lineWidth: size*0.06, lineCap: .round))
                    .frame(width: size*0.46, height: size*0.20)
            }

            // pin
            Circle()
                .fill(LinearGradient(colors: [.pink, .purple], startPoint: .top, endPoint: .bottom))
                .frame(width: size*0.22, height: size*0.22)
                .overlay(Circle().stroke(.white.opacity(0.85), lineWidth: size*0.03))
                .shadow(radius: 6, y: 3)
                .offset(y: -size*0.62)
        }
        .frame(width: size, height: size)
        .rotationEffect(.degrees(float ? 2.5 : -2.5))
        .offset(y: float ? -6 : 6)
        .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: float)
        .onAppear { float = true }
        .accessibilityHidden(true)
    }
}

struct ArcSmile: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addArc(center: CGPoint(x: rect.midX, y: rect.minY),
                 radius: rect.width * 0.5,
                 startAngle: .degrees(20),
                 endAngle: .degrees(160),
                 clockwise: false)
        return p
    }
}

// Title screen

struct TitleScreen: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [.purple.opacity(0.25), .pink.opacity(0.25)],
                           startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

            VStack(spacing: 24) {
                NoteSprite(size: 130) // NEW
                Text("The Best Notes App")
                    .font(.system(size: 36, weight: .bold))

                Text("Capture ideas. Grow streaks. ✨")
                    .foregroundColor(.secondary)

                NavigationLink {
                    OnboardingView()
                } label: {
                    SpriteButtonLabel(text: "Start Onboarding",
                                      systemImage: "arrow.right.circle.fill")
                }
                .simultaneousGesture(TapGesture().onEnded {
                    Haptics.light(); SystemSound.play(.tap)
                })

                NavigationLink {
                    LoginView()
                } label: {
                    SpriteButtonLabel(text: "Log In",
                                      systemImage: "person.crop.circle.fill")
                }
                .simultaneousGesture(TapGesture().onEnded {
                    Haptics.light(); SystemSound.play(.tap)
                })
            }
            .padding()
        }
    }
}

// Onboarding

struct OnboardingView: View {
    @State private var page = 0

    private let pages = [
        OnboardingCard(title: "Welcome to The Best Notes App",
            subtitle: "A simple, friendly space to capture ideas.", emoji: "✨"),
        OnboardingCard(title: "Stay Organized", subtitle: "Tag and color-code your notes.", emoji: "🗂️"),
        OnboardingCard(title: "Sync Everywhere", subtitle: "Your ideas on all devices.", emoji: "☁️"),
        OnboardingCard(title: "Build a Streak", subtitle: "Write a little every day.", emoji: "🔥")
    ]

    var body: some View {
        ZStack {
            LinearGradient(colors: [.mint.opacity(0.25), .blue.opacity(0.2)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()

            VStack(spacing: 24) {
                TabView(selection: $page) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, card in
                        VStack(spacing: 16) {
                            Text(card.emoji).font(.system(size: 80))
                            Text(card.title).font(.title.bold())
                            Text(card.subtitle)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .frame(maxHeight: 420)

                HStack(spacing: 12) {
                    if page > 0 {
                        Button {
                            withAnimation { page -= 1 }
                            Haptics.select(); SystemSound.play(.tap)
                        } label: {
                            SpriteButtonLabel(text: "Back",
                                              systemImage: "chevron.left.circle.fill")
                        }
                    }
                    Spacer()
                    if page < pages.count - 1 {
                        Button {
                            withAnimation { page += 1 }
                            Haptics.select(); SystemSound.play(.tap)
                        } label: {
                            SpriteButtonLabel(text: "Next",
                                              systemImage: "chevron.right.circle.fill")
                        }
                    } else {
                        NavigationLink {
                            LoginView()
                        } label: {
                            SpriteButtonLabel(text: "Get Started",
                                              systemImage: "checkmark.seal.fill")
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            Haptics.success(); SystemSound.play(.success)
                        })
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 24)
        }
        .navigationTitle("Onboarding")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Login page

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false

    private var isValid: Bool {
        email.contains("@") && password.count >= 6
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [.orange.opacity(0.22), .pink.opacity(0.22)],
                           startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.system(size: 64))
                    .foregroundStyle(.blue)

                Text("Welcome back")
                    .font(.title.bold())

                VStack(spacing: 12) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 14).fill(.thinMaterial))

                    SecureField("Password", text: $password)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 14).fill(.thinMaterial))
                }
                .padding(.horizontal)

                if showError {
                    Text("Please enter a valid email and a password with 6+ characters.")
                        .foregroundColor(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                NavigationLink {
                    HomeView()
                } label: {
                    SpriteButtonLabel(text: "Log In", systemImage: "lock.open.fill")
                }
                .simultaneousGesture(TapGesture().onEnded {
                    if isValid {
                        Haptics.success(); SystemSound.play(.success)
                    } else {
                        showError = true
                        Haptics.error(); SystemSound.play(.error)
                    }
                })
                .disabled(!isValid)
                .opacity(isValid ? 1 : 0.6)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Log In")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Note model
struct Note: Identifiable {
    let id = UUID()
    let text: String
    let date: Date
}

// Home screen

struct HomeView: View {
    @State private var showComposer = false
    @State private var notes: [Note] = []

    var body: some View {
        ZStack {
            LinearGradient(colors: [.indigo.opacity(0.2), .cyan.opacity(0.2)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Home")
                    .font(.largeTitle.bold())

                if notes.isEmpty {
                    Text("No notes yet. Tap “New Note”.")
                        .foregroundColor(.secondary)
                        .padding(.bottom, 8)
                } else {
                    List(notes) { note in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(note.text)
                            Text(note.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .listStyle(.insetGrouped)
                }

                Button { showComposer = true } label: {
                    SpriteButtonLabel(text: "New Note", systemImage: "square.and.pencil")
                }
                .sheet(isPresented: $showComposer) {
                    NoteComposer { newText in
                        notes.insert(Note(text: newText, date: Date()), at: 0)
                        Haptics.success(); SystemSound.play(.success)
                    }
                }
            }
            .padding()
        }
    }
}

// Note composer

struct NoteComposer: View {
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    var onSave: (String) -> Void

    var body: some View {
        NavigationStack {
            VStack {
                TextEditor(text: $text)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 14).fill(.thinMaterial))
                    .padding()
                Spacer()
            }
            .navigationTitle("New Note")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty {
                            onSave(trimmed)
                            dismiss()
                        } else {
                            Haptics.error(); SystemSound.play(.error)
                        }
                    }.bold()
                }
            }
        }
    }
}

// Root

struct ContentView: View {
    var body: some View {
        NavigationStack {
            TitleScreen()
        }
    }
}

#Preview {
    ContentView()
}
