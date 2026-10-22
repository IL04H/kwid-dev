import SwiftUI

struct ClockHomeView: View {
    @State private var use24Hour = true

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                    Text("KWID CLOCK")
                        .tracking(3)
                    Spacer()
                }
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.75))

                Spacer()

                VStack(spacing: 12) {
                    Text("LOCAL TIME")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .tracking(2)
                        .foregroundStyle(.white.opacity(0.4))

                    TimelineView(.periodic(from: .now, by: 1)) { context in
                        VStack(spacing: 12) {
                            Text(context.date.formatted(
                                use24Hour
                                ? Date.FormatStyle().hour(.twoDigits(amPM: .omitted)).minute(.twoDigits).second(.twoDigits)
                                : Date.FormatStyle().hour(.defaultDigits(amPM: .abbreviated)).minute(.twoDigits).second(.twoDigits)
                            ))
                            .font(.system(size: 48, weight: .light, design: .rounded).monospacedDigit())
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                            .foregroundStyle(.white)
                            .contentTransition(.numericText())

                            Text(context.date.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.55))
                        }
                    }
                }
                .frame(maxWidth: .infinity)

                Spacer()

                VStack(alignment: .leading, spacing: 14) {
                    Text("DISPLAY")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(.white.opacity(0.4))

                    Toggle(isOn: $use24Hour) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("24-hour time")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.white)
                            Text(use24Hour ? "18:45:32" : "6:45:32 PM")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.4))
                        }
                    }
                    .tint(.white.opacity(0.7))
                }
                .padding(20)
                .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 22))
            }
            .padding(24)
        }
        .preferredColorScheme(.dark)
    }
}
