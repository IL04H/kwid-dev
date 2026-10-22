import SwiftUI

private enum KwidTab: String, CaseIterable {
    case home = "Home"
    case countdowns = "Countdowns"
    case settings = "Settings"

    var symbol: String {
        switch self {
        case .home: return "clock"
        case .countdowns: return "calendar.badge.clock"
        case .settings: return "slider.horizontal.3"
        }
    }
}

private struct KwidTheme: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String
    let background: Color
    let card: Color
    let accent: Color
    let secondary: Color

    static let all: [KwidTheme] = [
        .init(id: "midnight", name: "Midnight", icon: "moon.stars.fill", background: Color(red: 0.035, green: 0.04, blue: 0.07), card: Color(red: 0.09, green: 0.10, blue: 0.15), accent: Color(red: 0.68, green: 0.62, blue: 1), secondary: Color(red: 0.64, green: 0.67, blue: 0.75)),
        .init(id: "halloween", name: "Halloween", icon: "moon.fill", background: Color(red: 0.09, green: 0.035, blue: 0.13), card: Color(red: 0.17, green: 0.07, blue: 0.20), accent: Color(red: 1, green: 0.42, blue: 0.12), secondary: Color(red: 0.78, green: 0.65, blue: 0.82)),
        .init(id: "christmas", name: "Christmas", icon: "snowflake", background: Color(red: 0.035, green: 0.12, blue: 0.10), card: Color(red: 0.07, green: 0.20, blue: 0.16), accent: Color(red: 1, green: 0.35, blue: 0.36), secondary: Color(red: 0.67, green: 0.83, blue: 0.75)),
        .init(id: "snow", name: "Winter Snow", icon: "cloud.snow.fill", background: Color(red: 0.055, green: 0.12, blue: 0.20), card: Color(red: 0.10, green: 0.20, blue: 0.30), accent: Color(red: 0.48, green: 0.82, blue: 1), secondary: Color(red: 0.69, green: 0.80, blue: 0.90)),
        .init(id: "spring", name: "Spring Bloom", icon: "leaf.fill", background: Color(red: 0.12, green: 0.07, blue: 0.12), card: Color(red: 0.20, green: 0.12, blue: 0.20), accent: Color(red: 1, green: 0.52, blue: 0.70), secondary: Color(red: 0.85, green: 0.70, blue: 0.80)),
        .init(id: "ocean", name: "Deep Ocean", icon: "water.waves", background: Color(red: 0.025, green: 0.08, blue: 0.15), card: Color(red: 0.05, green: 0.15, blue: 0.23), accent: Color(red: 0.22, green: 0.78, blue: 0.91), secondary: Color(red: 0.60, green: 0.78, blue: 0.84)),
        .init(id: "galaxy", name: "Galaxy", icon: "sparkles", background: Color(red: 0.07, green: 0.035, blue: 0.16), card: Color(red: 0.13, green: 0.08, blue: 0.24), accent: Color(red: 0.75, green: 0.48, blue: 1), secondary: Color(red: 0.73, green: 0.65, blue: 0.88)),
        .init(id: "mono", name: "Black & White", icon: "circle.lefthalf.filled", background: .black, card: Color(white: 0.10), accent: .white, secondary: Color(white: 0.66))
    ]
}

private struct KwidCountdown: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var date: Date
    var emoji: String
    var note: String
}

struct ClockHomeView: View {
    @AppStorage("kwid.use24Hour") private var use24Hour = true
    @AppStorage("kwid.monochrome") private var monochrome = false
    @AppStorage("kwid.theme") private var savedTheme = "halloween"
    @AppStorage("kwid.haptics") private var haptics = true
    @State private var selectedTab: KwidTab = .home
    @State private var countdowns: [KwidCountdown] = []
    @State private var showingAddCountdown = false
    @State private var editingCountdown: KwidCountdown?
    @State private var now = Date()

