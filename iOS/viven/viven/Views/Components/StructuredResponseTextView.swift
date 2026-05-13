import SwiftUI

struct StructuredResponseTextView: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            ForEach(Array(text.split(separator: "\n", omittingEmptySubsequences: false).enumerated()), id: \.offset) { _, line in
                StructuredResponseLineView(line: String(line))
            }
        }
    }
}

private struct StructuredResponseLineView: View {
    let line: String

    var body: some View {
        if let parsed = parseStructuredLine(line) {
            (
                Text(parsed.tag)
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color(hex: "C96442"))
                + Text(" ")
                + Text(parsed.body)
                    .font(.system(size: 15, weight: .regular, design: .default))
                    .foregroundStyle(Color(hex: "191817"))
            )
            .fixedSize(horizontal: false, vertical: true)
        } else {
            Text(line)
                .font(.system(size: 15, weight: .regular, design: .default))
                .foregroundStyle(Color(hex: "191817"))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func parseStructuredLine(_ line: String) -> (tag: String, body: String)? {
        guard let opening = line.firstIndex(of: "[") else { return nil }
        guard let closing = line.firstIndex(of: "]") else { return nil }
        let tag = String(line[opening...closing])
        let bodyStart = line.index(after: closing)
        let body = line[bodyStart...].trimmingCharacters(in: .whitespaces)
        return (tag, body)
    }
}
