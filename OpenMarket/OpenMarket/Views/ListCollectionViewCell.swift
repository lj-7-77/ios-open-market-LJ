//
//  ListCollectionViewCell.swift
//  OpenMarket
//
//  Created by Kyo, LJ on 2022/11/21.
//

import UIKit

final class ListCollectionViewCell: UICollectionViewCell {
    private var discountPrice: Double = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let indicatorView: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    private let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let productNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let productPriceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let productSalePriceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let productStockLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.init(systemName: "chevron.right"), for: .normal)
        button.tintColor = .gray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var priceLabelStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [productPriceLabel,
                                                       productSalePriceLabel])
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var ProductLabelStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [productNameLabel,
                                                       priceLabelStackView])
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var ProductStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [productImageView,
                                                      ProductLabelStackView])
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    func setupProductImage(with productThumnail: String) {
        indicatorView.startAnimating()
        
        let cacheKey = NSString(string: productThumnail)
        if let cachedImage = ImageCacheManager.shared.object(forKey: cacheKey) {
            uploadImage(cachedImage)
            return
        }
        
        guard let imageURL = URL(string: productThumnail) else { return }
        
        DispatchQueue.global().async { [weak self] in
            guard let data = try? Data(contentsOf: imageURL),
                  let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                ImageCacheManager.shared.setObject(image, forKey: cacheKey)
                self?.uploadImage(image)
            }
        }
    }
    
    private func uploadImage(_ image: UIImage) {
        productImageView.image = image
        indicatorView.stopAnimating()
        indicatorView.isHidden = true
    }
    
    func setupData(with productData: Product) {
        discountPrice = productData.discountedPrice
        
        productNameLabel.text = productData.name
        productPriceLabel.text = String(productData.price)
        productSalePriceLabel.text = String(productData.bargainPrice)
        productStockLabel.text = productData.stockDescription
        
        setupStockLabel()
        setupPriceLabel()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        clearPriceLabel()
        
        productImageView.image = nil
        productNameLabel.text = nil
        productPriceLabel.text = nil
        productSalePriceLabel.text = nil
        productStockLabel.text = nil
    }
    
    private func applyStrikeThroughStyle(label: UILabel) {
        let attributeString = NSMutableAttributedString(string: label.text ?? "")
        attributeString.addAttribute(.strikethroughStyle,
                                     value: NSUnderlineStyle.single.rawValue,
                                     range: NSMakeRange(0, attributeString.length))
        label.attributedText = attributeString
    }
}

// MARK: - Constraints
extension ListCollectionViewCell {
    private func setupUI() {
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 10
        contentView.layer.borderColor = UIColor.gray.cgColor
        setupView()
    }
    
    private func setupView() {
        contentView.addSubview(indicatorView)
        contentView.addSubview(ProductStackView)
        contentView.addSubview(productStockLabel)
        contentView.addSubview(nextButton)
        
        setupStackViewConstraints()
        setupIndicatorViewConstraints()
    }
    
    private func setupStockLabel() {
        if productStockLabel.text == "품절" {
            productStockLabel.textColor = .systemOrange
        } else {
            productStockLabel.textColor = .gray
        }
    }
    
    private func setupPriceLabel() {
        if  discountPrice == Double.zero {
            productSalePriceLabel.isHidden = true
        } else {
            productSalePriceLabel.isHidden = false
            productPriceLabel.textColor = .red
            applyStrikeThroughStyle(label: productPriceLabel)
        }
    }
    
    private func clearPriceLabel() {
        productPriceLabel.isHidden = false
        productPriceLabel.textColor = .gray
        productPriceLabel.attributedText = .none
    }
    
    func setupStackViewConstraints() {
        NSLayoutConstraint.activate([
            productImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.25),
            
            ProductStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            ProductStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            ProductStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            
            productStockLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            productStockLabel.leadingAnchor.constraint(equalTo: ProductStackView.trailingAnchor, constant: 40),
            nextButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nextButton.leadingAnchor.constraint(equalTo: productStockLabel.trailingAnchor, constant: 5),
            nextButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
    
    func setupIndicatorViewConstraints() {
        NSLayoutConstraint.activate([
            indicatorView.topAnchor.constraint(equalTo: productImageView.topAnchor),
            indicatorView.leadingAnchor.constraint(equalTo: productImageView.leadingAnchor),
            indicatorView.trailingAnchor.constraint(equalTo: productImageView.trailingAnchor)
        ])
    }
}

extension ListCollectionViewCell: ReuseIdentifierProtocol {
    
}
