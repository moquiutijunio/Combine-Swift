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
    
    private lazy var touchUpInsideSubject: PassthroughSubject<UIEvent, Never> = {
        let subject = PassthroughSubject<UIEvent, Never>()
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        return subject
    }()
    
    var touchUpInsidePublisher: AnyPublisher<UIEvent, Never> {
        return touchUpInsideSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
// MARK: - Handlers
extension PublisherButton {
    @objc private func handleTap(event: UIEvent) {
        touchUpInsideSubject.send(event)
    }
}

// MARK: - Public Functions
extension PublisherButton {
    public func drive(onNext: @escaping ((UIEvent) -> Void)) {
        butonCancellable = touchUpInsidePublisher
            .sink(receiveValue: onNext)
    }
}
