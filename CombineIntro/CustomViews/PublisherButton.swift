//
//  PublisherButton.swift
//  CombineIntro
//
//  Created by Junio Cesar Moquiuti on 18/08/21.
//

import UIKit
import Combine

final class PublisherButton: UIButton {
    
    // MARK: - Properties
    private var butonCancellable: AnyCancellable?
    
    private lazy var touchUpInsideSubject: PassthroughSubject<Void, Never> = {
        let subject = PassthroughSubject<Void, Never>()
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        return subject
    }()
    
    var touchUpInsidePublisher: AnyPublisher<Void, Never> {
        return touchUpInsideSubject
            .eraseToAnyPublisher()
    }
}
// MARK: - Handlers
extension PublisherButton {
    @objc private func handleTap() {
        touchUpInsideSubject.send()
    }
}
