//
//  KeyboardViewController.swift
//  CreatureTypeKeyboard
//
//  Created by Zach Wardlaw on 5/6/25.
//

import UIKit

// MARK: - Scryfall Models

struct ScryfallAutocomplete: Codable {
    let data: [String]
}

struct ScryfallCard: Codable {
    let name: String
    let image_uris: ImageURIs?
    let id: String
}

struct ImageURIs: Codable {
    let normal: String
}

class KeyboardViewController: UIInputViewController {

    // MARK: - Image Cache
    class ImageCache {
        static let shared = ImageCache()
        private var cache = NSCache<NSString, UIImage>()

        func image(forKey key: String) -> UIImage? {
            return cache.object(forKey: key as NSString)
        }

        func setImage(_ image: UIImage, forKey key: String) {
            cache.setObject(image, forKey: key as NSString)
        }
    }


    let textField = UITextField()
    let toggleButton = UIButton(type: .system)
    let tableView = UITableView()
    let collectionView: UICollectionView
    var imageResults: [ScryfallCard] = []
    var showingImages = false

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 120, height: 167)
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 0
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.backgroundColor = UIColor(red: 46/255, green: 23/255, blue: 13/255, alpha: 1.0)

        textField.placeholder = "Type card name"
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 8
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.layer.borderWidth = 1
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.font = UIFont(name: "Goudy Mediaeval Regular", size: 16)
        view.addSubview(textField)

        toggleButton.setTitle("Show Images", for: .normal)
        toggleButton.titleLabel?.font = UIFont(name: "Goudy Mediaeval Regular", size: 16)
        toggleButton.setTitleColor(.white, for: .normal)
        toggleButton.addTarget(self, action: #selector(toggleView), for: .touchUpInside)
        toggleButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toggleButton)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(AutocompleteCell.self, forCellReuseIdentifier: "AutocompleteCell")
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        view.addSubview(tableView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CardImageCell.self, forCellWithReuseIdentifier: "CardImageCell")
        collectionView.backgroundColor = .clear
        collectionView.isHidden = true
        collectionView.contentInset = .zero
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),

            toggleButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 10),
            toggleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            tableView.topAnchor.constraint(equalTo: toggleButton.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            tableView.heightAnchor.constraint(equalToConstant: 170),

            collectionView.topAnchor.constraint(equalTo: toggleButton.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 180)
        ])
        
        

        addKeyboardButtons()
    }
    
    

    @objc func toggleView() {
        showingImages.toggle()
        collectionView.isHidden = !showingImages
        tableView.isHidden = showingImages
        toggleButton.setTitle(showingImages ? "Show Names" : "Show Images", for: .normal)
        toggleButton.setTitleColor(UIColor.white, for: .normal)
    }

    func addKeyboardButtons() {
        let letters = [
            ["Q","W","E","R","T","Y","U","I","O","P"],
            ["A","S","D","F","G","H","J","K","L"],
            ["Z","X","C","V","B","N","M"]
        ]

        var previousRow: UIView? = collectionView

        for rowLetters in letters {
            let row = UIStackView()
            row.axis = .horizontal
            row.alignment = .fill
            row.distribution = .equalSpacing
            row.spacing = 6
            row.translatesAutoresizingMaskIntoConstraints = false

            for letter in rowLetters {
                let button = UIButton(type: .system)
                button.setTitle(letter, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
                button.setTitleColor(.white, for: .normal)
                button.backgroundColor = UIColor(red: 180/255, green: 130/255, blue: 85/255, alpha: 1.0)
                button.layer.cornerRadius = 6
                button.layer.shadowColor = UIColor.black.cgColor
                button.layer.shadowOpacity = 0.1
                button.layer.shadowOffset = CGSize(width: 0, height: 1)
                button.layer.shadowRadius = 1
                button.layer.borderColor = UIColor.black.cgColor
                button.layer.borderWidth = 1
                button.addTarget(self, action: #selector(keyPressed(_:)), for: .touchUpInside)
                button.titleLabel?.font = UIFont(name: "Goudy Mediaeval Regular", size: 16)
                row.addArrangedSubview(button)
            }

            view.addSubview(row)
            NSLayoutConstraint.activate([
                            row.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                            row.heightAnchor.constraint(equalToConstant: 40),
                            row.topAnchor.constraint(equalTo: previousRow!.bottomAnchor, constant: 4)
                        ])

            previousRow = row
        }

        let bottomRow = UIStackView()
        bottomRow.axis = .horizontal
        bottomRow.distribution = .equalSpacing
        bottomRow.spacing = 4
        bottomRow.translatesAutoresizingMaskIntoConstraints = false

        let space = UIButton(type: .system)
        space.widthAnchor.constraint(equalToConstant: 100).isActive = true
        space.setTitle("Space", for: .normal)
        space.titleLabel?.font = UIFont(name: "Goudy Mediaeval Regular", size: 16)
        space.setTitleColor(UIColor.white, for: .normal)
        space.backgroundColor = UIColor(red: 180/255, green: 130/255, blue: 85/255, alpha: 1.0)
        space.layer.cornerRadius = 6
        space.layer.shadowColor = UIColor.black.cgColor
        space.layer.shadowOpacity = 0.1
        space.layer.shadowOffset = CGSize(width: 0, height: 1)
        space.layer.shadowRadius = 1
        space.layer.borderColor = UIColor.black.cgColor
        space.layer.borderWidth = 1
        space.addTarget(self, action: #selector(spacePressed), for: .touchUpInside)

        let backspace = UIButton(type: .system)
        backspace.widthAnchor.constraint(equalToConstant: 60).isActive = true
        backspace.setTitle("⌫", for: .normal)
        backspace.titleLabel?.font = UIFont(name: "Goudy Mediaeval Regular", size: 24  )
        backspace.setTitleColor(UIColor.white, for: .normal)
        backspace.backgroundColor = UIColor(red: 180/255, green: 130/255, blue: 85/255, alpha: 1.0)
        backspace.layer.cornerRadius = 6
        backspace.layer.shadowColor = UIColor.black.cgColor
        backspace.layer.shadowOpacity = 0.1
        backspace.layer.shadowOffset = CGSize(width: 0, height: 1)
        backspace.layer.shadowRadius = 1
        backspace.layer.borderColor = UIColor.black.cgColor
        backspace.layer.borderWidth = 1
        backspace.addTarget(self, action: #selector(backspacePressed), for: .touchUpInside)

        bottomRow.addArrangedSubview(space)
        bottomRow.addArrangedSubview(backspace)

        view.addSubview(bottomRow)
        NSLayoutConstraint.activate([
            bottomRow.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomRow.topAnchor.constraint(equalTo: previousRow!.bottomAnchor, constant: 4),
            bottomRow.heightAnchor.constraint(equalToConstant: 40),
            bottomRow.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -4)
        ])
    }

    @objc func keyPressed(_ sender: UIButton) {
        if let title = sender.title(for: .normal) {
            textField.insertText(title)
        }
    }

    @objc func spacePressed() {
        textField.insertText(" ")
    }

    @objc func backspacePressed() {
        textField.deleteBackward()
    }

    @objc func insertText() {
        guard let cardName = textField.text else { return }
        textDocumentProxy.insertText(cardName)
    }

    @objc func textFieldDidChange() {
        guard let query = textField.text, query.count > 1 else {
            imageResults = []
            tableView.reloadData()
            collectionView.reloadData()
            return
        }
        fetchAutocomplete(query: query)
    }

    func fetchAutocomplete(query: String) {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = URL(string: "https://api.scryfall.com/cards/autocomplete?q=\(encoded)")!
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            if let result = try? JSONDecoder().decode(ScryfallAutocomplete.self, from: data) {
                DispatchQueue.main.async {
                    self.imageResults = []
                    for name in result.data.prefix(10) {
                        self.fetchCardData(for: name)
                    }
                }
            }
        }.resume()
    }

    func fetchCardData(for cardName: String) {
        let encoded = cardName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = URL(string: "https://api.scryfall.com/cards/named?exact=\(encoded)")!
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            if let card = try? JSONDecoder().decode(ScryfallCard.self, from: data) {
                DispatchQueue.main.async {
                    self.imageResults.append(card)
                    self.tableView.reloadData()
                    self.collectionView.reloadData()
                }
            }
        }.resume()
    }
}

