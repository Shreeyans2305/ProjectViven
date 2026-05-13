import Foundation
import SwiftUI

struct VIVENResponse: Identifiable, Hashable, Sendable {
    let id = UUID()
    let threatLevel: ThreatLevel
    let assess: String
    let priority: String
    let steps: [String]
    let watchFor: [String]

    init(
        threatLevel: ThreatLevel,
        assess: String,
        priority: String,
        steps: [String],
        watchFor: [String]
    ) {
        self.threatLevel = threatLevel
        self.assess = assess
        self.priority = priority
        self.steps = steps
        self.watchFor = watchFor
    }

    init(parsedFrom rawOutput: String, defaultThreatLevel: ThreatLevel = .low) {
        let parsedAssess = Self.sectionValue(for: "ASSESS", in: rawOutput)
        let parsedPriority = Self.sectionValue(for: "PRIORITY", in: rawOutput)
        let parsedSteps = Self.listItems(from: Self.sectionValue(for: "STEPS", in: rawOutput))
        let parsedWatchFor = Self.listItems(from: Self.sectionValue(for: "WATCH FOR", in: rawOutput))

        self.init(
            threatLevel: defaultThreatLevel,
            assess: parsedAssess.isEmpty ? rawOutput.trimmingCharacters(in: .whitespacesAndNewlines) : parsedAssess,
            priority: parsedPriority.isEmpty ? "Stay alert and continue monitoring conditions." : parsedPriority,
            steps: parsedSteps,
            watchFor: parsedWatchFor
        )
    }

    var structuredDisplayText: String {
        let stepText = steps.enumerated().map { index, step in
            "\(index + 1). \(step)"
        }.joined(separator: "  ")

        let watchText = watchFor.joined(separator: "  ")

        return [
            "[ASSESS] \(assess)",
            "[PRIORITY] \(priority)",
            "[STEPS] \(stepText)",
            "[WATCH FOR] \(watchText)"
        ]
        .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).hasSuffix("]") }
        .joined(separator: "\n")
    }

    func formattedText() -> AttributedString {
        var output = AttributedString()
        let lines = structuredDisplayText.split(separator: "\n", omittingEmptySubsequences: false)

        for (index, rawLine) in lines.enumerated() {
            let line = String(rawLine)
            if let parsed = Self.lineComponents(from: line) {
                var tag = AttributedString(parsed.tag)
                tag.font = .system(size: 12, weight: .semibold, design: .monospaced)
                tag.foregroundColor = Color(hex: "F5A623")

                var body = AttributedString(parsed.body)
                body.font = .system(size: 15, weight: .regular, design: .default)
                body.foregroundColor = .white

                output += tag
                output += AttributedString(" ")
                output += body
            } else {
                var lineText = AttributedString(line)
                lineText.font = .system(size: 15, weight: .regular, design: .default)
                lineText.foregroundColor = .white
                output += lineText
            }

            if index < lines.count - 1 {
                output += AttributedString("\n")
            }
        }

        return output
    }

    private static func lineComponents(from line: String) -> (tag: String, body: String)? {
        guard let start = line.firstIndex(of: "[") else { return nil }
        guard let end = line.firstIndex(of: "]") else { return nil }
        let tag = String(line[start...end])
        let bodyStart = line.index(after: end)
        let body = String(line[bodyStart...]).trimmingCharacters(in: .whitespaces)
        return (tag, body)
    }

    private static func sectionValue(for tag: String, in raw: String) -> String {
        let searchTag = "[\(tag)]"
        guard let tagRange = raw.range(of: searchTag, options: [.caseInsensitive]) else {
            return ""
        }

        let tags = ["[ASSESS]", "[PRIORITY]", "[STEPS]", "[WATCH FOR]"]
        var endIndex = raw.endIndex
        for candidate in tags where candidate != searchTag {
            if let candidateRange = raw.range(of: candidate, options: [.caseInsensitive], range: tagRange.upperBound..<raw.endIndex) {
                endIndex = candidateRange.lowerBound
                break
            }
        }

        let extracted = String(raw[tagRange.upperBound..<endIndex])
        return extracted.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func listItems(from raw: String) -> [String] {
        guard !raw.isEmpty else { return [] }

        let separators = CharacterSet(charactersIn: "\n;•")
        let chunks = raw.components(separatedBy: separators)
            .flatMap { chunk in
                chunk.components(separatedBy: "  ")
            }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let cleaned = chunks.map { chunk -> String in
            var result = chunk
            if let regex = try? NSRegularExpression(pattern: "^\\d+[\\.\\)]\\s*") {
                let range = NSRange(result.startIndex..., in: result)
                result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "")
            }
            return result.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return cleaned.isEmpty ? [raw.trimmingCharacters(in: .whitespacesAndNewlines)] : cleaned
    }
}
