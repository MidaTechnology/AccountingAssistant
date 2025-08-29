//
//  Mock.swift
//  AccountingAssistant
//
//  Created by mathwallet on 2025/8/27.
//

import Foundation

struct Mock {
    /// 随机生成今日消费文本
    /// - Returns: 消费文本
    static func randomAccountingText() -> String {
        let texts: [String] = [
            "今天天气真好呀，我骑车共享单车上班花了2.5元，路过一个包子店买了两个大肉包6块钱。然后在公司上了9个小时的班后，我乘坐2块钱的轮渡去了陆家嘴，花了200元买了东方明珠的门票，夜览了上海全貌。",
            "周末我吃过5元的早餐后，步行去公园，没想到路上捡到了100元大钞，那是真的开心啊！于是我买了奶茶、看了电影共花了188。看来还是不能捡钱啊！",
            "工资3800到账，开心了5分钟后，我还了5800的房贷。"
        ]
        return texts[Int.random(in: 0..<texts.count)]
    }
    
    /// 随机生成演示账单
    /// - Returns: 消费文本
    static func randomAccountings() -> [Accounting] {
        let calendar = Calendar.current
        let today = Date()
        var components = calendar.dateComponents([.year, .month, .day], from: today)
        components.hour = 0
        components.minute = 0
        components.second = 0
        guard let todayAm0 = calendar.date(from: components) else {
            return []
        }
        
        // 生成 offsetDays 天数的数据
        var accountings: [Accounting] = []
        let offsetDays: Int = 90
        
        let breakfastFoods = ["早餐", "KFC 满分", "豆浆+油条", "包子", "鸡蛋灌饼", "玉米", "饭团"]
        let lunchFoods = ["午餐", "炒菜", "火锅🍲", "饺子🥟", "面条", "麦当劳"]
        let dinnerFoods = ["晚餐", "炒菜", "火锅🍲", "饺子🥟", "面条", "麦当劳", "烧烤"]
        
        for i in 0..<offsetDays {
            guard let date = calendar.date(byAdding: .day, value: -i, to: todayAm0) else {
                break
            }
            let day = Calendar.current.component(.day, from: date)
            let week = Calendar.current.component(.weekday, from: date)
            
            // 8点
            guard let am8 = calendar.date(byAdding: .hour, value: 8, to: date) else {
                break
            }
            accountings.append(Accounting(
                date: am8,
                category: .Food,
                amount: Decimal(-Double.random(in: 6...12)),
                desc: breakfastFoods[Int.random(in: 0..<breakfastFoods.count)]
            ))
            // 12点
            guard let pm12 = calendar.date(byAdding: .hour, value: 4, to: am8) else {
                break
            }
            accountings.append(Accounting(
                date: pm12,
                category: .Food,
                amount: Decimal(-Double.random(in: 15...50)),
                desc: lunchFoods[Int.random(in: 0..<lunchFoods.count)]
            ))
            // 17点
            guard let pm17 = calendar.date(byAdding: .hour, value: 5, to: pm12) else {
                break
            }
            accountings.append(Accounting(
                date: pm17,
                category: .Food,
                amount: Decimal(-Double.random(in: 10...30)),
                desc: dinnerFoods[Int.random(in: 0..<dinnerFoods.count)]
            ))
            // 排除周末
            if [2, 3, 4, 5, 6].contains(week) {
                accountings.append(Accounting(
                    date: am8,
                    category: .Transportation,
                    amount: Decimal(-5),
                    desc: "乘地铁"
                ))
                accountings.append(Accounting(
                    date: pm17,
                    category: .Transportation,
                    amount: Decimal(-5),
                    desc: "乘地铁"
                ))
            }
            
            // 20点
            // 每月10号 工资
            // 每月15号 房租
            guard let pm20 = calendar.date(byAdding: .hour, value: 3, to: pm17) else {
                break
            }
            if day == 10 {
                accountings.append(Accounting(
                    date: pm20,
                    category: .Salary,
                    amount: Decimal(8888),
                    desc: "工资"
                ))
            } else if day == 15 {
                accountings.append(Accounting(
                    date: pm20,
                    category: .Rent,
                    amount: Decimal(-4800),
                    desc: "交房租🏡"
                ))
            }
        }

        return accountings
    }
}
