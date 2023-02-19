//
//  AppUtility.swift
//  Photo Wall
//
//  Created by Leo Ho on 2023/2/19.
//

import Foundation

struct AppUtility {
    
    /// 取得送出、更新留言的當下時間
    static func getSystemTime() -> String {
        let currectDate = Date()
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale.ReferenceType.system
        dateFormatter.timeZone = TimeZone.ReferenceType.system
        return dateFormatter.string(from: currectDate)
    }
}
