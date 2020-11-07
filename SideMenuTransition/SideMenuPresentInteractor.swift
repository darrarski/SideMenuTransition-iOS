import UIKit

final class SideMenuPresentInteractor: UIPercentDrivenInteractiveTransition, UIGestureRecognizerDelegate {
  private(set) var interactionInProgress = false
  private var action: (() -> Void)?
  private var shouldFinishTransition = false
  private let maxEdgeOffset: CGFloat = 32
  private let viewWidthProgressTranslation: CGFloat = 0.6
  private let triggerProgress: CGFloat = 0.5

  func setup(view: UIView, action: @escaping () -> Void) {
    let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
    recognizer.delegate = self
    view.addGestureRecognizer(recognizer)
    self.action = action
  }

  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    guard let recognizer = gestureRecognizer as? UIPanGestureRecognizer,
          let view = recognizer.view
    else { return false }

    let translation = recognizer.translation(in: view)
    guard translation.y == 0 else { return false }

    let location = recognizer.location(in: view)
    let edgeOffsetRange = (view.bounds.minX...(view.bounds.minX + maxEdgeOffset))
    guard edgeOffsetRange.contains(location.x) else { return false }

    return true
  }

  @objc
  private func handleGesture(_ recognizer: UIPanGestureRecognizer) {
    guard let view = recognizer.view else { return }
    let viewWidth = view.bounds.size.width
    guard viewWidth > 0 else { return }

    let translation = recognizer.translation(in: view)
    let progress = min(1, max(0, translation.x / (viewWidth * viewWidthProgressTranslation)))

    switch recognizer.state {
    case .possible, .failed:
      interactionInProgress = false

    case .began:
      interactionInProgress = true
      shouldFinishTransition = false
      action?()

    case .changed:
      shouldFinishTransition = progress >= triggerProgress
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
