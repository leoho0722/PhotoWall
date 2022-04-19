//
//  CustomTabBarFooterView.swift
//  PhotoKit Demo
//
//  Created by Leo Ho on 2022/4/18.
//

import UIKit

class CustomTabBarFooterView: UIView {
    
    @IBOutlet weak var left: CustomFavoriteButton!
    @IBOutlet weak var mid: CustomFavoriteButton!
    @IBOutlet weak var right: CustomFavoriteButton!
    
    var photoOp: ((Int) -> ())? = nil
    
    override func awakeFromNib() {
        addXibView()
    }
    
    // view 在設計時想要看到畫面要用這個
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        addXibView()
    }
    
    // MARK: - 客製化元件樣式初始化
    
    func setInit(isDarkMode: Bool) {
        left.setInit(bgViewColor: (isDarkMode) ? .lightText : .darkText,
                     btnBgColor: (isDarkMode) ? .lightText : .darkText,
                     buttonIndex: 0,
                     icon: UIImage(systemName: "heart")!,
                     iconImageContentMode: .scaleAspectFit,
                     labelText: "Favorite",
                     labelTintColor: (isDarkMode) ? .darkText : .lightText,
                     labelFontStyle: .normal,
                     labelFontSize: 17,
                     delegate: self)
        
        mid.setInit(bgViewColor: (isDarkMode) ? .lightText : .darkText,
                    btnBgColor: (isDarkMode) ? .lightText : .darkText,
                    buttonIndex: 1,
                    icon: UIImage(systemName: "play.circle.fill")!,
                    iconImageContentMode: .scaleAspectFit,
                    labelText: "Play",
                    labelTintColor: (isDarkMode) ? .darkText : .lightText,
                    labelFontStyle: .normal,
                    labelFontSize: 17,
                    delegate: self)
        
        right.setInit(bgViewColor: (isDarkMode) ? .lightText : .darkText,
                      btnBgColor: (isDarkMode) ? .lightText : .darkText,
                      buttonIndex: 2,
                      icon: UIImage(systemName: "trash")!,
                      iconImageContentMode: .scaleAspectFit,
                      labelText: "Trash",
                      labelTintColor: (isDarkMode) ? .darkText : .lightText,
                      labelFontStyle: .normal,
                      labelFontSize: 17,
                      delegate: self)
    }
}

// MARK: - 

fileprivate extension CustomTabBarFooterView {
    // 加入畫面
    func addXibView() {
        if let loadView = Bundle(for: CustomTabBarFooterView.self).loadNibNamed("CustomTabBarFooterView", owner: self, options: nil)?.first as? UIView{
            addSubview(loadView)
            loadView.frame = bounds
        }
    }
}

// MARK: - CustomFavoriteButtonDelegate 實作

extension CustomTabBarFooterView: CustomFavoriteButtonDelegate {
    func target(index: Int) {
        switch index {
        case 0:
            photoOp?(index)
            break
        case 1:
            photoOp?(index)
            break
        case 2:
            photoOp?(index)
            break
        default:
            break
        }
    }
}
