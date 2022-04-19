//
//  CustomFavoriteButton.swift
//  PhotoKit Demo
//
//  Created by Leo Ho on 2022/4/18.
//

import UIKit

class CustomFavoriteButton: UIView {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    var delegate: CustomFavoriteButtonDelegate?
    
    override func awakeFromNib() {
        addXibView()
    }
    
    // view 在設計時想要看到畫面要用這個
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        addXibView()
    }
    
    // MARK: - 客製化元件樣式初始化
    
    func setInit(bgViewColor: UIColor,
                 btnBgColor: UIColor, buttonIndex: Int,
                 icon: UIImage, iconImageContentMode: UIImageView.ContentMode,
                 labelText: String?, labelTintColor: UIColor, labelFontStyle: SystemFontStyle, labelFontSize: CGFloat,
                 delegate: CustomFavoriteButtonDelegate) {
        setBackgroundView(backgroundColor: bgViewColor)
        setButton(backgroundColor: btnBgColor, buttonTitle: "", buttonIndex: buttonIndex)
        setIconImageView(icon: icon, iconImageContentMode: iconImageContentMode)
        setLabel(labelText: labelText, textTintColor: labelTintColor, fontStyle: labelFontStyle, fontSize: labelFontSize)
        self.delegate = delegate
    }
    
    // MARK: 設定底層的 View
    
    private func setBackgroundView(backgroundColor bgColor: UIColor) {
        backgroundView.layer.cornerRadius = backgroundView.bounds.height / 2
        backgroundView.backgroundColor = bgColor
        backgroundView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: backgroundView.bounds.width, height: backgroundView.bounds.height))
    }
    
    // MARK: 設定底層的 Button
    
    private func setButton(backgroundColor bgColor: UIColor, buttonTitle title: String?, buttonIndex tag: Int) {
        button.layer.cornerRadius = button.bounds.height / 2
        button.backgroundColor = bgColor
        button.setTitle(title, for: .normal)
        button.tag = tag
        button.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: button.bounds.width, height: button.bounds.height))
    }
    
    // MARK: 設定 icon Image
    
    private func setIconImageView(icon image: UIImage, iconImageContentMode contentMode: UIImageView.ContentMode) {
        icon.image = image
        icon.contentMode = contentMode
    }
    
    // MARK: 設定 Label
    
    private func setLabel(labelText text: String?, textTintColor tintColor: UIColor, fontStyle: SystemFontStyle, fontSize: CGFloat) {
        label.text = text
        label.textColor = tintColor
        label.font = chooseSystemFontStyle(systemFontStyle: fontStyle, fontSize: fontSize)
    }
    
    // MARK: - 設定字體樣式
    
    enum SystemFontStyle {
        case normal
        case bold
        case italic
    }
    func chooseSystemFontStyle(systemFontStyle fontStyle: SystemFontStyle, fontSize: CGFloat) -> UIFont {
        switch fontStyle {
        case .normal:
            return UIFont.systemFont(ofSize: fontSize)
        case .bold:
            return UIFont.boldSystemFont(ofSize: fontSize)
        case .italic:
            return UIFont.italicSystemFont(ofSize: fontSize)
        }
    }

    // MARK: - 點擊按鈕後要做的事
    
    @IBAction func buttonClicked(_ sender: UIButton) {
        delegate?.target(index: sender.tag)
    }
}

// MARK: -

fileprivate extension CustomFavoriteButton {
    // 加入畫面
    func addXibView() {
        if let loadView = Bundle(for: CustomFavoriteButton.self).loadNibNamed("CustomFavoriteButton", owner: self, options: nil)?.first as? UIView{
            addSubview(loadView)
            loadView.frame = bounds
        }
    }
}

// MARK: - CustomFavoriteButtonDelegate

protocol CustomFavoriteButtonDelegate: NSObjectProtocol {
    func target(index: Int)
}
