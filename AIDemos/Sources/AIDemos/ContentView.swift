import SwiftUI

enum Demo: String, CaseIterable, Identifiable {
    case xorNeuralNet = "XOR Neural Net"
    case irisKMeans   = "Iris k-Means"
    case perceptron   = "Perceptron"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .xorNeuralNet: return "brain.head.profile"
        case .irisKMeans:   return "circles.hexagongrid"
        case .perceptron:   return "network"
        }
    }

    var topic: String {
        switch self {
        case .xorNeuralNet: return "Deep Learning"
        case .irisKMeans:   return "Unsupervised Learning"
        case .perceptron:   return "Linear Classifier"
        }
    }
}

struct ContentView: View {
    @State private var selectedDemo: Demo? = .xorNeuralNet

    var body: some View {
        NavigationSplitView {
            List(Demo.allCases, selection: $selectedDemo) { demo in
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(demo.rawValue).fontWeight(.medium)
                        Text(demo.topic).font(.caption).foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: demo.icon)
                }
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 220)
            .navigationTitle("AI Demos")
        } detail: {
            switch selectedDemo {
            case .xorNeuralNet:
                XorNeuralNetView()
            case .irisKMeans:
                IrisKMeansView()
            case .perceptron:
                PerceptronView()
            case nil:
                Text("Bitte ein Demo auswählen")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
