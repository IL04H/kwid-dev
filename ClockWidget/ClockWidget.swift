import WidgetKit
import SwiftUI

struct ClockEntry: TimelineEntry { let date: Date }
struct ClockProvider: TimelineProvider {
    func placeholder(in context: Context) -> ClockEntry { ClockEntry(date: .now) }
    func getSnapshot(in context: Context, completion: @escaping (ClockEntry) -> Void) { completion(ClockEntry(date: .now)) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<ClockEntry>) -> Void) {
        let now = Date()
        let entries = (0..<12).map { ClockEntry(date: Calendar.current.date(byAdding: .minute, value: $0, to: now) ?? now) }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}
struct ClockWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: ClockEntry
    var body: some View {
        ZStack {
            Color.black
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 5) { Image(systemName: "clock.fill"); Text("KWID CLOCK").tracking(2) }
                    .font(.system(size: 9, weight: .bold, design: .rounded)).foregroundStyle(.white.opacity(0.55))
                Spacer(minLength: 0)
                Text(entry.date, style: .time).font(.system(size: family == .systemSmall ? 29 : 39, weight: .light, design: .rounded).monospacedDigit()).foregroundStyle(.white).minimumScaleFactor(0.65).lineLimit(1)
                if family != .systemSmall { Text(entry.date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())).font(.system(size: 12, weight: .medium, design: .rounded)).foregroundStyle(.white.opacity(0.55)) }
            }.padding(family == .systemSmall ? 13 : 17)
        }.containerBackground(.black, for: .widget)
    }
}
@main struct ClockWidgetBundle: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "KwidClockWidget", provider: ClockProvider()) { entry in ClockWidgetView(entry: entry) }
            .configurationDisplayName("Kwid Clock").description("A clean dark clock for your Home Screen.")
            .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
