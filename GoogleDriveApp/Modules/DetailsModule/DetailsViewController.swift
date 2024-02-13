import UIKit

class DetailsViewController: UIViewController {

    enum Constants {
        static let bigTextSize = 20.0
        static let smallTextSize = 16.0
        static let imagePlaceholder = "placeholder"
        static let bigCornerRadius = 20.0
        static let smallCornerRadius = 16.0
        static let backTitle = "Назад"
        static let borderWidth = 2.0
        static let bigConstraintConstant = 40.0
        static let smallConstraintConstant = 20.0
        static let heightButton = 50.0
        static let widthButton = 120.0
        static let stackViewHeight = 200.0
    }

    let file: FileModel
    let networkService: NetworkServiceProtocol

    lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.boldSystemFont(ofSize: Constants.bigTextSize)
        nameLabel.numberOfLines = 0
        return nameLabel
    }()

    lazy var sizeLabel: UILabel = {
        let sizeLabel = UILabel()
        sizeLabel.translatesAutoresizingMaskIntoConstraints = false
        sizeLabel.font = UIFont.systemFont(ofSize: Constants.smallTextSize)
        return sizeLabel
    }()

    lazy var modifiedTimeLabel: UILabel = {
        let modifiedTimeLabel = UILabel()
        modifiedTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        modifiedTimeLabel.font = UIFont.systemFont(ofSize: Constants.smallTextSize)
        return modifiedTimeLabel
    }()

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: Constants.imagePlaceholder)
        imageView.layer.cornerRadius = Constants.smallCornerRadius
        return imageView
    }()

    lazy var backButton: UIButton = {
        let backButton = UIButton()
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.backgroundColor = .darkGray
        backButton.tintColor = .white
        backButton.setTitle(Constants.backTitle, for: .normal)
        backButton.layer.cornerRadius = Constants.smallCornerRadius
        backButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backAction(_:))))
        return backButton
    }()

    init(file: FileModel, networkService: NetworkServiceProtocol) {
        self.file = file
        self.networkService = networkService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        setupLabels()
        setupImage()

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)

        let stackView = UIStackView(arrangedSubviews: [
            nameLabel,
            sizeLabel,
            modifiedTimeLabel,
        ])

        contentView.addSubview(imageView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillProportionally

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.smallConstraintConstant),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.smallConstraintConstant),
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.smallConstraintConstant),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Constants.bigConstraintConstant)
        ])
        contentView.layer.borderColor = UIColor.darkGray.cgColor
        contentView.layer.borderWidth = Constants.borderWidth
        contentView.layer.cornerRadius = Constants.bigCornerRadius

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.smallConstraintConstant),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.bigConstraintConstant),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.bigConstraintConstant),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        ])

        stackView.layer.borderWidth = Constants.borderWidth
        stackView.layer.borderColor = UIColor.darkGray.cgColor
        stackView.layer.cornerRadius = Constants.smallCornerRadius
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.smallConstraintConstant),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.bigConstraintConstant),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.bigConstraintConstant),
            stackView.heightAnchor.constraint(equalToConstant: Constants.stackViewHeight)
        ])

        contentView.addSubview(backButton)

        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: Constants.widthButton),
            backButton.heightAnchor.constraint(equalToConstant: Constants.heightButton),
            backButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            backButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: Constants.smallConstraintConstant)
        ])
    }

    func setupLabels() {
        view.backgroundColor = .white
        nameLabel.text = file.name
        if let modifiedTime = file.modifiedTime {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, h:mm a"
            let timeString = formatter.string(from: modifiedTime)
            modifiedTimeLabel.text = timeString
        }
        if let byteSize = file.size {
            sizeLabel.text = Units(bytes: byteSize).getReadableUnit()
        }
    }

    @objc func backAction(_ sender: UITapGestureRecognizer) {
        navigationController?.popViewController(animated: true)
    }

    private func setupImage() {
        var link: String? = nil
        if file.hasThumbnail == true {
            if let stringUrl = file.thumbnailLink {
                link = stringUrl
            }
        } else {
            if let stringUrl = file.iconLink {
                link = stringUrl
            }
        }

        guard let link = link else { return }

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let url = URL(string: link) else { return }
            self?.networkService.fetchData(from: url) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    self?.imageView.image = UIImage(data: data)
                }
            }
        }
    }
}
