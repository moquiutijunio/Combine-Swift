//
//  BalanceViewModel.swift
//  CombineIntro
//
//  Created by Junio Cesar Moquiuti on 06/09/21.
//

import Combine
import Foundation

final class BalanceViewModel {
    
    // MARK: - Properties
    private let service: BalanceService
    let stateSubject = CurrentValueSubject<BalanceViewState, Never>(.init())
    
    // MARK: - Life Cycle
    init(service: BalanceService) {
        self.service = service
    }
    
    // MARK: - Methods
    func viewDidAppear() {
        refreshBalance()
    }
    
    func updateState(isRedacted: Bool) {
        stateSubject.value.isRedacted = isRedacted
    }
    
    func refreshBalance() {
        stateSubject.value.didFail = false
        stateSubject.value.isRefreshing = true
        service.refreshBalance { [weak self] result in
            self?.handleResult(result)
        }
    }
    
    private func handleResult(_ result: Result<BalanceResponse, Error>) {
        stateSubject.value.isRefreshing = false
        do {
            stateSubject.value.lastResponse = try result.get()
        } catch {
            stateSubject.value.didFail = true
        }
    }
}
