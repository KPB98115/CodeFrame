//
//  TimeFormatter.swift
//  CodeFrame
//
//  Created by 施家浩 on 2024/2/9.
//

import Foundation

func dateFormatter(date: Date) -> String {
    let formatter = DateFormatter()
    
    formatter.dateFormat = "MMM d, yyyy HH:mm:ss"
    return formatter.string(from: date)
}
