import UIKit

public protocol SideMenuPresentInteracting {
  var interactionInProgress: Bool { get }
  var percentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition { get }

  func setup(view: UIView, action: @escaping () -> Void)
}

public final class SideMenuPresentInteractor: NSObject,
                                              SideMenuPresentInteracting,
                                              UIGestureRecognizerDelegate {
  public override init() { super.init() }

  var panGestureRecognizerFactory: (Any?, Selector?) -> UIPanGestureRecognizer
    = UIPanGestureRecognizer.init(target:action:)

  private var action: (() -> Void)?
  private var shouldFinishTransition = false

  // MARK: - SideMenuPresentInteracting

  public private(set) var interactionInProgress = false
  public internal(set) var percentDrivenInteractiveTransition = UIPercentDrivenInteractiveTransition()

  public func setup(view: UIView, action: @escaping () -> Void) {
    let recognizer = panGestureRecognizerFactory(self, #selector(handleGesture(_:)))
    recognizer.delegate = self
    view.addGestureRecognizer(recognizer)
    self.action = action
  }

  // MARK: - UIGestureRecognizerDelegate

  public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    guard let recognizer = gestureRecognizer as? UIPanGestureRecognizer,
          let view = recognizer.view
    else { return false }

    let translation = recognizer.translation(in: view)
    guard translation.y == 0 else { return false }

    let location = recognizer.location(in: view)
    let edgeOffsetRange = (view.bounds.minX...(view.bounds.minX + 32))
    guard edgeOffsetRange.contains(location.x) else { return false }

    return true
  }

  // MARK: - Gesture handling

  @objc
  private func handleGesture(_ recognizer: UIPanGestureRecognizer) {
    guard let view = recognizer.view else { return }
    let viewWidth = view.bounds.size.width
    guard viewWidth > 0 else { return }

    let translation = recognizer.translation(in: view)
    let progress = min(1, max(0, translation.x / (viewWidth * 0.6)))

    switch recognizer.state {
    case .possible, .failed:
      interactionInProgress = false

    case .began:
      interactionInProgress = true
      shouldFinishTransition = false
      action?()

    case .changed:
      shouldFinishTransition = progress >= 0.5
      percentDrivenInteractiveTransition.update(progress)

    case .cancelled:
      interactionInProgress = false
      percentDrivenInteractiveTransition.cancel()

    case .ended:
      interactionInProgress = false
      if shouldFinishTransition {
        percentDrivenInteractiveTransition.finish()
      } else {
        percentDrivenInteractiveTransition.cancel()
      }

    @unknown default:
      interactionInProgress = false
      percentDrivenInteractiveTransition.cancel()
    }
  }
}
