//
//  SimplexMethod.swift
//  FitKeeper
//  Copyright © 2017 FitKeeper. All rights reserved.
//

class SimplexMethod {
    
    var table = [[Double]]() //симплекс таблица
    var m = Int()
    var n = Int()
    
    var basis = [Int]() //список базисных переменных
    
    init (source: [[Double]],  type: String,  rezult: [Double]) {
        m = source[0].count
        n = source[1].count
        var counter = 0
        for i in 0..<m {
            if source[i][0] < 0 {
                counter += 1
            }
        }
        if counter == 0 {
            OneSimplex(source)
        } else {
            DoubleSimplex(source, counter)
            Calculate(rezult, type, false)
        }
    }
    
    func DoubleSimplex(_ source: [[Double]], _ counter: Int) {
        //table = new double[m + 1, n + m - 1 + counter];
       // basis = new List<int>();
        var iter = 0
        for i in 0..<m {
            if source[i][0] >= 0 {
                for j in 0..<table[1].count {
                    if j < n {
                        table[i][j] = source[i][j]
                    } else {
                        table[i][j] = 0
                    }
                }
         //выставляем коэффициент 1 перед базисной переменной в строке
                if (n + i) >= table[1].count - 1 {
                    continue
                }
                table[i][n + i] = 1
                basis.append(n + i)
        } else {
                for j in 0..<table[1].count {
                    if j < n {
                        table[i][j] = -source[i][j]
                    } else {
                        table[i][j] = 0
                    }
                }
                if (n + i) < table[1].count {
                    table[i][n + i] = -1
                }
                for j in 0..<table[1].count {
                    table[m][j] += table[i][j]
                }
                if (n + m + iter) <= table[1].count {
                    table[i][n + m + iter - 1] = 1
                    basis.append(n + m + iter - 1)
                    iter += 1
                }
            }
        }
        Calculate([Double](), "min", true)
        var tableCopy = [[Double]]()
        for i in 0..<(table[0].count - 1) {
            for j in 0..<(table[1].count - counter) {
                tableCopy[i][j] = table[i][j]
            }
        }
        table = tableCopy
        n = table[0].count
    }
    
    func OneSimplex(_ source: [[Double]]) {
        //table = new double[m, n + m - 1];
        //basis = new List<int>();
    
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
    
    func Calculate(  _ result: [Double], _ type: String, _ isDoubleSimplex: Bool) -> [[Double]] {
        var result = result
        var mainCol = Int()
        var mainRow = Int() //ведущие столбец и строка
        var counter = 0
        while isDoubleSimplex == true ? IsItEndDouble() == false : IsItEnd(type) == false {
            if isDoubleSimplex == true {
                mainCol = findMainColDouble()
                mainRow = findMainRowDouble(mainCol)
            } else {
                mainCol = findMainCol(type)
                mainRow = findMainRow(mainCol)
            }
    
            basis[mainRow] = mainCol
            var new_table = [[Double]]()
            for j in 0..<table[1].count {
                new_table[mainRow][j] = table[mainRow][j] / table[mainRow][mainCol]
            }
    
            for i in 0..<table[0].count {
                if i == mainRow {
                    continue
                }
    
                for j in 0..<table[1].count {
                    new_table[i][j] = table[i][j] - table[i][mainCol] * new_table[mainRow][j]
                }
                table = new_table
                counter += 1
//                if counter == 10000 {
//                    throw  NotSupportedException()
//                }
            }
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
    
    func IsItEnd(_ type: String) -> Bool {
        var flag = true

        for j in 1..<table[1].count {
            if table[m - 1][j] < 0 && type == "max" {
                flag = false
                break
            } else if table[m - 1][j] > 0 && type == "min" {
                flag = false
                break
            }
        }
        return flag
    }
    
    func IsItEndDouble() -> Bool {
        var flag = true
        for j in 1..<table[1].count {
            if table[m][j] > 0 {
                flag = false
                break
            }
        }
        return flag
    }
    
    func findMainCol(_ type: String) -> Int {
        if type == "max" {
            var mainCol = 1
            for j in 2..<table[1].count {
                if table[table[0].count - 1][j] < table[table[0].count - 1][mainCol] {
                    mainCol = j
                }
            }
            return mainCol
        } else {
            return findMainColDouble()
        }
    }
    
    func findMainColDouble() -> Int {
        var mainCol = 1
        for j in 2..<table[1].count {
            if table[table[0].count - 1][j] > table[table[0].count - 1][mainCol] {
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
    
    func findMainRowDouble(_ mainCol: Int) -> Int {
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
