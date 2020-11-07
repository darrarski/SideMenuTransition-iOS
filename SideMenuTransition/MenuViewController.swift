import UIKit

final class MenuViewController: UIViewController {
  override func loadView() {
    let view = UIView()
    view.backgroundColor = .systemBackground
    let dismissButton = UIButton()
    dismissButton.setTitle("Dismiss", for: .normal)
    dismissButton.setTitleColor(.systemBlue, for: .normal)
    dismissButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
    view.addSubview(dismissButton)
    dismissButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      dismissButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
      dismissButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
    ])
    self.view = view
  }

  @objc
  private func dismissSelf() {
    presentingViewController?.dismiss(animated: true)
  }
}
