import UIKit

protocol SideMenuPresentInteracting: UIViewControllerInteractiveTransitioning {
  func setup(view: UIView, action: @escaping () -> Void)
  var interactionInProgress: Bool { get }
}

final class SideMenuPresentInteractor: UIPercentDrivenInteractiveTransition,
                                       SideMenuPresentInteracting,
                                       UIGestureRecognizerDelegate {
  private var action: (() -> Void)?
  private var shouldFinishTransition = false

  // MARK: - SideMenuPresentInteracting

  private(set) var interactionInProgress = false

  func setup(view: UIView, action: @escaping () -> Void) {
    let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
    recognizer.delegate = self
    view.addGestureRecognizer(recognizer)
    self.action = action
  }

  // MARK: - UIGestureRecognizerDelegate

  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
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
      update(progress)

    case .cancelled:
      interactionInProgress = false
      cancel()

    case .ended:
      interactionInProgress = false
      if shouldFinishTransition {
        finish()
      } else {
        cancel()
      }

    @unknown default:
      interactionInProgress = false
      cancel()
    }
  }
}
