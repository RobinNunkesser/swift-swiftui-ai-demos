import Foundation

/// Single-layer Perceptron (binary, threshold activation).
/// Converges on linearly separable data.
final class PerceptronLearner {
    private var weights: [Double]
    private var bias: Double
    private let lr: Double
    private let maxEpochs: Int

    private(set) var epochsRun: Int = 0
    private(set) var errors: [(epoch: Int, misclassified: Int)] = []

    init(inputSize: Int, learningRate: Double = 0.1, maxEpochs: Int = 100) {
        self.weights = Array(repeating: 0.0, count: inputSize)
        self.bias = 0.0
        self.lr = learningRate
        self.maxEpochs = maxEpochs
    }

    func train(inputs: [[Double]], targets: [Int]) {
        for epoch in 1...maxEpochs {
            var misclassified = 0
            for (x, y) in zip(inputs, targets) {
                let pred = predict(x)
                let err = y - pred
                if err != 0 {
                    misclassified += 1
                    for i in 0..<weights.count { weights[i] += lr * Double(err) * x[i] }
                    bias += lr * Double(err)
                }
            }
            errors.append((epoch, misclassified))
            epochsRun = epoch
            if misclassified == 0 { break }
        }
    }

    func predict(_ input: [Double]) -> Int {
        let z = bias + zip(weights, input).reduce(0) { $0 + $1.0 * $1.1 }
        return z >= 0 ? 1 : 0
    }
}
