import SwiftUI
import Charts

struct PerceptronView: View {
    @State private var vm = PerceptronViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Perceptron").font(.largeTitle).bold()
                    Text("Einschichtiger linearer Klassifikator · AND-Gate")
                        .foregroundStyle(.secondary)
                }

                GroupBox("Konfiguration") {
                    HStack(spacing: 20) {
                        Picker("Lernrate", selection: $vm.learningRate) {
                            ForEach(vm.lrOptions, id: \.value) { opt in
                                Text(opt.label).tag(opt.value)
                            }
                        }
                        .pickerStyle(.segmented).frame(maxWidth: 220)

                        Picker("Max. Epochen", selection: $vm.maxEpochs) {
                            ForEach(vm.epochOptions, id: \.value) { opt in
                                Text(opt.label).tag(opt.value)
                            }
                        }
                        .pickerStyle(.segmented).frame(maxWidth: 280)

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
                    HStack(alignment: .top, spacing: 24) {
                        // Predictions table
                        GroupBox("Vorhersagen (AND)") {
                            VStack(spacing: 0) {
                                HStack {
                                    Text("Input").frame(width: 70, alignment: .leading).bold()
                                    Text("Erwartet").frame(width: 75).bold()
                                    Text("Vorhersage").frame(width: 90).bold()
                                    Text("").frame(width: 30)
                                }
                                .padding(.vertical, 6)
                                .background(Color.primary.opacity(0.05))
                                Divider()
                                ForEach(vm.examples) { ex in
                                    HStack {
                                        Text(ex.label).frame(width: 70, alignment: .leading)
                                        Text("\(ex.expected)").frame(width: 75)
                                        Text("\(ex.predicted)").frame(width: 90)
                                        Image(systemName: ex.correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                                            .foregroundStyle(ex.correct ? .green : .red)
                                            .frame(width: 30)
                                    }
                                    .padding(.vertical, 5)
                                    Divider()
                                }
                            }
                            .font(.system(.body, design: .monospaced))
                        }
                        .frame(maxWidth: 310)

                        VStack(alignment: .leading, spacing: 16) {
                            GroupBox("Ergebnis") {
                                HStack(spacing: 32) {
                                    StatCell3(label: "Epochen bis Konvergenz", value: "\(vm.epochsRun)")
                                    StatCell3(label: "Lernrate", value: "\(vm.learningRate)")
                                }
                                .padding(.vertical, 4)
                            }

                            GroupBox("Fehler pro Epoche") {
                                Chart(vm.errorHistory) {
                                    BarMark(x: .value("Epoche", $0.epoch),
                                            y: .value("Fehler", $0.misclassified))
                                    .foregroundStyle(.orange)
                                }
                                .frame(height: 220)
                                .padding(.top, 4)
                            }
                        }
                    }
                }
            }
            .padding(24)
        }
    }
}

private struct StatCell3: View {
    let label: String
    let value: String
    var body: some View {
        VStack(spacing: 2) {
            Text(value).font(.title2).bold()
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
    }
}
