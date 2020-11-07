import UIKit

protocol SideMenuAnimating {
  func animate(parentView: UIView, to progress: CGFloat)
}

struct SideMenuAnimator: SideMenuAnimating {
  func animate(parentView: UIView, to progress: CGFloat) {
    let cornerRadius = progress * 48
    let shadowOpacity = Float(progress)
    let offsetX = parentView.bounds.size.width * 0.7 * progress
    let scale = 1 - (0.2 * progress)

    parentView.layer.cornerRadius = cornerRadius
    parentView.layer.shadowOpacity = shadowOpacity
    parentView.transform = CGAffineTransform.identity
      .translatedBy(x: offsetX, y: 0)
      .scaledBy(x: scale, y: scale)
  }
}
