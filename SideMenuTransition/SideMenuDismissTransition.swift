import UIKit

final class SideMenuDismissTransition: NSObject, UIViewControllerAnimatedTransitioning {
  func transitionDuration(using context: UIViewControllerContextTransitioning?) -> TimeInterval {
    0.25
  }

  func animateTransition(using context: UIViewControllerContextTransitioning) {
    guard let fromSnapshot = context.containerView.viewWithTag(SideMenuPresentTransition.fromSnapshotViewTag)
    else {
      context.completeTransition(false)
      return
    }

    UIView.animate(
      withDuration: transitionDuration(using: context),
      animations: {
        fromSnapshot.layer.shadowOpacity = 0
        fromSnapshot.transform = .identity
      },
      completion: { _ in
        let isCancelled = context.transitionWasCancelled
        context.completeTransition(isCancelled == false)
      }
    )
  }
}
