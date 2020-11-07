import UIKit

final class SideMenuDismissTransition: NSObject, UIViewControllerAnimatedTransitioning {
  let animator = SideMenuAnimator()

  func transitionDuration(using context: UIViewControllerContextTransitioning?) -> TimeInterval {
    0.25
  }

  func animateTransition(using context: UIViewControllerContextTransitioning) {
    UIView.animate(
      withDuration: transitionDuration(using: context),
      animations: {
        self.animator.animate(in: context.containerView, to: 0)
      },
      completion: { _ in
        let isCancelled = context.transitionWasCancelled
        context.completeTransition(isCancelled == false)
      }
    )
  }
}
