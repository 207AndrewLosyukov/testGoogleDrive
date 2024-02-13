import UIKit
import GoogleAPIClientForREST

class FileCell: UITableViewCell {

    // констрейнты в константы нет смысла собирать - они все разные и будет только хуже
    enum Constants {
        static let reuseIdentifier = "FileCell"
        static let imagePlaceholder = "placeholder"
        static let chevronImage = "chevron.right"
        static let today = "Сегодня в"
        static let yesterday = "Вчера в"
        static let subtitleSize = 11.0
    }

    var fileImageView: UIImageView = UIImageView()
    var titleLabel: UILabel = UILabel()
    var subtitleLabel: UILabel = UILabel()
    let chevronImage = UIImageView()

    func configureCell(_ file: FileModel) {
        fileImageView.image = UIImage(named: Constants.imagePlaceholder)
        setupConstraints()
        setupLabels(from: file)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        fileImageView.image = nil
        chevronImage.image = nil
    }

    func setupLabels(from file: FileModel) {
        titleLabel.text = file.name
        if let byteSize = file.size, let date = file.modifiedTime {

            let sizeString = Units(bytes: byteSize).getReadableUnit()

            let dateString = getDate(date: date)
            subtitleLabel.text = "\(sizeString) - \(dateString)"

        } else if file.size != nil {
            let sizeString = Units(bytes: file.size ?? 0).getReadableUnit()
            subtitleLabel.text = "\(sizeString)"
        } else if file.modifiedTime != nil {
            let dateString = getDate(date: file.modifiedTime ?? Date())
            subtitleLabel.text = "\(dateString)"
            setupChevronRight()

        } else {
            setupChevronRight()
        }
        subtitleLabel.font = UIFont.systemFont(ofSize: Constants.subtitleSize)
        subtitleLabel.textColor = .lightGray
    }

    func setupChevronRight() {
        chevronImage.image = UIImage(systemName: Constants.chevronImage)
        chevronImage.translatesAutoresizingMaskIntoConstraints = false
        chevronImage.tintColor = .lightGray
        contentView.addSubview(chevronImage)
        NSLayoutConstraint.activate([
            chevronImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            chevronImage.heightAnchor.constraint(equalToConstant: 28),
            chevronImage.widthAnchor.constraint(equalToConstant: 14)
        ])
    }

    func setupConstraints() {
        fileImageView.contentMode = .scaleToFill
        fileImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(fileImageView)
        NSLayoutConstraint.activate([
            fileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            fileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            fileImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            fileImageView.widthAnchor.constraint(equalTo: fileImageView.heightAnchor)
        ])

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: fileImageView.trailingAnchor, constant: 15),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
        ])

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
    }

    func getDate(date: Date) -> String {

        let calendar = Calendar.current

        var dateString = ""
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let timeString = formatter.string(from: date)
            dateString = "\(Constants.today) \(timeString)"
        } else if calendar.isDateInYesterday(date) {

            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let timeString = formatter.string(from: date)
            dateString = "\(Constants.yesterday) \(timeString)"
        } else {
            if case .text(let str) = date.customPlaygroundQuickLook {
                dateString = str
            }
        }
        return dateString
    }
}

