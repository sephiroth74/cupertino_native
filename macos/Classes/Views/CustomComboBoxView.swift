import Cocoa
import FlutterMacOS

/// A custom combo box built with NSTextField + NSPopover for reliable focus and popup handling.
class CustomComboBoxView: NSView, NSTextFieldDelegate, NSTableViewDelegate, NSTableViewDataSource {
    private let textField = NSTextField()
    private let dropdownButton = NSButton()
    private let popover = NSPopover()
    private let tableView = NSTableView()
    private let scrollView = NSScrollView()

    private var items: [String] = []
    private var isPopoverOpen = false

    private func debugLog(_ message: String) {
        NSLog("[CustomComboBoxView] \(message)")
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        debugLog("setupUI")

        // Text field
        textField.isEditable = true
        textField.placeholderString = "Select or type..."
        textField.stringValue = "Select..."
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textField)

        // Dropdown button
        dropdownButton.bezelStyle = .rounded
        dropdownButton.title = "▼"
        dropdownButton.target = self
        dropdownButton.action = #selector(togglePopover(_:))
        dropdownButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dropdownButton)

        // Configure table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.headerView = nil
        tableView.rowHeight = 24

        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("item"))
        column.width = 200
        tableView.addTableColumn(column)

        // Configure scroll view
        scrollView.documentView = tableView
        scrollView.hasVerticalScroller = true

        // Configure popover
        let popoverViewController = NSViewController()
        popoverViewController.view = scrollView
        popover.contentViewController = popoverViewController
        popover.behavior = .transient
        popover.delegate = self

        // Layout constraints
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.trailingAnchor.constraint(
                equalTo: dropdownButton.leadingAnchor, constant: -4),

            dropdownButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            dropdownButton.topAnchor.constraint(equalTo: topAnchor),
            dropdownButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            dropdownButton.widthAnchor.constraint(equalToConstant: 28),
        ])
    }

    func setItems(_ newItems: [String]) {
        items = newItems
        debugLog("setItems count=\(items.count)")
        tableView.reloadData()
    }

    @objc private func togglePopover(_ sender: Any) {
        debugLog("togglePopover called, isPopoverOpen=\(isPopoverOpen)")

        if isPopoverOpen {
            closePopover()
        } else {
            openPopover()
        }
    }

    private func openPopover() {
        debugLog("openPopover start")

        // Ensure text field is first responder
        window?.makeFirstResponder(textField)

        // Position popover below the button
        let buttonRect = dropdownButton.bounds
        let rectInWindow = dropdownButton.convert(buttonRect, to: nil)

        isPopoverOpen = true

        // Schedule popover open on next run loop to avoid timing issues
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if !self.isPopoverOpen {
                self.debugLog("openPopover cancelled because popover already closed")
                return
            }
            self.debugLog("openPopover executing")
            self.popover.show(
                relativeTo: rectInWindow, of: self.dropdownButton.window!.contentView!,
                preferredEdge: .minY)
        }
    }

    private func closePopover() {
        debugLog("closePopover")
        isPopoverOpen = false
        popover.close()
    }

    // MARK: - NSTableViewDataSource

    func numberOfRows(in tableView: NSTableView) -> Int {
        return items.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int)
        -> Any?
    {
        return items[row]
    }

    // MARK: - NSTableViewDelegate

    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectedRow = tableView.selectedRow
        guard selectedRow >= 0 && selectedRow < items.count else {
            debugLog("tableViewSelectionDidChange invalid row=\(selectedRow)")
            return
        }

        let selectedItem = items[selectedRow]
        debugLog("tableViewSelectionDidChange row=\(selectedRow) item=\(selectedItem)")

        textField.stringValue = selectedItem
        closePopover()
    }
}

// MARK: - NSPopoverDelegate

extension CustomComboBoxView: NSPopoverDelegate {
    func popoverDidClose(_ notification: Notification) {
        debugLog("popoverDidClose")
        isPopoverOpen = false
    }
}
