import Foundation
import Observation

struct PerceptronExample: Identifiable {
    let id = UUID()
    let label: String
    let x0: Double
    let x1: Double
    let expected: Int
    var predicted: Int
    var correct: Bool { expected == predicted }
}

struct PerceptronError: Identifiable {
    let id = UUID()
    let epoch: Int
    let misclassified: Int
}

@Observable
final class PerceptronViewModel {
    var learningRate: Double = 0.1
    var maxEpochs: Int = 100
    var isTrained: Bool = false
    var isTraining: Bool = false

    var examples: [PerceptronExample] = []
    var errorHistory: [PerceptronError] = []
    var epochsRun: Int = 0

    let lrOptions: [(label: String, value: Double)] = [
        ("0.01", 0.01), ("0.1", 0.1), ("0.5", 0.5)
    ]
    let epochOptions: [(label: String, value: Int)] = [
        ("10", 10), ("50", 50), ("100", 100), ("200", 200)
    ]

    // AND gate (linearly separable)
    private let inputs:  [[Double]] = [[0,0],[0,1],[1,0],[1,1]]
    private let targets: [Int]      = [0,    0,    0,    1   ]
    private let labels                = ["(0,0)","(0,1)","(1,0)","(1,1)"]

    func train() {
        isTraining = true
        isTrained = false
        let lr = learningRate, ep = maxEpochs

        Task.detached { [weak self] in
            guard let self else { return }
            let p = PerceptronLearner(inputSize: 2, learningRate: lr, maxEpochs: ep)
            p.train(inputs: self.inputs, targets: self.targets)

            let exs = self.inputs.enumerated().map { idx, x in
                PerceptronExample(label: self.labels[idx],
                                  x0: x[0], x1: x[1],
                                  expected: self.targets[idx],
                                  predicted: p.predict(x))
            }
            let errs = p.errors.map { PerceptronError(epoch: $0.epoch, misclassified: $0.misclassified) }

            await MainActor.run {
                self.examples = exs
                self.errorHistory = errs
                self.epochsRun = p.epochsRun
                self.isTrained = true
                self.isTraining = false
            }
        }
    }
}
