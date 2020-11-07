import UIKit

final class RootViewController: UIViewController {
  init() {
    super.init(nibName: nil, bundle: nil)
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      title: "Menu",
      style: .plain,
      target: self,
      action: #selector(presentMenu)
    )
  }

  required init?(coder: NSCoder) { nil }

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

  @objc
  private func presentMenu() {
    let viewController = MenuViewController()
    present(viewController, animated: true)
  }
}
