//
//  SearchBarTranscribeButton.swift
//  CountriesExplorer
//
//  Created by Ashleigh Kaffenberger on 5/6/24.
//

import SwiftUI

struct SearchBarTranscribeButton: ViewModifier {
    let text: Binding<String>
    
    func body(content: Content) -> some View {
        SearchBarTranscribeButtonView(text: text) {
            content
        }
    }
}

extension View {
    func searchBarTranscribeButton(text: Binding<String>) -> some View {
        modifier(SearchBarTranscribeButton(text: text))
    }
}

struct SearchBarTranscribeButtonView<V: View>: UIViewControllerRepresentable {
    var text: Binding<String>
    var content: () -> V
    
    func makeUIViewController(context: Context) -> ViewController {
        return ViewController(rootView: content())
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        uiViewController.text = text
        uiViewController.rootView = content()
    }
    
    class ViewController: UIHostingController<V> {
        
        var text: Binding<String>?
        
        @Inject(\.speechService) private var speechService
        private var isTranscribing: Bool = false
        
        private lazy var button: UIButton = {
            let button = UIButton()
            button.tintColor = .gray
            button.accessibilityIdentifier = "SearchBarTranscribeButton"
            button.setImage(UIImage(systemName: "mic.fill"), for: .normal)
            button.addTarget(self, action: #selector(onTap), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
        
        override func viewWillLayoutSubviews() {
            super.viewWillLayoutSubviews()
            
            if let searchBar = findSearchController(on: self)?.searchBar {
                if !searchBar.contains(button) {
                    searchBar.addSubview(button)
                    searchBar.searchTextField.clearButtonMode = .never
                    button.topAnchor.constraint(equalTo: searchBar.searchTextField.topAnchor).isActive = true
                    button.trailingAnchor.constraint(equalTo: searchBar.searchTextField.trailingAnchor, constant: -6).isActive = true
                    button.bottomAnchor.constraint(equalTo: searchBar.searchTextField.bottomAnchor).isActive = true
                }
            }
        }
        
        private func findSearchController(on controller: UIViewController) -> UISearchController? {
            if let searchController = controller.navigationItem.searchController {
                return searchController
            } else if let parent = controller.parent {
                return findSearchController(on: parent)
            } else {
                return nil
            }
        }

        @objc func onTap() {
            if isTranscribing {
                speechService.stopTranscribing()
                button.setImage(UIImage(systemName: "mic.fill"), for: .normal)
                isTranscribing = false
            } else {
                Task {
                    if await speechService.authorized() {
                        speechService.startTranscribing(text)
                        button.setImage(UIImage(systemName: "mic.fill.badge.xmark"), for: .normal)
                        isTranscribing = true
                    } else {
                        let alert = UIAlertController(title: "Authorize Speech to Text", message: "Please authorize speech to text in app settings!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        present(alert, animated: true)
                    }
                }
            }
        }
    }
}
