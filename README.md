# swift-swiftui-ai-demos

SwiftUI macOS desktop app — interactive AI/ML demos for lectures and validation.

## Purpose

- **Live lecture demos**: native macOS performance, instant startup, no browser load time
- **Validation companion**: runs the same algorithms independently of [nuget-ai](https://github.com/Italbytz/nuget-ai), used to cross-check results
- **Experiment sandbox**: native Swift Charts, animations, and UI that are impractical in WASM/Blazor

## Covered demos

| # | Demo | Topic |
|---|------|-------|
| 1 | XOR neural net | MLP, batch backpropagation |
| 2 | Iris k-Means | Unsupervised clustering |
| 3 | Perceptron | Single-layer linear classifier |

## Requirements

- macOS 14 Sonoma or later
- Xcode 16 or later

## Open in Xcode

```sh
open AIDemos.xcodeproj
```

## Build and start on macOS

```sh
make macos-start
```

Additional targets:

```sh
make macos-build
make clean
```

## Related

- [nuget-ai](https://github.com/Italbytz/nuget-ai) — C# / Blazor WASM counterpart
- [KI lecture slides](https://github.com/RobinNunkesser/md) — `md/quarto/ki/`
