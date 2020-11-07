import UIKit

protocol SideMenuAnimating {
  func animate(in containerView: UIView, to progress: CGFloat)
}

struct SideMenuAnimator: SideMenuAnimating {
  func animate(in containerView: UIView, to progress: CGFloat) {
    guard let fromSnapshot = containerView.viewWithTag(SideMenuPresentTransition.fromSnapshotViewTag)
    else { return }

    let shadowOpacity = Float(progress)
    let offsetX = containerView.bounds.size.width * 0.7 * progress
    let scale = 1 - (0.2 * progress)

    fromSnapshot.layer.shadowOpacity = shadowOpacity
    fromSnapshot.transform = CGAffineTransform.identity
      .translatedBy(x: offsetX, y: 0)
      .scaledBy(x: scale, y: scale)
  }
}
