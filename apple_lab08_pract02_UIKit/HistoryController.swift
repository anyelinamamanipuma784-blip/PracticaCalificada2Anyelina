//
//  HistoryController.swift
//  apple_lab08_pract02_UIKit
//

import UIKit

// MARK: - Modelo

struct Calculation: Codable {
    let operation: Operation
    let first: Double
    let second: Double
    let result: Double
    let date: Date

    var expression: String {
        "\(formatNumber(first)) \(operation.symbol) \(formatNumber(second)) = \(formatNumber(result))"
    }
}

extension Operation {
    /// (fondo pastel, color del símbolo)
    var pastel: (UIColor, UIColor) {
        switch self {
        case .addition:       return (UIColor(hex: 0xD3F1E3), UIColor(hex: 0x4E9C7A))
        case .subtraction:    return (UIColor(hex: 0xFFE0D1), UIColor(hex: 0xC9764F))
        case .multiplication: return (UIColor(hex: 0xE4DAFA), UIColor(hex: 0x7A62C2))
        }
    }
}

// MARK: - Almacén del historial (se guarda en UserDefaults)

final class CalculationHistory {

    static let shared = CalculationHistory()

    private let storageKey = "calculation_history"
    private(set) var items: [Calculation] = []

    private init() {
        load()
    }

    func add(_ calculation: Calculation) {
        items.insert(calculation, at: 0)
        save()
    }

    func remove(at index: Int) {
        guard items.indices.contains(index) else { return }
        items.remove(at: index)
        save()
    }

    func clear() {
        items.removeAll()
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([Calculation].self, from: data) else { return }
        items = decoded
    }

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}

// MARK: - Celda

final class HistoryCell: UITableViewCell {

    static let reuseId = "HistoryCell"

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_PE")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    private let cardView = UIView()
    private let badgeView = UIView()
    private let symbolLabel = UILabel()
    private let expressionLabel = UILabel()
    private let detailLabel = UILabel()
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

        badgeView.layer.cornerRadius = 25
        badgeView.translatesAutoresizingMaskIntoConstraints = false

        symbolLabel.font = .systemFont(ofSize: 24, weight: .bold)
        symbolLabel.textAlignment = .center
        symbolLabel.translatesAutoresizingMaskIntoConstraints = false
        badgeView.addSubview(symbolLabel)

        expressionLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        expressionLabel.textColor = Theme.textPrimary
        expressionLabel.adjustsFontSizeToFitWidth = true
        expressionLabel.minimumScaleFactor = 0.6

        detailLabel.font = .systemFont(ofSize: 13)
        detailLabel.textColor = Theme.textSecondary

        let textStack = UIStackView(arrangedSubviews: [expressionLabel, detailLabel])
        textStack.axis = .vertical
        textStack.spacing = 3
        textStack.translatesAutoresizingMaskIntoConstraints = false

        chevron.tintColor = Theme.accent
        chevron.contentMode = .scaleAspectFit
        chevron.translatesAutoresizingMaskIntoConstraints = false

        cardView.addSubview(badgeView)
        cardView.addSubview(textStack)
        cardView.addSubview(chevron)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            badgeView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            badgeView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            badgeView.widthAnchor.constraint(equalToConstant: 50),
            badgeView.heightAnchor.constraint(equalToConstant: 50),

            symbolLabel.centerXAnchor.constraint(equalTo: badgeView.centerXAnchor),
            symbolLabel.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor),

            textStack.leadingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: 14),
            textStack.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -8),
            textStack.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),

            chevron.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 12)
        ])
    }

    func configure(with calculation: Calculation) {
        let colors = calculation.operation.pastel
        badgeView.backgroundColor = colors.0
        symbolLabel.textColor = colors.1
        symbolLabel.text = calculation.operation.symbol
        expressionLabel.text = calculation.expression
        detailLabel.text = "\(calculation.operation.rawValue) · \(Self.dateFormatter.string(from: calculation.date))"
    }
}

// MARK: - Controller

final class HistoryController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyLabel = UILabel()
    private let history = CalculationHistory.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Resultados"
        view.backgroundColor = Theme.background
        navigationItem.largeTitleDisplayMode = .never

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "trash"),
            primaryAction: UIAction { [weak self] _ in self?.confirmClear() }
        )

        setupTableView()
        setupEmptyState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = Theme.background
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 88
        tableView.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        tableView.register(HistoryCell.self, forCellReuseIdentifier: HistoryCell.reuseId)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupEmptyState() {
        emptyLabel.text = "Aún no hay cálculos.\nHaz una operación en Calculadora\ny aparecerá aquí."
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        emptyLabel.font = .systemFont(ofSize: 16)
        emptyLabel.textColor = Theme.textSecondary
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32)
        ])
    }

    private func reload() {
        tableView.reloadData()
        let isEmpty = history.items.isEmpty
        emptyLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        navigationItem.rightBarButtonItem?.isEnabled = !isEmpty
    }

    private func confirmClear() {
        let alert = UIAlertController(title: "Borrar historial",
                                      message: "¿Quieres borrar todos los resultados?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alert.addAction(UIAlertAction(title: "Borrar", style: .destructive) { [weak self] _ in
            self?.history.clear()
            self?.reload()
        })
        alert.view.tintColor = Theme.accentStrong
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource / Delegate

extension HistoryController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        history.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HistoryCell.reuseId, for: indexPath) as! HistoryCell
        cell.configure(with: history.items[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = history.items[indexPath.row]
        let detail = ResultController(operation: item.operation,
                                      first: item.first,
                                      second: item.second,
                                      result: item.result)
        // "Nuevo cálculo" desde aquí te lleva al tab Calculadora.
        detail.onNewCalculation = { [weak self] in
            self?.tabBarController?.selectedIndex = 1
        }
        navigationController?.pushViewController(detail, animated: true)
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        history.remove(at: indexPath.row)
        reload()
    }
}
