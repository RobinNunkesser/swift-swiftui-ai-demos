import SwiftUI
import Charts

struct IrisKMeansView: View {
    @State private var vm = IrisKMeansViewModel()

    private let clusterColors: [Color] = [.blue, .orange, .green, .purple]
    private let labelNames = ["Setosa", "Versicolor", "Virginica"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Iris k-Means").font(.largeTitle).bold()
                    Text("Unüberwachtes Clustering · Sepal Length × Sepal Width")
                        .foregroundStyle(.secondary)
                }

                GroupBox("Konfiguration") {
                    HStack(spacing: 20) {
                        Picker("k", selection: $vm.k) {
                            ForEach(vm.kOptions, id: \.self) { Text("k = \($0)").tag($0) }
                        }
                        .pickerStyle(.segmented).frame(maxWidth: 200)

                        Spacer()

                        Button("Clustern") { vm.train() }
                            .buttonStyle(.borderedProminent)
                            .disabled(vm.isTraining)
                    }
                    .padding(.vertical, 4)
                }

                if vm.isTraining {
                    HStack { Spacer(); ProgressView("Clustert…"); Spacer() }
                }

                if vm.isTrained {
                    HStack(alignment: .top, spacing: 24) {
                        GroupBox("Scatter Plot") {
                            Chart(vm.points) { p in
                                PointMark(x: .value("Sepal Length", p.sepalLength),
                                          y: .value("Sepal Width",  p.sepalWidth))
                                .foregroundStyle(clusterColors[p.cluster % clusterColors.count])
                                .symbolSize(60)
                                .symbol(by: .value("Cluster", "Cluster \(p.cluster)"))
                            }
                            .chartXAxisLabel("Sepal Length (cm)")
                            .chartYAxisLabel("Sepal Width (cm)")
                            .frame(height: 340)
                            .padding(.top, 4)
                        }

                        VStack(alignment: .leading, spacing: 16) {
                            GroupBox("Ergebnis") {
                                VStack(spacing: 8) {
                                    StatCell2(label: "k", value: "\(vm.k)")
                                    StatCell2(label: "Iterationen", value: "\(vm.iterationsRun)")
                                }
                                .padding(.vertical, 4)
                            }
                            GroupBox("Legende (Wahrheit)") {
                                ForEach(Array(labelNames.enumerated()), id: \.offset) { idx, name in
                                    HStack {
                                        Circle()
                                            .fill(clusterColors[idx])
                                            .frame(width: 10, height: 10)
                                        Text(name)
                                    }
                                    .padding(.vertical, 2)
                                }
                                Text("Cluster ≠ Labels — k-Means kennt keine Klassen")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 4)
                            }
                        }
                        .frame(maxWidth: 200)
                    }
                }
            }
            .padding(24)
        }
    }
}

private struct StatCell2: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label).foregroundStyle(.secondary)
            Spacer()
            Text(value).bold()
        }
    }
}
