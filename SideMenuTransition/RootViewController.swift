import UIKit

final class RootViewController: UIViewController {
  private let menuPresenter: SideMenuPresenting = SideMenuPresenter()

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

  override func viewDidLoad() {
    super.viewDidLoad()
    menuPresenter.setup(in: self)
  }

  @objc
  private func presentMenu() {
    menuPresenter.present(from: self)
  }
}
