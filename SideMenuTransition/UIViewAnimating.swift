import UIKit

protocol UIViewAnimating {
  static func animate(
    withDuration duration: TimeInterval,
    animations: @escaping () -> Void,
    completion: ((Bool) -> Void)?
  )
}

extension UIView: UIViewAnimating {}
