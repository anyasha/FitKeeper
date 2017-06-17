//
//  Simplex.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

class Simplex {
    //source - симплекс таблица без базисных переменных
    var table = [[Double]]() //симплекс таблица
    
    var m = Int()
    var n = Int()
    
    var basis = [Int]() //список базисных переменных
    
    func Simplex(_ source: [[Double]]) {
        m = source[0].count
        n = source[1].count
        //table = new double[m, n + m - 1]
        //basis = new List<int>()
        for i in 0..<m {
            for j in 0..<table[1].count {
                if j < n {
                    table[i][j] = source[i][j]
                } else {
                    table[i][j] = 0
                }
            }
            //выставляем коэффициент 1 перед базисной переменной в строке
            if (n + i) < table[1].count {
                table[i][n + i] = 1
                basis.append(n + i)
            }
        }
        n = table[1].count
    }
    
    //result - в этот массив будут записаны полученные значения X
    func Calculate( _ result: [Double]) -> [[Double]] {
        var result = result
        var mainCol = Int()
        var mainRow = Int() //ведущие столбец и строка
        while IsItEnd() == false {
            mainCol = findMainCol()
            mainRow = findMainRow(mainCol)
            basis[mainRow] = mainCol
    
            var new_table = [[Double]]()
    
            for j in 0..<n {
                new_table[mainRow][j] = table[mainRow][j] / table[mainRow][mainCol]
            }
            for i in 0..<m {
                if i == mainRow {
                    continue
                }
                for j in 0..<n {
                    new_table[i][j] = table[i][j] - table[i][mainCol] * new_table[mainRow][j]
                }
            }
            table = new_table
        }
    
        //заносим в result найденные значения X
        for i in 0..<result.count {
            var k = basis.index(of: i + 1)
            if k != -1 {
                result[i] = table[k!][0]
            } else {
                result[i] = 0
            }
        }
        return table
    }
    
    func IsItEnd() -> Bool {
        var flag = true
    
        for j in 1..<n {
            if table[m - 1][j] < 0 {
                flag = false
                break
            }
        }
        return flag
    }
    
    func findMainCol() -> Int {
        var mainCol = 1
        for j in 2..<n {
            if table[m - 1][j] < table[m - 1][mainCol] {
                mainCol = j
            }
        }
        return mainCol
    }
    
    func findMainRow(_ mainCol: Int) -> Int {
        var mainRow = 0
        for i in 0..<(m - 1) {
            if table[i][mainCol] > 0 {
                mainRow = i
                break
            }
        }
        for i in (mainRow + 1)..<(m - 1) {
            if table[i][mainCol] > 0 && (table[i][0] / table[i][mainCol] < table[mainRow][0] / table[mainRow][mainCol]) {
                mainRow = i
            }
        }
    
    return mainRow
    }
}
