import UIKit

final class SideMenuPresentAnimation: NSObject, UIViewControllerAnimatedTransitioning {
  static let fromSnapshotViewTag = UUID().hashValue

  func transitionDuration(using context: UIViewControllerContextTransitioning?) -> TimeInterval {
    0.25
  }

  func animateTransition(using context: UIViewControllerContextTransitioning) {
    guard let fromVC = context.viewController(forKey: .from),
          let fromSnapshot = fromVC.view.snapshotView(afterScreenUpdates: true),
          let toVC = context.viewController(forKey: .to)
    else {
      context.completeTransition(false)
      return
    }

    context.containerView.addSubview(toVC.view)
    toVC.view.frame = context.containerView.bounds

    context.containerView.addSubview(fromSnapshot)
    fromSnapshot.tag = Self.fromSnapshotViewTag
    fromSnapshot.frame = context.containerView.bounds
    fromSnapshot.layer.borderWidth = 1
    fromSnapshot.layer.borderColor = UIColor.separator.cgColor
    fromSnapshot.layer.shadowColor = UIColor.separator.cgColor
    fromSnapshot.layer.shadowOpacity = 0
    fromSnapshot.layer.shadowOffset = .zero
    fromSnapshot.layer.shadowRadius = 32

    UIView.animate(
      withDuration: transitionDuration(using: context),
      animations: {
        fromSnapshot.layer.shadowOpacity = 1
        fromSnapshot.transform = CGAffineTransform.identity
          .translatedBy(x: context.containerView.bounds.size.width * 0.7, y: 0)
          .scaledBy(x: 0.8, y: 0.8)
      },
      completion: { _ in
        let isCancelled = context.transitionWasCancelled
        context.completeTransition(isCancelled == false)
      }
    )
  }
}
