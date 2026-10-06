//
//  CalculatorController.swift
//  apple_lab08_pract02_UIKit
//

import UIKit

// MARK: - Tema pastel

extension UIColor {
    convenience init(hex: UInt32) {
        self.init(red: CGFloat((hex >> 16) & 0xFF) / 255,
                  green: CGFloat((hex >> 8) & 0xFF) / 255,
                  blue: CGFloat(hex & 0xFF) / 255,
                  alpha: 1)
    }
}

enum Theme {
    static let background    = UIColor(hex: 0xF4EFFF)   // lavanda muy suave
    static let card          = UIColor.white
    static let field         = UIColor(hex: 0xF3EEFD)
    static let accent        = UIColor(hex: 0xCDB8F5)   // lila pastel (botones)
    static let accentText    = UIColor(hex: 0x3E2F66)
    static let accentStrong  = UIColor(hex: 0x8E73D9)   // tabs, números, bordes
    static let mint          = UIColor(hex: 0xBDEBD7)
    static let mintText      = UIColor(hex: 0x2F6B53)
    static let textPrimary   = UIColor(hex: 0x3D3552)
    static let textSecondary = UIColor(hex: 0x8A8399)
    static let separator     = UIColor(hex: 0xE6DDF7)
}

// MARK: - Modelo

enum Operation: String, CaseIterable, Codable {
    case addition       = "Suma (+)"
    case subtraction    = "Resta (-)"
    case multiplication = "Multiplicación (×)"

    var symbol: String {
        switch self {
        case .addition:       return "+"
        case .subtraction:    return "-"
        case .multiplication: return "×"
        }
    }

    func apply(_ a: Double, _ b: Double) -> Double {
        switch self {
        case .addition:       return a + b
        case .subtraction:    return a - b
        case .multiplication: return a * b
        }
    }
}

func formatNumber(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.numberStyle = .decimal
    formatter.usesGroupingSeparator = false
    formatter.maximumFractionDigits = 6
    return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
}

private func makeCard() -> UIView {
    let card = UIView()
    card.backgroundColor = Theme.card
    card.layer.cornerRadius = 22
    card.layer.shadowColor = Theme.accentStrong.cgColor
    card.layer.shadowOpacity = 0.15
    card.layer.shadowRadius = 12
    card.layer.shadowOffset = CGSize(width: 0, height: 4)
    card.translatesAutoresizingMaskIntoConstraints = false
    return card
}

// MARK: - Pantalla Calculator

class CalculatorController: UIViewController, UITextFieldDelegate {

    private let firstField = UITextField()
    private let secondField = UITextField()
    private let operationButton = UIButton(type: .system)
    private var selectedOperation: Operation = .addition

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Calculadora"
        view.backgroundColor = Theme.background
        navigationItem.largeTitleDisplayMode = .never
        setupUI()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: UI

