import SwiftUI
import Charts

struct XorNeuralNetView: View {
    @State private var vm = XorNeuralNetViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("XOR Neural Net").font(.largeTitle).bold()
                    Text("Multi-layer perceptron · batch backpropagation · sigmoid activation")
                        .foregroundStyle(.secondary)
                }

                // Config
                GroupBox("Konfiguration") {
                    HStack(spacing: 20) {
                        Picker("Hidden Neurons", selection: $vm.hiddenNeurons) {
                            ForEach(vm.hiddenNeuronOptions, id: \.self) { Text("\($0)").tag($0) }
                        }
                        .pickerStyle(.segmented).frame(maxWidth: 200)

                        Picker("Lernrate", selection: $vm.learningRate) {
                            ForEach(vm.learningRateOptions, id: \.value) { opt in
                                Text(opt.label).tag(opt.value)
                            }
                        }
                        .pickerStyle(.segmented).frame(maxWidth: 220)

                        Picker("Epochen", selection: $vm.epochs) {
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
                        // Predictions
                        GroupBox("Vorhersagen") {
                            VStack(spacing: 0) {
                                HStack {
                                    Text("Input").frame(width: 80, alignment: .leading).bold()
                                    Text("Erwartet").frame(width: 80).bold()
                                    Text("Vorhersage").frame(width: 80).bold()
                                    Text("").frame(width: 30)
                                }
                                .padding(.vertical, 6)
                                .background(Color.primary.opacity(0.05))
                                Divider()
                                ForEach(vm.predictions) { row in
                                    HStack {
                                        Text(row.input).frame(width: 80, alignment: .leading)
                                        Text("\(row.expected)").frame(width: 80)
                                        Text("\(row.predicted)").frame(width: 80)
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
                        .frame(maxWidth: 320)

                        // Stats + Loss chart
                        VStack(alignment: .leading, spacing: 16) {
                            GroupBox("Ergebnis") {
                                HStack(spacing: 32) {
                                    StatCell(label: "Architektur",
                                             value: "2–\(vm.hiddenNeurons)–1")
                                    StatCell(label: "Epochen",
                                             value: "\(vm.epochs)")
                                    StatCell(label: "Lernrate",
                                             value: "\(vm.learningRate)")
                                    StatCell(label: "Genauigkeit",
                                             value: String(format: "%.0f %%", vm.accuracy * 100))
                                }
                                .padding(.vertical, 4)
                            }

                            GroupBox("Lernkurve (MSE)") {
                                Chart(vm.lossHistory) {
                                    LineMark(x: .value("Epoche", $0.epoch),
                                             y: .value("Loss", $0.loss))
                                    .foregroundStyle(.blue)
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

private struct StatCell: View {
    let label: String
    let value: String
    var body: some View {
        VStack(spacing: 2) {
            Text(value).font(.title2).bold()
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
    }
}
