//
//  ViewController.swift
//  PokemonBrowser
//
//  Created by Matthew Ruston on 3/9/19.
//  Copyright © 2019 Under Armour, Inc. All rights reserved.
//

import UIKit
import AlamofireImage
import Pokedex

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    let imageCache = AutoPurgingImageCache()
    let pokedex = Pokedex()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.black.cgColor
    }
    
    func lookup(pokemon number: Int) {
        
        pokedex.fetch(pokemon: number) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let pokemon):
                    self.titleLabel.text = pokemon.name
                    
                    if let image = pokemon.sprites.frontDefault {
                        self.show(image: image)
                    }
                    
                case .error:
                    self.titleLabel.text = "Unknown pokemon"
                }
            }
        }
        
    }
    
    func show(image path: String) {
        guard let url = URL(string: path) else {
            return
        }
        
        let request = URLRequest(url: url)
        
        if let image = imageCache.image(for: request) {
            imageView.image = image
            return
        }

        URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self = self, let data = data, let image = UIImage(data: data) else {
                return
            }
            
            self.imageCache.add(image, for: request)
            
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }.resume()
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, let value = Int(text), value > 0, value < 151 else {
            return false
        }
        
        lookup(pokemon: value)
        
        return true
    }
}