    private func setupUI() {
        let card = makeCard()
        view.addSubview(card)

        let titleLabel = UILabel()
        titleLabel.text = "Operación matemática"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = Theme.textPrimary
        titleLabel.textAlignment = .center

        configure(field: firstField)
        configure(field: secondField)

        configureOperationButton()
        let operationBox = makeBox(caption: "Operación", input: operationButton)
        let chevron = UIImageView(image: UIImage(systemName: "chevron.up.chevron.down"))
        chevron.tintColor = Theme.accentStrong
        chevron.translatesAutoresizingMaskIntoConstraints = false
        operationBox.addSubview(chevron)
        NSLayoutConstraint.activate([
            chevron.trailingAnchor.constraint(equalTo: operationBox.trailingAnchor, constant: -12),
            chevron.bottomAnchor.constraint(equalTo: operationBox.bottomAnchor, constant: -14)
        ])

        var config = UIButton.Configuration.filled()
        config.title = "Calcular"
        config.cornerStyle = .capsule
        config.baseBackgroundColor = Theme.accent
        config.baseForegroundColor = Theme.accentText
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var attrs = attrs
            attrs.font = .systemFont(ofSize: 18, weight: .semibold)
            return attrs
        }
        let calculateButton = UIButton(configuration: config, primaryAction: UIAction { [weak self] _ in
            self?.calculate()
        })
        calculateButton.heightAnchor.constraint(equalToConstant: 54).isActive = true

        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            makeBox(caption: "Primer número", input: firstField),
            makeBox(caption: "Segundo número", input: secondField),
            operationBox,
            calculateButton
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
    }

    private func configure(field: UITextField) {
        field.text = "0"
        field.font = .systemFont(ofSize: 17)
        field.textColor = Theme.textPrimary
        field.tintColor = Theme.accentStrong
        field.keyboardType = .numbersAndPunctuation
        field.clearButtonMode = .whileEditing
        field.delegate = self
    }

    private func configureOperationButton() {
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = Theme.textPrimary
        config.contentInsets = .zero
        config.title = selectedOperation.rawValue
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var attrs = attrs
            attrs.font = .systemFont(ofSize: 17)
            return attrs
        }
        operationButton.configuration = config
        operationButton.contentHorizontalAlignment = .leading
        operationButton.showsMenuAsPrimaryAction = true
        operationButton.menu = makeOperationMenu()
    }

    private func makeOperationMenu() -> UIMenu {
        let actions = Operation.allCases.map { op in
            UIAction(title: op.rawValue, state: op == selectedOperation ? .on : .off) { [weak self] _ in
                guard let self else { return }
                self.selectedOperation = op
                self.operationButton.configuration?.title = op.rawValue
                self.operationButton.menu = self.makeOperationMenu()
            }
        }
        return UIMenu(children: actions)
    }

    private func makeBox(caption: String, input: UIView) -> UIView {
        let box = UIView()
        box.backgroundColor = Theme.field
        box.layer.cornerRadius = 14

        let captionLabel = UILabel()
        captionLabel.text = caption
        captionLabel.font = .systemFont(ofSize: 13)
        captionLabel.textColor = Theme.textSecondary

        let stack = UIStackView(arrangedSubviews: [captionLabel, input])
        stack.axis = .vertical
        stack.spacing = 2
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
        stack.translatesAutoresizingMaskIntoConstraints = false
        box.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: box.topAnchor),
            stack.leadingAnchor.constraint(equalTo: box.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: box.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: box.bottomAnchor)
        ])
        return box
    }

    // MARK: Acciones

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func parse(_ text: String?) -> Double? {
        guard let text = text?.trimmingCharacters(in: .whitespaces), !text.isEmpty else { return nil }
        return Double(text.replacingOccurrences(of: ",", with: "."))
    }

    private func calculate() {
        view.endEditing(true)

        guard let a = parse(firstField.text), let b = parse(secondField.text) else {
            let alert = UIAlertController(title: "Entrada inválida",
                                          message: "Ingresa dos números válidos.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
            alert.view.tintColor = Theme.accentStrong
            present(alert, animated: true)
            return
        }

        let value = selectedOperation.apply(a, b)
        CalculationHistory.shared.add(Calculation(operation: selectedOperation,
                                                  first: a,
                                                  second: b,
                                                  result: value,
                                                  date: Date()))

        let result = ResultController(operation: selectedOperation,
                                      first: a,
                                      second: b,
                                      result: value)
        result.onNewCalculation = { [weak self] in self?.resetFields() }
        navigationController?.pushViewController(result, animated: true)
    }

    private func resetFields() {
        firstField.text = "0"
        secondField.text = "0"
        selectedOperation = .addition
        operationButton.configuration?.title = selectedOperation.rawValue
        operationButton.menu = makeOperationMenu()
    }

    // MARK: UITextFieldDelegate

    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.async { textField.selectAll(nil) }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Pantalla Result

final class ResultController: UIViewController {

    private let operation: Operation
    private let first: Double
    private let second: Double
    private let result: Double

    var onNewCalculation: (() -> Void)?

    private var shareText: String {
        "\(formatNumber(first)) \(operation.symbol) \(formatNumber(second)) = \(formatNumber(result))"
    }

    init(operation: Operation, first: Double, second: Double, result: Double) {
        self.operation = operation
        self.first = first
        self.second = second
        self.result = result
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Resultado"
        view.backgroundColor = Theme.background
        navigationItem.largeTitleDisplayMode = .never
        setupUI()
    }

    private func setupUI() {
        let card = makeCard()
        view.addSubview(card)

        let titleLabel = UILabel()
        titleLabel.text = "Resultado del cálculo"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = Theme.textPrimary
        titleLabel.textAlignment = .center

        let divider = UIView()
        divider.backgroundColor = Theme.separator
        divider.heightAnchor.constraint(equalToConstant: 1.5).isActive = true

        let resultCaption = UILabel()
        resultCaption.text = "Resultado:"
        resultCaption.font = .systemFont(ofSize: 17, weight: .bold)
        resultCaption.textColor = Theme.textSecondary

        let resultLabel = UILabel()
        resultLabel.text = formatNumber(result)
        resultLabel.font = .systemFont(ofSize: 40, weight: .bold)
        resultLabel.textColor = Theme.accentStrong
        resultLabel.textAlignment = .center
        resultLabel.adjustsFontSizeToFitWidth = true
        resultLabel.minimumScaleFactor = 0.4

        let resultBox = UIView()
        resultBox.backgroundColor = Theme.field
        resultBox.layer.cornerRadius = 16
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        resultBox.addSubview(resultLabel)
        NSLayoutConstraint.activate([
            resultLabel.topAnchor.constraint(equalTo: resultBox.topAnchor, constant: 14),
            resultLabel.bottomAnchor.constraint(equalTo: resultBox.bottomAnchor, constant: -14),
            resultLabel.leadingAnchor.constraint(equalTo: resultBox.leadingAnchor, constant: 12),
            resultLabel.trailingAnchor.constraint(equalTo: resultBox.trailingAnchor, constant: -12)
        ])

        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            makeRow("Operación:", operation.rawValue),
            makeRow("Primer número:", formatNumber(first)),
            makeRow("Segundo número:", formatNumber(second)),
            divider,
            resultCaption,
            resultBox,
            makeButtons()
        ])
        stack.axis = .vertical
        stack.spacing = 14
        stack.setCustomSpacing(18, after: titleLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20)
        ])
    }

    private func makeRow(_ title: String, _ value: String) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.textColor = Theme.textSecondary
        titleLabel.widthAnchor.constraint(equalToConstant: 130).isActive = true

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 16, weight: .medium)
        valueLabel.textColor = Theme.textPrimary
        valueLabel.numberOfLines = 0

        let row = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .firstBaseline
        return row
    }

    private func makeButtons() -> UIView {
        var shareConfig = UIButton.Configuration.filled()
        shareConfig.title = "Compartir"
        shareConfig.cornerStyle = .capsule
        shareConfig.baseBackgroundColor = Theme.mint
        shareConfig.baseForegroundColor = Theme.mintText
        shareConfig.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var attrs = attrs
            attrs.font = .systemFont(ofSize: 16, weight: .semibold)
            return attrs
        }
        let shareButton = UIButton(configuration: shareConfig, primaryAction: UIAction { [weak self] action in
            self?.share(from: action.sender as? UIView)
        })

        var newConfig = UIButton.Configuration.plain()
        newConfig.title = "Nuevo cálculo"
        newConfig.cornerStyle = .capsule
        newConfig.baseForegroundColor = Theme.accentStrong
        newConfig.background.strokeColor = Theme.accent
        newConfig.background.strokeWidth = 2
        newConfig.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var attrs = attrs
            attrs.font = .systemFont(ofSize: 15, weight: .semibold)
            return attrs
        }
        let newButton = UIButton(configuration: newConfig, primaryAction: UIAction { [weak self] _ in
            self?.onNewCalculation?()
            self?.navigationController?.popViewController(animated: true)
        })

        let stack = UIStackView(arrangedSubviews: [shareButton, newButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.heightAnchor.constraint(equalToConstant: 46).isActive = true
        return stack
    }

    private func share(from sourceView: UIView?) {
        let activity = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        activity.popoverPresentationController?.sourceView = sourceView ?? view
        present(activity, animated: true)
    }
}
