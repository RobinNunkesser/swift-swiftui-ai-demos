import SwiftUI

struct RestaurantID3View: View {
    @State private var vm = RestaurantID3ViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Restaurant ID3").font(.largeTitle).bold()
                    Text("Klassifikationsbaum für die AIMA-Restaurantdaten · fits / predicts / scores")
                        .foregroundStyle(.secondary)
                }

                GroupBox("Lern-API") {
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Wurzelattribut").font(.caption).foregroundStyle(.secondary)
                            Text(vm.rootAttribute.isEmpty ? "Noch nicht trainiert" : vm.rootAttribute)
                                .font(.headline)
                        }

                        Divider().frame(height: 28)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Accuracy@12").font(.caption).foregroundStyle(.secondary)
                            Text(vm.accuracyText.isEmpty ? "-" : vm.accuracyText)
                                .font(.headline)
                        }

                        Spacer()

                        Button("Trainieren") { vm.train() }
                            .buttonStyle(.borderedProminent)
                            .disabled(vm.isTraining)
                    }
                    .padding(.vertical, 4)
                }

                if vm.isTraining {
                    HStack { Spacer(); ProgressView("Trainiert…"); Spacer() }
                }

                if vm.isTrained {
                    GroupBox("Baumgrafik") {
                        VStack(alignment: .leading, spacing: 12) {
                            if vm.graphPreviewMode == "svg", !vm.graphPreviewHTML.isEmpty {
                                GraphPreviewWebView(html: vm.graphPreviewHTML)
                                    .frame(minHeight: 320)
                            } else if !vm.dotSource.isEmpty {
                                Text("Graphviz war nicht verfügbar, daher wird der DOT-Export angezeigt.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                ScrollView {
                                    Text(vm.dotSource)
                                        .font(.system(.caption, design: .monospaced))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .textSelection(.enabled)
                                        .padding(8)
                                }
                                .frame(minHeight: 240)
                                .background(Color.primary.opacity(0.03))
                            }
                        }
                    }

                    GroupBox("Restaurant-Trainingsbeispiele") {
                        VStack(spacing: 0) {
                            HStack {
                                Text("Patrons").frame(width: 100, alignment: .leading).bold()
                                Text("Erwartet").frame(width: 80).bold()
                                Text("Vorhersage").frame(width: 90).bold()
                                Text("OK").frame(width: 30).bold()
                            }
                            .padding(.vertical, 6)
                            .background(Color.primary.opacity(0.05))

                            Divider()

                            ForEach(vm.trainingRows) { row in
                                HStack {
                                    Text(row.label).frame(width: 100, alignment: .leading)
                                    Text(row.expected).frame(width: 80)
                                    Text(row.predicted).frame(width: 90)
                                    Image(systemName: row.correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundStyle(row.correct ? .green : .red)
                                        .frame(width: 30)
                                }
                                .padding(.vertical, 5)
                                Divider()
                            }
                        }
                        .font(.system(.body, design: .monospaced))
                    }
                }
            }
            .padding(24)
        }
    }
}