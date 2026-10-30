import Flutter
import UIKit

/// Tells Dart about the iPhone Duo's fold and vertical bar (iOS 27.1+),
/// which Flutter doesn't report itself. See HingeFeatures in
/// lib/common/fold_posture.dart for the Dart side and the event format.
///
/// * The fold is the view's division region (`reservedRegions(kind:
///   .division)`), and `UIHingeInteraction` says whether the device is half
///   open (where the editor splits its panes at the fold).
/// * The vertical bar is where iOS moves an app's bars on the Duo (the side
///   of the outer display, and the inner display in landscape).
///   `verticalBarEdge` says which side; a bar layout region says where a
///   bar of our width goes, so the app's own buttons can sit there.
final class HingeBridge: NSObject, FlutterStreamHandler {
  /// How wide the app's vertical bar is, in points (a 44pt button plus
  /// margins). Matches VerticalBar.extent in Dart.
  static let barExtent: CGFloat = 60

  private static var instance: HingeBridge?

  private let registrar: FlutterPluginRegistrar
  private var sink: FlutterEventSink?
  private var lastEvent: NSDictionary?
  private var detach: (@MainActor () -> Void)?

  private init(registrar: FlutterPluginRegistrar) {
    self.registrar = registrar
  }

  static func register(with registrar: FlutterPluginRegistrar) {
    let bridge = HingeBridge(registrar: registrar)
    instance = bridge
    FlutterMethodChannel(name: "homiletics/hinge", binaryMessenger: registrar.messenger())
      .setMethodCallHandler { call, result in
        guard call.method == "isSupported" else {
          result(FlutterMethodNotImplemented)
          return
        }
        if #available(iOS 27.1, *) {
          result(true)
        } else {
          result(false)
        }
      }
    FlutterEventChannel(name: "homiletics/hinge/events", binaryMessenger: registrar.messenger())
      .setStreamHandler(bridge)
  }

  func onListen(withArguments _: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    sink = events
    lastEvent = nil
    if #available(iOS 27.1, *) {
      // Channel handlers run on the main thread.
      MainActor.assumeIsolated { attach() }
    } else {
      events(nil)
    }
    return nil
  }

  func onCancel(withArguments _: Any?) -> FlutterError? {
    if let detach {
      MainActor.assumeIsolated { detach() }
    }
    detach = nil
    sink = nil
    return nil
  }

  @available(iOS 27.1, *)
  @MainActor
  private func attach() {
    guard detach == nil else { return }
    guard let view = registrar.viewController?.view else {
      // No Flutter view yet: nothing to report until Dart listens again.
      sink?(nil)
      return
    }
    var hinge: UIHinge?
    let probe = LayoutProbe(frame: view.bounds)
    let barGuides: [UIVerticalBarEdge: UILayoutGuide] = [
      .leading: view.layoutGuide(for: .bar(onEdge: NSDirectionalRectEdge.leading, extent: Self.barExtent)),
      .trailing: view.layoutGuide(for: .bar(onEdge: NSDirectionalRectEdge.trailing, extent: Self.barExtent)),
    ]

    let report: @MainActor () -> Void = { [weak self, weak view] in
      guard let self, let view else { return }
      self.send(Self.event(for: view, hinge: hinge, barGuides: barGuides))
    }
    probe.onChange = report
    view.insertSubview(probe, at: 0)

    let interaction = UIHingeInteraction { _, update in
      hinge = update.hinge
      report()
    }
    view.addInteraction(interaction)
    let traits = probe.registerForTraitChanges(UITraitCollection.systemTraitsAffectingVerticalBarEdge) {
      (_: LayoutProbe, _: UITraitCollection) in report()
    }

    detach = { [weak view, weak probe] in
      probe?.unregisterForTraitChanges(traits)
      probe?.removeFromSuperview()
      view?.removeInteraction(interaction)
    }
    report()
  }

  private func send(_ event: NSDictionary) {
    guard !(lastEvent?.isEqual(event) ?? false) else { return }
    lastEvent = event
    sink?(event)
  }

  @available(iOS 27.1, *)
  @MainActor
  private static func event(
    for view: UIView, hinge: UIHinge?, barGuides: [UIVerticalBarEdge: UILayoutGuide]
  ) -> NSDictionary {
    let event = NSMutableDictionary()

    if let fold = view.reservedRegions(kind: .division).first {
      let state = hinge?.status == .partiallyOpen ? "halfOpened" : "flat"
      event["fold"] = rect(fold.frame, ["type": "fold", "state": state])
    }

    let edge = view.traitCollection.verticalBarEdge
    if edge != .unspecified, let guide = barGuides[edge] {
      let frame = guide.layoutFrame
      if frame.width > 0, frame.height > 0 {
        let side = frame.midX > view.bounds.midX ? "right" : "left"
        // With the status bar moved into the vertical bar, nothing keeps
        // content off the screen's rounded corners; the corner-adapted
        // safe area says how far in a top row has to start.
        let corners = view.edgeInsets(for: .safeArea(cornerAdaptation: .horizontal))
        event["bar"] = rect(frame, [
          "side": side,
          "cornerLeft": Double(corners.left),
          "cornerRight": Double(corners.right),
        ])
      }
    }
    return event
  }

  private static func rect(_ r: CGRect, _ extra: [String: Any]) -> NSDictionary {
    let out = NSMutableDictionary(dictionary: extra)
    out["left"] = Double(r.minX)
    out["top"] = Double(r.minY)
    out["right"] = Double(r.maxX)
    out["bottom"] = Double(r.maxY)
    return out
  }
}

/// An invisible view filling the Flutter view, so the bridge hears about
/// every resize, rotation and safe area change.
private final class LayoutProbe: UIView {
  var onChange: (@MainActor () -> Void)?

  override init(frame: CGRect) {
    super.init(frame: frame)
    autoresizingMask = [.flexibleWidth, .flexibleHeight]
    isUserInteractionEnabled = false
    backgroundColor = .clear
    isAccessibilityElement = false
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    // After this pass, so layout guides have their new frames.
    DispatchQueue.main.async { [weak self] in self?.onChange?() }
  }

  override func safeAreaInsetsDidChange() {
    super.safeAreaInsetsDidChange()
    DispatchQueue.main.async { [weak self] in self?.onChange?() }
  }
}
