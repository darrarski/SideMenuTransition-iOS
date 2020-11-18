import UIKit

public final class SideMenuPresentTransition: NSObject,
                                              UIViewControllerAnimatedTransitioning {
  static let fromViewTag = UUID().hashValue

  public init(
    dismissInteractor: SideMenuDismissInteracting,
    menuAnimator: SideMenuAnimating,
    viewAnimator: UIViewAnimating.Type
  ) {
    self.dismissInteractor = dismissInteractor
    self.menuAnimator = menuAnimator
    self.viewAnimator = viewAnimator
    super.init()
  }

  let dismissInteractor: SideMenuDismissInteracting
  let menuAnimator: SideMenuAnimating
  let viewAnimator: UIViewAnimating.Type

  // MARK: - UIViewControllerAnimatedTransitioning

  public func transitionDuration(using context: UIViewControllerContextTransitioning?) -> TimeInterval {
    0.25
  }

  public func animateTransition(using context: UIViewControllerContextTransitioning) {
    guard let fromVC = context.viewController(forKey: .from),
          let fromSnapshot = fromVC.view.snapshotView(afterScreenUpdates: true),
          let toVC = context.viewController(forKey: .to)
    else {
      context.completeTransition(false)
      return
    }

    context.containerView.addSubview(toVC.view)
    toVC.view.frame = context.containerView.bounds

    let fromView = UIView()
    fromView.tag = Self.fromViewTag
    context.containerView.addSubview(fromView)
    fromView.frame = context.containerView.bounds
    fromView.layer.shadowColor = UIColor.separator.cgColor
    fromView.layer.shadowOpacity = 0
    fromView.layer.shadowOffset = .zero
    fromView.layer.shadowRadius = 32
    fromView.addSubview(fromSnapshot)
    fromSnapshot.frame = fromView.bounds
    fromSnapshot.layer.borderWidth = 1
    fromSnapshot.layer.borderColor = UIColor.separator.cgColor
    fromSnapshot.layer.cornerRadius = 0
    fromSnapshot.layer.masksToBounds = true

    dismissInteractor.setup(
      view: fromSnapshot,
      action: { fromVC.dismiss(animated: true) }
    )

    viewAnimator.animate(
      withDuration: transitionDuration(using: context),
      animations: {
        self.menuAnimator.animate(in: context.containerView, to: 1)
      },
      completion: { _ in
        let isCancelled = context.transitionWasCancelled
        context.completeTransition(isCancelled == false)
      }
    )
  }
}
