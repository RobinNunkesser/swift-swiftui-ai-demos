import Foundation
import Observation
import SwiftUI
import SwiftAICore

struct RestaurantPredictionRow: Identifiable {
    let id = UUID()
    let label: String
    let expected: String
    let predicted: String

    var correct: Bool { expected == predicted }
}

@Observable
final class RestaurantID3ViewModel {
    var isTrained: Bool = false
    var isTraining: Bool = false
    var rootAttribute: String = ""
    var accuracyText: String = ""
    var dotSource: String = ""
    var graphPreviewHTML: String = ""
    var graphPreviewMode: String = ""
    var trainingRows: [RestaurantPredictionRow] = []

    func train() {
        isTraining = true
        isTrained = false

        Task.detached { [weak self] in
            guard let self else { return }

            var classifier = ID3Classifier()
            do {
                try classifier.fit(examples: RestaurantDataset.trainingExamples)
                let rootAttribute = classifier.rootAttribute ?? "-"
                let accuracy = String(format: "%.0f %%", classifier.score(on: RestaurantDataset.trainingExamples) * 100)
                let rows = RestaurantDataset.trainingExamples.map { example in
                    RestaurantPredictionRow(
                        label: example.attributes["patrons"] ?? "-",
                        expected: example.label,
                        predicted: classifier.predict(example.attributes) ?? "-"
                    )
                }
                let dot = classifier.decisionTree?.dotDescription(name: "RestaurantID3") ?? ""
                let (previewHTML, mode) = Self.renderGraphPreview(from: dot)

                await MainActor.run {
                    self.rootAttribute = rootAttribute
                    self.accuracyText = accuracy
                    self.dotSource = dot
                    self.graphPreviewHTML = previewHTML
                    self.graphPreviewMode = mode
                    self.trainingRows = rows
                    self.isTrained = true
                    self.isTraining = false
                }
            } catch {
                await MainActor.run {
                    self.rootAttribute = "Fehler"
                    self.accuracyText = "-"
                    self.dotSource = ""
                    self.graphPreviewHTML = ""
                    self.graphPreviewMode = ""
                    self.trainingRows = []
                    self.isTrained = false
                    self.isTraining = false
                }
            }
        }
    }

    private static func renderGraphPreview(from dotSource: String) -> (String, String) {
        guard !dotSource.isEmpty else {
            return ("", "dot")
        }

        let task = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        let tempDirectory = FileManager.default.temporaryDirectory
        let dotURL = tempDirectory.appendingPathComponent("restaurant-id3.dot")
        let svgURL = tempDirectory.appendingPathComponent("restaurant-id3.svg")

        do {
            try dotSource.write(to: dotURL, atomically: true, encoding: .utf8)
        } catch {
            return (dotSource, "dot")
        }

        task.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        task.arguments = ["dot", "-Tsvg", dotURL.path, "-o", svgURL.path]
        task.standardOutput = outputPipe
        task.standardError = errorPipe

        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            return (dotSource, "dot")
        }

        guard task.terminationStatus == 0,
              let svgData = try? Data(contentsOf: svgURL),
              var svgString = String(data: svgData, encoding: .utf8) else {
            return (dotSource, "dot")
        }

        svgString = svgString
            .replacingOccurrences(of: "<svg", with: "<svg style=\"width: 100%; height: auto;\"")

        let html = """
        <!doctype html>
        <html>
        <head>
          <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
          <style>
            body { margin: 0; background: transparent; font-family: -apple-system, BlinkMacSystemFont, sans-serif; }
            .wrap { padding: 8px; }
            svg { max-width: 100%; height: auto; }
          </style>
        </head>
        <body>
          <div class=\"wrap\">\(svgString)</div>
        </body>
        </html>
        """

        return (html, "svg")
    }
}