    private var theme: KwidTheme {
        if monochrome { return KwidTheme.all.first(where: { $0.id == "mono" })! }
        return KwidTheme.all.first(where: { $0.id == savedTheme }) ?? KwidTheme.all[1]
    }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar
                Group {
                    switch selectedTab {
                    case .home: homePage
                    case .countdowns: countdownPage
                    case .settings: settingsPage
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                bottomBar
            }
        }
        .foregroundStyle(.white)
        .preferredColorScheme(.dark)
        .onAppear {
            loadCountdowns()
            now = Date()
        }
        .sheet(isPresented: $showingAddCountdown) {
            CountdownEditor(theme: theme, existing: nil) { item in
                countdowns.append(item)
                saveCountdowns()
            }
            .preferredColorScheme(.dark)
        }
        .sheet(item: $editingCountdown) { item in
            CountdownEditor(theme: theme, existing: item) { updated in
                if let index = countdowns.firstIndex(where: { $0.id == updated.id }) {
                    countdowns[index] = updated
                    saveCountdowns()
                }
            }
            .preferredColorScheme(.dark)
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { date in
            now = date
        }
    }

    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("KWID")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .tracking(4)
                    .foregroundStyle(theme.accent)
                Text(selectedTab.rawValue)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
            }
            Spacer()
            if theme.id == "halloween" {
                Text("🎃").font(.system(size: 31))
            } else if theme.id == "christmas" {
                Text("🎄").font(.system(size: 31))
            } else {
                Image(systemName: theme.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(theme.accent)
                    .frame(width: 46, height: 46)
                    .background(theme.card, in: RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 14)
        .padding(.bottom, 18)
    }

    private var homePage: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 30).fill(theme.card)
                    if theme.id == "halloween" {
                        HStack {
                            VStack { Text("🕸️"); Spacer(); Text("🐈‍⬛") }
                            Spacer()
                            VStack { Spacer(); Text("🕷️"); Text("🎃") }
                        }
                        .font(.system(size: 28))
                        .padding(18)
                    } else if theme.id == "christmas" {
                        HStack {
                            Text("❄️"); Spacer(); Text("🎁")
                        }.font(.system(size: 28)).padding(18)
                    } else if theme.id == "snow" {
                        HStack { Text("❄️"); Spacer(); Text("☃️") }.font(.system(size: 28)).padding(18)
                    } else if theme.id == "spring" {
                        HStack { Text("🌸"); Spacer(); Text("🌷") }.font(.system(size: 28)).padding(18)
                    } else if theme.id == "galaxy" {
                        HStack { Text("🌙"); Spacer(); Text("✨") }.font(.system(size: 28)).padding(18)
                    } else if theme.id == "ocean" {
                        HStack { Text("🌊"); Spacer(); Text("🐚") }.font(.system(size: 28)).padding(18)
                    }
                    VStack(spacing: 14) {
                        Text("YOUR LOCAL TIME")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .tracking(2.5)
                            .foregroundStyle(theme.secondary)
                        TimelineView(.periodic(from: .now, by: 1)) { context in
                            Text(context.date.formatted(use24Hour
                                ? Date.FormatStyle().hour(.twoDigits(amPM: .omitted)).minute(.twoDigits).second(.twoDigits)
                                : Date.FormatStyle().hour(.defaultDigits(amPM: .abbreviated)).minute(.twoDigits).second(.twoDigits)))
                                .font(.system(size: 43, weight: .light, design: .rounded).monospacedDigit())
                                .minimumScaleFactor(0.55)
                                .lineLimit(1)
                                .foregroundStyle(theme.accent)
                        }
                        Text(Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(theme.secondary)
                        Button {
                            use24Hour.toggle()
                            tap()
                        } label: {
                            Text(use24Hour ? "24-HOUR FORMAT  ↗" : "12-HOUR FORMAT  ↗")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(1)
                                .foregroundStyle(theme.accent)
                                .padding(.horizontal, 14).padding(.vertical, 9)
                                .background(theme.background.opacity(0.7), in: Capsule())
                        }
                    }
                    .padding(.vertical, 32)
                }
                .frame(minHeight: 250)

                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("COUNTING DOWN TO")
                            .font(.system(size: 10, weight: .bold)).tracking(2).foregroundStyle(theme.secondary)
                        Text("Your next big moment")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                    }
                    Spacer()
                    Button { selectedTab = .countdowns; tap() } label: {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(theme.background)
                            .frame(width: 42, height: 42)
                            .background(theme.accent, in: Circle())
                    }
                }
                if let next = countdowns.filter({ $0.date > now }).sorted(by: { $0.date < $1.date }).first {
                    countdownCard(next)
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("✨").font(.system(size: 29))
                        Text("Something to look forward to")
                            .font(.system(size: 17, weight: .bold))
                        Text("Add a birthday, holiday, trip or any date that matters to you.")
                            .font(.system(size: 13)).foregroundStyle(theme.secondary)
                        Button { showingAddCountdown = true; tap() } label: {
                            Label("Create countdown", systemImage: "plus")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(theme.background)
                                .padding(.horizontal, 16).padding(.vertical, 12)
                                .background(theme.accent, in: Capsule())
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(theme.card, in: RoundedRectangle(cornerRadius: 24))
                }

                Text("YOUR VIBE")
                    .font(.system(size: 10, weight: .bold)).tracking(2).foregroundStyle(theme.secondary)
                HStack(spacing: 10) {
                    themeShortcut("Halloween", emoji: "🎃", id: "halloween")
                    themeShortcut("Christmas", emoji: "🎄", id: "christmas")
                    themeShortcut("Galaxy", emoji: "🌌", id: "galaxy")
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }

    private func themeShortcut(_ title: String, emoji: String, id: String) -> some View {
        Button {
            savedTheme = id
            monochrome = false
            tap()
        } label: {
            VStack(spacing: 9) {
                Text(emoji).font(.system(size: 26))
                Text(title).font(.system(size: 11, weight: .semibold)).lineLimit(1)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 15)
            .background(theme.card, in: RoundedRectangle(cornerRadius: 19))
            .overlay(RoundedRectangle(cornerRadius: 19).stroke(savedTheme == id && !monochrome ? theme.accent.opacity(0.7) : .clear, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var countdownPage: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(countdowns.count) MOMENTS SAVED")
                        .font(.system(size: 10, weight: .bold)).tracking(2).foregroundStyle(theme.secondary)
                    Text("Make time exciting.")
                        .font(.system(size: 16, weight: .medium)).foregroundStyle(theme.secondary)
                }
                Spacer()
                Button { showingAddCountdown = true; tap() } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(theme.background)
                        .frame(width: 48, height: 48)
                        .background(theme.accent, in: Circle())
                }
            }
            .padding(.horizontal, 20).padding(.bottom, 16)

            if countdowns.isEmpty {
                Spacer()
                Text("📅").font(.system(size: 52))
                Text("Nothing on the horizon")
                    .font(.system(size: 19, weight: .bold))
                    .padding(.top, 12)
                Text("Create a countdown to your next big day.")
                    .font(.system(size: 13)).foregroundStyle(theme.secondary)
                    .padding(.top, 4)
                Button { showingAddCountdown = true } label: {
                    Label("Add countdown", systemImage: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .padding(.horizontal, 20).padding(.vertical, 13)
                        .background(theme.accent, in: Capsule())
                        .foregroundStyle(theme.background)
                }.padding(.top, 18)
                Spacer()
            } else {
                List {
                    ForEach(countdowns.sorted(by: { $0.date < $1.date })) { item in
                        countdownCard(item)
                            .listRowInsets(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    countdowns.removeAll { $0.id == item.id }
                                    saveCountdowns()
                                } label: { Label("Delete", systemImage: "trash") }
                                Button { editingCountdown = item } label: { Label("Edit", systemImage: "pencil") }
                                    .tint(theme.accent)
                            }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }

    private func countdownCard(_ item: KwidCountdown) -> some View {
        let remaining = max(0, Int(item.date.timeIntervalSince(now)))
        let days = remaining / 86400
        let hours = (remaining % 86400) / 3600
        let minutes = (remaining % 3600) / 60
        let seconds = remaining % 60
        return HStack(spacing: 14) {
            Text(item.emoji).font(.system(size: 29))
                .frame(width: 58, height: 62)
                .background(theme.background.opacity(0.7), in: RoundedRectangle(cornerRadius: 18))
            VStack(alignment: .leading, spacing: 5) {
                Text(item.title).font(.system(size: 16, weight: .bold)).lineLimit(1)
                Text(item.date.formatted(.dateTime.month(.abbreviated).day().year()))
                    .font(.system(size: 11, weight: .medium)).foregroundStyle(theme.secondary)
                if !item.note.isEmpty {
                    Text(item.note).font(.system(size: 11)).foregroundStyle(theme.secondary).lineLimit(1)
                }
            }
            Spacer(minLength: 4)
            VStack(alignment: .trailing, spacing: 4) {
                Text(item.date <= now ? "TODAY" : "\(days)d \(hours)h")
                    .font(.system(size: 17, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundStyle(theme.accent)
                Text(item.date <= now ? "It's here!" : String(format: "%02dm %02ds", minutes, seconds))
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(theme.secondary)
            }
        }
        .padding(14)
        .background(theme.card, in: RoundedRectangle(cornerRadius: 22))
        .contentShape(Rectangle())
        .onTapGesture { editingCountdown = item }
    }

    private var settingsPage: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 7) {
                    Text("MAKE IT YOURS")
                        .font(.system(size: 10, weight: .bold)).tracking(2).foregroundStyle(theme.secondary)
                    Text("Your clock, your rules.")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                }
                VStack(alignment: .leading, spacing: 14) {
                    Text("APPEARANCE").font(.system(size: 10, weight: .bold)).tracking(2).foregroundStyle(theme.secondary)
                    Toggle(isOn: $monochrome) {
                        Label {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Black & white").font(.system(size: 15, weight: .semibold))
                                Text("Minimal monochrome look").font(.system(size: 11)).foregroundStyle(theme.secondary)
                            }
                        } icon: { Image(systemName: "circle.lefthalf.filled").foregroundStyle(theme.accent) }
                    }.tint(theme.accent).onChange(of: monochrome) { _, _ in tap() }
                }
                .padding(18).background(theme.card, in: RoundedRectangle(cornerRadius: 22))

                VStack(alignment: .leading, spacing: 14) {
                    Text("THEME GALLERY").font(.system(size: 10, weight: .bold)).tracking(2).foregroundStyle(theme.secondary)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 11) {
                        ForEach(KwidTheme.all.filter { $0.id != "mono" }) { option in
                            Button {
                                savedTheme = option.id
                                monochrome = false
                                tap()
                            } label: {
                                VStack(alignment: .leading, spacing: 13) {
                                    HStack {
                                        Image(systemName: option.icon).font(.system(size: 18, weight: .semibold))
                                        Spacer()
                                        if savedTheme == option.id && !monochrome {
                                            Image(systemName: "checkmark.circle.fill")
                                        }
                                    }.foregroundStyle(option.accent)
                                    Text(option.name).font(.system(size: 14, weight: .bold))
                                    RoundedRectangle(cornerRadius: 3).fill(option.accent).frame(height: 4)
                                }
                                .padding(15).frame(maxWidth: .infinity, alignment: .leading)
                                .background(option.card, in: RoundedRectangle(cornerRadius: 19))
                                .overlay(RoundedRectangle(cornerRadius: 19).stroke(savedTheme == option.id && !monochrome ? option.accent : .clear, lineWidth: 1.5))
                            }.buttonStyle(.plain)
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 15) {
                    Text("CLOCK").font(.system(size: 10, weight: .bold)).tracking(2).foregroundStyle(theme.secondary)
                    settingRow(icon: "clock", title: "24-hour time", subtitle: "Use 18:45 instead of 6:45 PM") {
                        Toggle("", isOn: $use24Hour).labelsHidden().tint(theme.accent).onChange(of: use24Hour) { _, _ in tap() }
                    }
                    Divider().overlay(theme.secondary.opacity(0.2))
                    settingRow(icon: "hand.tap", title: "Haptic feedback", subtitle: "Vibration on app controls") {
                        Toggle("", isOn: $haptics).labelsHidden().tint(theme.accent)
                    }
                }
                .padding(18).background(theme.card, in: RoundedRectangle(cornerRadius: 22))

                VStack(alignment: .leading, spacing: 8) {
                    Text("KWID CLOCK").font(.system(size: 11, weight: .black)).tracking(3).foregroundStyle(theme.accent)
                    Text("A little more magic in every moment.")
                        .font(.system(size: 12)).foregroundStyle(theme.secondary)
                    Text("Your countdowns stay saved on this iPhone.")
                        .font(.system(size: 11)).foregroundStyle(theme.secondary)
                }.padding(.horizontal, 3).padding(.bottom, 18)
            }
            .padding(.horizontal, 20)
        }
    }

    private func settingRow<Accessory: View>(icon: String, title: String, subtitle: String, @ViewBuilder accessory: () -> Accessory) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.system(size: 16)).foregroundStyle(theme.accent).frame(width: 27)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.system(size: 14, weight: .semibold))
                Text(subtitle).font(.system(size: 11)).foregroundStyle(theme.secondary)
            }
            Spacer()
            accessory()
        }
    }

    private var bottomBar: some View {
        HStack(spacing: 0) {
            ForEach(KwidTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.18)) { selectedTab = tab }
                    tap()
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: tab.symbol).font(.system(size: 19, weight: selectedTab == tab ? .semibold : .regular))
                        Text(tab.rawValue).font(.system(size: 10, weight: selectedTab == tab ? .bold : .medium))
                    }
                    .foregroundStyle(selectedTab == tab ? theme.accent : theme.secondary)
                    .frame(maxWidth: .infinity).padding(.top, 13).padding(.bottom, 8)
                    .contentShape(Rectangle())
                }.buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .background(theme.card.opacity(0.95))
        .overlay(alignment: .top) { Rectangle().fill(theme.secondary.opacity(0.15)).frame(height: 1) }
    }

    private func tap() {
        guard haptics else { return }
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }

    private func loadCountdowns() {
        guard let data = UserDefaults.standard.data(forKey: "kwid.countdowns"),
              let saved = try? JSONDecoder().decode([KwidCountdown].self, from: data) else { return }
        countdowns = saved
    }

    private func saveCountdowns() {
        guard let data = try? JSONEncoder().encode(countdowns) else { return }
        UserDefaults.standard.set(data, forKey: "kwid.countdowns")
    }
}

