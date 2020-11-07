import UIKit

final class SideMenuDismissTransition: NSObject,
                                       UIViewControllerAnimatedTransitioning {
  init(
    menuAnimator: SideMenuAnimating,
    viewAnimator: UIViewAnimating.Type
  ) {
    self.menuAnimator = menuAnimator
    self.viewAnimator = viewAnimator
    super.init()
  }

  let menuAnimator: SideMenuAnimating
  let viewAnimator: UIViewAnimating.Type

  // MARK: - UIViewControllerAnimatedTransitioning

  func transitionDuration(using context: UIViewControllerContextTransitioning?) -> TimeInterval {
    0.25
  }

  func animateTransition(using context: UIViewControllerContextTransitioning) {
    guard let parentVC = context.viewController(forKey: .to)
    else {
      context.completeTransition(false)
      return
    }

    // TODO: disable interactive dismiss gesture in parent view
    // TODO: enable interactive present gesture in parent view

    viewAnimator.animate(
      withDuration: transitionDuration(using: context),
      animations: {
        self.menuAnimator.animate(parentView: parentVC.view, to: 0)
      },
      completion: { _ in
        let isCancelled = context.transitionWasCancelled
        context.completeTransition(isCancelled == false)
      }
    )
  }
}
