//
//  TeacherController.swift
//  apple_lab08_pract02_UIKit
//

import UIKit

// MARK: - Modelo

struct Teacher {
    let name: String
    let subject: String
    let background: UIColor   // fondo pastel del avatar
    let foreground: UIColor   // color de las iniciales

    var initials: String {
        name.split(separator: " ").prefix(2).compactMap { $0.first }.map(String.init).joined()
    }
}

// MARK: - Celda (tarjeta pastel)

final class TeacherCell: UITableViewCell {

    static let reuseId = "TeacherCell"

    private let cardView = UIView()
    private let avatarView = UIView()
    private let initialsLabel = UILabel()
    private let nameLabel = UILabel()
    private let subjectLabel = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        cardView.backgroundColor = Theme.card
        cardView.layer.cornerRadius = 18
        cardView.layer.shadowColor = Theme.accentStrong.cgColor
        cardView.layer.shadowOpacity = 0.12
        cardView.layer.shadowRadius = 8
        cardView.layer.shadowOffset = CGSize(width: 0, height: 3)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)

        avatarView.layer.cornerRadius = 25
        avatarView.translatesAutoresizingMaskIntoConstraints = false

        initialsLabel.font = .systemFont(ofSize: 18, weight: .bold)
        initialsLabel.textAlignment = .center
        initialsLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarView.addSubview(initialsLabel)

        nameLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        nameLabel.textColor = Theme.textPrimary
        subjectLabel.font = .systemFont(ofSize: 15)
        subjectLabel.textColor = Theme.textSecondary

        let textStack = UIStackView(arrangedSubviews: [nameLabel, subjectLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false

        chevron.tintColor = Theme.accent
        chevron.contentMode = .scaleAspectFit
        chevron.translatesAutoresizingMaskIntoConstraints = false

        cardView.addSubview(avatarView)
        cardView.addSubview(textStack)
        cardView.addSubview(chevron)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            avatarView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            avatarView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 50),
            avatarView.heightAnchor.constraint(equalToConstant: 50),

            initialsLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),

            textStack.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 14),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: chevron.leadingAnchor, constant: -8),
            textStack.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

            chevron.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 12)
        ])
    }

    func configure(with teacher: Teacher) {
        nameLabel.text = teacher.name
        subjectLabel.text = teacher.subject
        initialsLabel.text = teacher.initials
        initialsLabel.textColor = teacher.foreground
        avatarView.backgroundColor = teacher.background
    }
}

// MARK: - Controller

class TeacherController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .plain)

    private let teachers: [Teacher] = [
        Teacher(name: "John Doe",        subject: "Matemática",      background: UIColor(hex: 0xD6E8FA), foreground: UIColor(hex: 0x4F7CAC)),
        Teacher(name: "Anna Smith",      subject: "Física",          background: UIColor(hex: 0xFFE0D1), foreground: UIColor(hex: 0xC9764F)),
        Teacher(name: "Robert Johnson",  subject: "Química",        background: UIColor(hex: 0xD3F1E3), foreground: UIColor(hex: 0x4E9C7A)),
        Teacher(name: "Maria Brown",     subject: "Biología",          background: UIColor(hex: 0xE4DAFA), foreground: UIColor(hex: 0x7A62C2)),
        Teacher(name: "David Wilson",    subject: "Historia",          background: UIColor(hex: 0xFBD6E4), foreground: UIColor(hex: 0xC2587F)),
        Teacher(name: "Emily Garcia",    subject: "Inglés",          background: UIColor(hex: 0xFFF3C4), foreground: UIColor(hex: 0xA8892A)),
        Teacher(name: "Thomas Martinez", subject: "Computación", background: UIColor(hex: 0xCFF0F0), foreground: UIColor(hex: 0x3E9A9A)),
        Teacher(name: "Laura Taylor",    subject: "Arte",              background: UIColor(hex: 0xFFE5C2), foreground: UIColor(hex: 0xC48A2F)),
        Teacher(name: "Carlos Mendoza",  subject: "Geografía",        background: UIColor(hex: 0xE0F0C8), foreground: UIColor(hex: 0x6C9A3A))
    ]
    private var filteredTeachers: [Teacher] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Docentes"
        view.backgroundColor = Theme.background
        filteredTeachers = teachers

        setupSearch()
        setupTableView()
    }

    private func setupSearch() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Buscar"
        searchController.searchBar.tintColor = Theme.accentStrong
        searchController.searchBar.searchTextField.backgroundColor = Theme.card
        searchController.searchBar.searchTextField.textColor = Theme.textPrimary
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.largeTitleDisplayMode = .never
        definesPresentationContext = true
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = Theme.background
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 88
        tableView.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        tableView.keyboardDismissMode = .onDrag
        tableView.register(TeacherCell.self, forCellReuseIdentifier: TeacherCell.reuseId)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource / Delegate

extension TeacherController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredTeachers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TeacherCell.reuseId, for: indexPath) as! TeacherCell
        cell.configure(with: filteredTeachers[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UISearchResultsUpdating

extension TeacherController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        let query = (searchController.searchBar.text ?? "").trimmingCharacters(in: .whitespaces)
        if query.isEmpty {
            filteredTeachers = teachers
        } else {
            filteredTeachers = teachers.filter {
                $0.name.localizedCaseInsensitiveContains(query) ||
                $0.subject.localizedCaseInsensitiveContains(query)
            }
        }
        tableView.reloadData()
    }
}
