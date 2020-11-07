import UIKit

final class SideMenuPresentTransition: NSObject, UIViewControllerAnimatedTransitioning {
  static let fromSnapshotViewTag = UUID().hashValue

  init(dismissInteractor: SideMenuDismissInteracting) {
    self.dismissInteractor = dismissInteractor
    super.init()
  }

  let dismissInteractor: SideMenuDismissInteracting
  let animator = SideMenuAnimator()

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

    dismissInteractor.setup(
      view: fromSnapshot,
      action: { fromVC.dismiss(animated: true) }
    )

    UIView.animate(
      withDuration: transitionDuration(using: context),
      animations: {
        self.animator.animate(in: context.containerView, to: 1)
      },
      completion: { _ in
        let isCancelled = context.transitionWasCancelled
        context.completeTransition(isCancelled == false)
      }
    )
  }
}