extension KeyboardViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageResults.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AutocompleteCell", for: indexPath) as! AutocompleteCell
        cell.label.text = imageResults[indexPath.row].name
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = imageResults[indexPath.row].image_uris?.normal {
            textDocumentProxy.insertText(url)
        }
    }
    
}


class AutocompleteCell: UITableViewCell {
    let label = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true

        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont(name: "Goudy Mediaeval Regular", size: 22)
        contentView.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



class CardImageCell: UICollectionViewCell {
    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 7
        imageView.backgroundColor = .clear
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        imageView.layer.shadowOpacity = 0.2
        imageView.layer.shadowRadius = 2
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension KeyboardViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let card = imageResults[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardImageCell", for: indexPath) as! CardImageCell
        
        if let imageURL = card.image_uris?.normal, let url = URL(string: imageURL) {
            if let cached = ImageCache.shared.image(forKey: imageURL) {
                cell.imageView.image = cached
            } else {
                cell.imageView.image = nil
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    guard let data = data, let image = UIImage(data: data) else { return }
                    ImageCache.shared.setImage(image, forKey: imageURL)
                    DispatchQueue.main.async {
                        if collectionView.indexPath(for: cell) == indexPath {
                            cell.imageView.alpha = 0
                            cell.imageView.image = image
                            UIView.animate(withDuration: 0.3) {
                                cell.imageView.alpha = 1
                            }
                        }
                    }
                }.resume()
            }
        } else {
            cell.imageView.image = nil
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let url = imageResults[indexPath.item].image_uris?.normal {
            textDocumentProxy.insertText(url)
        }
    }
    

}
