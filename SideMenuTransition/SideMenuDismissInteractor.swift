import UIKit

protocol SideMenuDismissInteracting: UIViewControllerInteractiveTransitioning {
  func setup(view: UIView, action: @escaping () -> Void)
  var interactionInProgress: Bool { get }
}

final class SideMenuDismissInteractor: UIPercentDrivenInteractiveTransition,
                                       SideMenuDismissInteracting {
  private var action: (() -> Void)?
  private var shouldFinishTransition = false

  // MARK: - SideMenuDismissInteracting

  private(set) var interactionInProgress = false

  func setup(view: UIView, action: @escaping () -> Void) {
    let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
    view.addGestureRecognizer(recognizer)
    self.action = action
  }

  // MARK: - Gesture handling

  @objc
  private func handleGesture(_ recognizer: UIPanGestureRecognizer) {
    guard let view = recognizer.view,
          let containerView = view.superview
    else { return }

    let viewWidth = containerView.bounds.size.width
    guard viewWidth > 0 else { return }

    let translation = recognizer.translation(in: view)
    let progress = min(1, max(0, -translation.x / (viewWidth * 0.8)))

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
      shouldFinishTransition ? finish() : cancel()

    @unknown default:
      interactionInProgress = false
      cancel()
    }
  }
}
