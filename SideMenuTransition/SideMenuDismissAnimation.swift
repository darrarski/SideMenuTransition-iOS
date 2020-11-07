import UIKit

final class SideMenuDismissAnimation: NSObject, UIViewControllerAnimatedTransitioning {
  func transitionDuration(using context: UIViewControllerContextTransitioning?) -> TimeInterval {
    0.25
  }

  func animateTransition(using context: UIViewControllerContextTransitioning) {
    guard let fromSnapshot = context.containerView.viewWithTag(SideMenuPresentAnimation.fromSnapshotViewTag)
    else {
      context.completeTransition(false)
      return
    }

    UIView.animate(
      withDuration: transitionDuration(using: context),
      animations: {
        fromSnapshot.transform = .identity
      },
      completion: { _ in
        let isCancelled = context.transitionWasCancelled
        context.completeTransition(isCancelled == false)
      }
    )
  }
}
