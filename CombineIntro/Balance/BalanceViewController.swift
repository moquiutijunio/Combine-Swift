//
//  BalanceViewController.swift
//  CombineIntro
//
//  Created by Junio Cesar Moquiuti on 18/08/21.
//

import Combine
import Foundation
import UIKit

@dynamicMemberLookup
final class BalanceViewController: UIViewController {
    
    // MARK: - Properties
    private let rootView = BalanceView()
    private let viewModel: BalanceViewModel
    private let formatDate: (Date) -> String
    private lazy var cancellables = Set<AnyCancellable>()

    // MARK: - Life Cycle
    init(
        viewModel: BalanceViewModel,
        formatDate: @escaping (Date) -> String = BalanceViewState.relativeDateFormatter.string(from:)
    ) {
        self.viewModel = viewModel
        self.formatDate = formatDate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        binds()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.viewDidAppear()
    }

    // MARK: - Methods
    private func binds() {
        viewModel.stateSubject
            .sink { [weak self] _ in self?.updateView() }
            .store(in: &cancellables)
        
        rootView.refreshButton
            .touchUpInsidePublisher
            .sink(receiveValue: viewModel.refreshBalance)
            .store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: UIApplication.willResignActiveNotification)
            .sink { [viewModel] _ in viewModel.updateState(isRedacted: true) }
            .store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [viewModel] _ in viewModel.updateState(isRedacted: false) }
            .store(in: &cancellables)
    }
    
    private func updateView() {
        rootView.refreshButton.isHidden = viewModel.stateSubject.value.isRefreshing
        if viewModel.stateSubject.value.isRefreshing {
            rootView.activityIndicator.startAnimating()
        } else {
            rootView.activityIndicator.stopAnimating()
        }
        rootView.valueLabel.text = viewModel.stateSubject.value.formattedBalance
        rootView.valueLabel.alpha = viewModel.stateSubject.value.isRedacted ? BalanceView.alphaForRedactedValueLabel : 1
        rootView.infoLabel.text = viewModel.stateSubject.value.infoText(formatDate: formatDate)
        rootView.infoLabel.textColor = viewModel.stateSubject.value.infoColor
        rootView.redactedOverlay.isHidden = !viewModel.stateSubject.value.isRedacted

        view.setNeedsLayout()
    }
}

// MARK: - SwiftUI Preview
#if DEBUG
import SwiftUI

struct BalanceViewController_Previews: PreviewProvider {
    static private func makePreview() -> some View {
        BalanceViewController(viewModel: BalanceViewModel(service: FakeBalanceService()))
            .staticRepresentable
    }

    static var previews: some View {
        Group {
            makePreview()
                .preferredColorScheme(.dark)

            makePreview()
                .preferredColorScheme(.light)
        }
    }
}

// To help with tests
extension BalanceViewController {
    subscript<T>(dynamicMember keyPath: KeyPath<BalanceView, T>) -> T {
        rootView[keyPath: keyPath]
    }
}
#endif
