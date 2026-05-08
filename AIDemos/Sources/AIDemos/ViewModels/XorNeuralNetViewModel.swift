import Foundation
import Observation

struct XorPredictionRow: Identifiable {
    let id = UUID()
    let input: String
    let expected: Int
    let predicted: Int
    var correct: Bool { expected == predicted }
}

struct LossPoint: Identifiable {
    let id = UUID()
    let epoch: Int
    let loss: Double
}

@Observable
final class XorNeuralNetViewModel {
    var hiddenNeurons: Int = 2
    var learningRate: Double = 0.5
    var epochs: Int = 10_000

    var predictions: [XorPredictionRow] = []
    var lossHistory: [LossPoint] = []
    var accuracy: Double = 0
    var isTrained: Bool = false
    var isTraining: Bool = false

    let hiddenNeuronOptions = [2, 3, 4]
    let learningRateOptions: [(label: String, value: Double)] = [
        ("0.1", 0.1), ("0.5", 0.5), ("1.0", 1.0)
    ]
    let epochOptions: [(label: String, value: Int)] = [
        ("1 000", 1_000), ("5 000", 5_000), ("10 000", 10_000), ("50 000", 50_000)
    ]

    // XOR data
    private let inputs:  [[Double]] = [[0,0],[0,1],[1,0],[1,1]]
    private let targets: [Double]   = [0, 1, 1, 0]

    func train() {
        isTraining = true
        isTrained = false
        let h = hiddenNeurons, lr = learningRate, ep = epochs

        Task.detached { [weak self] in
            guard let self else { return }
            let mlp = MlpLearner(layers: [2, h, 1],
                                 learningRate: lr,
                                 epochs: ep,
                                 seed: 42,
                                 logEvery: max(1, ep / 50))
            mlp.train(inputs: self.inputs, targets: self.targets)

            let rows: [XorPredictionRow] = self.inputs.enumerated().map { idx, x in
                let pred = mlp.predict(x) >= 0.5 ? 1 : 0
                let exp  = Int(self.targets[idx])
                return XorPredictionRow(input: "(\(Int(x[0])), \(Int(x[1])))", expected: exp, predicted: pred)
            }
            let lp = mlp.lossHistory.map { LossPoint(epoch: $0.epoch, loss: $0.loss) }
            let acc = Double(rows.filter(\.correct).count) / Double(rows.count)

            await MainActor.run {
                self.predictions = rows
                self.lossHistory = lp
                self.accuracy = acc
                self.isTrained = true
                self.isTraining = false
            }
        }
    }
}
