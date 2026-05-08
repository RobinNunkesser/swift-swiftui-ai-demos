import Foundation

/// Minimal multi-layer perceptron trained with batch backpropagation.
/// Sigmoid activation, MSE loss. No external dependencies.
final class MlpLearner {

    // weights[l][j][k] — weight from neuron k in layer l-1 to neuron j in layer l
    private var w: [[[Double]]]
    private var b: [[Double]]
    private let layers: [Int]
    private let lr: Double
    private let epochs: Int
    private let logEvery: Int
    private var rng: SeededRandom

    private(set) var lossHistory: [(epoch: Int, loss: Double)] = []

    init(layers: [Int],
         learningRate: Double = 0.5,
         epochs: Int = 10_000,
         seed: UInt64 = 42,
         logEvery: Int = 1_000) {
        self.layers = layers
        self.lr = learningRate
        self.epochs = epochs
        self.logEvery = logEvery > 0 ? logEvery : epochs
        self.rng = SeededRandom(seed: seed)

        let L = layers.count
        w = Array(repeating: [], count: L)
        b = Array(repeating: [], count: L)

        // Layer 0 is the input — no weights.
        for l in 1..<L {
            let nIn  = layers[l - 1]
            let nOut = layers[l]
            let limit = (6.0 / Double(nIn + nOut)).squareRoot()
            w[l] = (0..<nOut).map { _ in
                (0..<nIn).map { _ in (rng.nextDouble() * 2 - 1) * limit }
            }
            b[l] = Array(repeating: 0.0, count: nOut)
        }
    }

    // MARK: Forward

    private func forward(_ input: [Double]) -> [[Double]] {
        let L = layers.count
        var a = [[Double]](repeating: [], count: L)
        a[0] = input
        for l in 1..<L {
            a[l] = (0..<layers[l]).map { j in
                let z = b[l][j] + zip(w[l][j], a[l-1]).reduce(0) { $0 + $1.0 * $1.1 }
                return sigmoid(z)
            }
        }
        return a
    }

    // MARK: Training

    func train(inputs: [[Double]], targets: [Double]) {
        let N = inputs.count
        let L = layers.count

        for epoch in 1...epochs {
            var dW = w.map { layer in layer.map { row in Array(repeating: 0.0, count: row.count) } }
            var dB = b.map { Array(repeating: 0.0, count: $0.count) }
            var totalLoss = 0.0

            for n in 0..<N {
                let a = forward(inputs[n])
                var t = Array(repeating: 0.0, count: layers[L-1])
                t[0] = targets[n]

                for j in 0..<layers[L-1] {
                    totalLoss += 0.5 * pow(a[L-1][j] - t[j], 2)
                }

                var delta = [[Double]](repeating: [], count: L)
                for l in 0..<L { delta[l] = Array(repeating: 0.0, count: layers[l]) }

                // Output layer
                for j in 0..<layers[L-1] {
                    delta[L-1][j] = (a[L-1][j] - t[j]) * sigmoidDerivative(a[L-1][j])
                }
                // Hidden layers
                for l in stride(from: L-2, through: 1, by: -1) {
                    for k in 0..<layers[l] {
                        let sum = (0..<layers[l+1]).reduce(0.0) { $0 + w[l+1][$1][k] * delta[l+1][$1] }
                        delta[l][k] = sum * sigmoidDerivative(a[l][k])
                    }
                }
                // Accumulate
                for l in 1..<L {
                    for j in 0..<layers[l] {
                        dB[l][j] += delta[l][j]
                        for k in 0..<layers[l-1] {
                            dW[l][j][k] += delta[l][j] * a[l-1][k]
                        }
                    }
                }
            }

            // Apply
            for l in 1..<L {
                for j in 0..<layers[l] {
                    b[l][j] -= lr * dB[l][j] / Double(N)
                    for k in 0..<layers[l-1] {
                        w[l][j][k] -= lr * dW[l][j][k] / Double(N)
                    }
                }
            }

            if epoch % logEvery == 0 || epoch == epochs {
                lossHistory.append((epoch, totalLoss / Double(N)))
            }
        }
    }

    func predict(_ input: [Double]) -> Double {
        forward(input)[layers.count - 1][0]
    }

    // MARK: Helpers

    private func sigmoid(_ x: Double) -> Double { 1.0 / (1.0 + exp(-x)) }
    private func sigmoidDerivative(_ s: Double) -> Double { s * (1.0 - s) }
}

// MARK: - Seeded RNG (xorshift64)

private struct SeededRandom {
    private var state: UInt64
    init(seed: UInt64) { state = seed == 0 ? 1 : seed }

    mutating func nextDouble() -> Double {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return Double(state) / Double(UInt64.max)
    }
}
