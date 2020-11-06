import UIKit

final class ViewController: UIViewController {
  override func loadView() {
    let view = UIView()
    view.backgroundColor = .systemBackground
    let label = UILabel()
    label.text = "Hello, World!"
    view.addSubview(label)
    label.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
      label.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
    ])
    self.view = view
  }
}
