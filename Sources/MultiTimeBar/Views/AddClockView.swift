import SwiftUI

struct AddClockView: View {
    @EnvironmentObject private var clockStore: ClockStore

    @State private var query: String = ""
    @State private var selection: CityEntry?

    private var results: [CityEntry] {
        Array(TimezoneDatabase.search(query).prefix(8))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Add a Clock")
                    .font(.subheadline).bold()
                    .foregroundStyle(.secondary)
                Spacer()
            }
            HStack {
                TextField("Enter city", text: $query)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(addSelected)
                Button("Add") {
                    addSelected()
                }
                .disabled(results.isEmpty)
            }

            if !results.isEmpty {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(results) { entry in
                            resultRow(entry)
                        }
                    }
                }
                .frame(maxHeight: 140)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(nsColor: .textBackgroundColor).opacity(0.5))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(Color.secondary.opacity(0.2))
                )
            }
        }
    }

    private func resultRow(_ entry: CityEntry) -> some View {
        Button {
            selection = entry
            addSelected()
        } label: {
            HStack(spacing: 8) {
                Text(FlagEmoji.from(countryCode: entry.countryCode))
                VStack(alignment: .leading, spacing: 1) {
                    Text(entry.name)
                    Text("\(entry.country) · \(entry.timezoneIdentifier)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func addSelected() {
        let entry = selection ?? results.first
        guard let entry else { return }
        clockStore.add(entry)
        query = ""
        selection = nil
    }
}