private struct CountdownEditor: View {
    let theme: KwidTheme
    let existing: KwidCountdown?
    let onSave: (KwidCountdown) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var date = Calendar.current.date(byAdding: .day, value: 7, to: .now) ?? .now
    @State private var emoji = "🎃"
    @State private var note = ""

    private let emojis = ["🎃", "👻", "🐈‍⬛", "🕷️", "🦇", "🎄", "🎁", "❄️", "🎂", "🎉", "❤️", "✈️", "🎓", "🌙", "✨", "🌸", "🏖️", "🎮"]

    var body: some View {
        NavigationStack {
            ZStack {
                theme.background.ignoresSafeArea()
                Form {
                    Section("YOUR EVENT") {
                        TextField("Name your countdown", text: $title)
                        DatePicker("Date and time", selection: $date, in: Date.distantPast..., displayedComponents: [.date, .hourAndMinute])
                        TextField("Add a note (optional)", text: $note)
                    }
                    Section("PICK AN ICON") {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                            ForEach(emojis, id: \.self) { symbol in
                                Button { emoji = symbol } label: {
                                    Text(symbol).font(.system(size: 27))
                                        .frame(maxWidth: .infinity).padding(.vertical, 8)
                                        .background(emoji == symbol ? theme.accent.opacity(0.25) : theme.card, in: RoundedRectangle(cornerRadius: 12))
                                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(emoji == symbol ? theme.accent : .clear, lineWidth: 1.5))
                                }.buttonStyle(.plain)
                            }
                        }.listRowBackground(theme.card)
                    }
                    Section {
                        Text("Your countdown is saved locally on this iPhone.")
                            .font(.system(size: 12)).foregroundStyle(theme.secondary)
                    }
                }
                .scrollContentBackground(.hidden)
                .tint(theme.accent)
            }
            .navigationTitle(existing == nil ? "New countdown" : "Edit countdown")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.foregroundStyle(theme.accent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let item = KwidCountdown(id: existing?.id ?? UUID(), title: title.trimmingCharacters(in: .whitespacesAndNewlines), date: date, emoji: emoji, note: note.trimmingCharacters(in: .whitespacesAndNewlines))
                        onSave(item)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .foregroundStyle(theme.accent)
                }
            }
            .onAppear {
                if let existing {
                    title = existing.title
                    date = existing.date
                    emoji = existing.emoji
                    note = existing.note
                }
            }
        }
    }
}
