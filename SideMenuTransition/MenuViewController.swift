import UIKit

final class MenuViewController: UIViewController {
  override func loadView() {
    let view = UIView()
    view.backgroundColor = .systemBackground
    let dismissButton = UIButton(type: .system)
    dismissButton.setTitle("Dismiss", for: .normal)
    dismissButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
    view.addSubview(dismissButton)
    dismissButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      dismissButton.topAnchor.constraint(
        equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor,
        multiplier: 1
      ),
      dismissButton.leftAnchor.constraint(
        equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leftAnchor,
        multiplier: 2
      )
    ])
    self.view = view
  }

  @objc
  private func dismissSelf() {
    presentingViewController?.dismiss(animated: true)
  }
}
