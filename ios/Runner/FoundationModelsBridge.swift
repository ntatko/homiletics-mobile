import Flutter
import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

/// Bridges Apple's on-device Foundation Models framework (iOS 26.0+, Apple
/// Intelligence-eligible hardware only) to Dart so lecture transcripts can be
/// formatted without downloading a model. Every path degrades to
/// "unavailable" rather than crashing; the Dart side falls back to the
/// downloadable local model.
final class FoundationModelsBridge: NSObject {
  static let channelName = "homiletics/foundation_models"

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: registrar.messenger()
    )
    let instance = FoundationModelsBridge()
    channel.setMethodCallHandler { call, result in
      instance.handle(call, result: result)
    }
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "checkAvailability":
      result(checkAvailability())
    case "generate":
      guard let args = call.arguments as? [String: Any],
            let prompt = args["prompt"] as? String else {
        result(FlutterError(code: "bad_args", message: "Missing 'prompt' argument", details: nil))
        return
      }
      generate(
        prompt: prompt,
        instructions: args["instructions"] as? String,
        temperature: args["temperature"] as? Double,
        result: result
      )
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// Returns one of: "available", "deviceNotEligible", "appleIntelligenceNotEnabled",
  /// "modelNotReady", "unsupportedOsVersion".
  private func checkAvailability() -> String {
    #if canImport(FoundationModels)
    if #available(iOS 26.0, *) {
      switch SystemLanguageModel.default.availability {
      case .available:
        return "available"
      case .unavailable(.deviceNotEligible):
        return "deviceNotEligible"
      case .unavailable(.appleIntelligenceNotEnabled):
        return "appleIntelligenceNotEnabled"
      case .unavailable(.modelNotReady):
        return "modelNotReady"
      case .unavailable:
        return "deviceNotEligible"
      }
    }
    #endif
    return "unsupportedOsVersion"
  }

  private func generate(
    prompt: String,
    instructions: String?,
    temperature: Double?,
    result: @escaping FlutterResult
  ) {
    #if canImport(FoundationModels)
    if #available(iOS 26.0, *) {
      Task {
        do {
          // A fresh session per call: each transcript chunk is independent,
          // and carrying history would eat the ~4K-token context window.
          let session = instructions.map { LanguageModelSession(instructions: $0) }
            ?? LanguageModelSession()
          let options = GenerationOptions(temperature: temperature)
          let response = try await session.respond(to: prompt, options: options)
          result(response.content)
        } catch {
          result(FlutterError(code: "generation_failed", message: error.localizedDescription, details: nil))
        }
      }
      return
    }
    #endif
    result(FlutterError(code: "unavailable", message: "Foundation Models unavailable on this OS version", details: nil))
  }
}
