//
//  sort.swift
//  FitKeeper
//
//  Created by Анна Писаренко on 02.06.17.
//  Copyright © 2017 FitKeeper. All rights reserved.
//

class Algorythm {
    
    var isFromFile = false;
    var tableFile = [[String]]();
    var optFile = [[String]]();
    
    
    var Error = String()
    
    var nameAlgorythm = String()
    
    var resultPM = [Double]()
    var optimumOnePM = Double()
    var optimumTwoPM = Double()
    var optimumThreePM = Double()
    
    var resultCC = [Double]()
    var optimumOneCC = Double()
    var optimumTwoCC = Double()
    var optimumThreeCC = Double()
    
    var resultCon = [Double]()
    var optimumCon = Double()
    var objFunctionCon = [Double]()
    var tableCon = [[Double]]()
    
    var CONST_ONE : Double = 3;
    var CONST_TWO : Double = 3;
    
    var objFunctionsType = [String]()
    
    var objFunctionsPM = [[Double]]()
    
    var objFunctionsCC = [[Double]]()
    
    var tableOnePM = [[Double]]()
    var tableTwoPM = [[Double]]()
    var tableThreePM = [[Double]]()
    
    var tableOneCC = [[Double]]()
    var tableTwoCC = [[Double]]()
    var tableThreeCC = [[Double]]()
    
    var limitationNumber = Int()
    var variableNumber = Int()
    
    func Convolution() {
        //objFunctionCon = new double[variableNumber+1];
        for i in 0..<(variableNumber + 1) {
            objFunctionCon[i] = 0.5 * objFunctionsPM[0][i] * (objFunctionsType[0] == "max" ? 1 : -1) + 0.3 * objFunctionsPM[1][i] * (objFunctionsType[1] == "max" ? 1 : -1) + 0.2 * objFunctionsPM[2][i] * (objFunctionsType[2] == "max" ? 1 : -1);
        }
        for i in 1..<(variableNumber + 1) {
            tableCon[limitationNumber][i] = -1 * objFunctionCon[i];
        }
        //var simplexMethod = SimplexMethod(tableCon, "max", resultCon);
        for i in 1..<(variableNumber + 1) {
            optimumCon += objFunctionCon[i] * resultCon[i - 1];
        }
    }
    
    func Destruct() {
        isFromFile = false
        //tableFile = new List<List<string>>();
        //optFile = new List<List<string>>();
      
        Error = String()
        nameAlgorythm = String()
    
        resultPM.removeAll()
        optimumOnePM = 0
        optimumTwoPM = 0
        optimumThreePM = 0
    
        resultCC.removeAll()
        optimumOneCC = 0
        optimumTwoCC = 0
        optimumThreeCC = 0
        
        resultCon.removeAll()
        optimumCon = 0
        objFunctionCon.removeAll()
        tableCon.removeAll()
    
    
        objFunctionsType.removeAll()
        
        objFunctionsPM.removeAll()
        
        objFunctionsCC.removeAll()
        
        tableOnePM.removeAll()
        tableTwoPM.removeAll()
        tableThreePM.removeAll()
        
        tableOneCC.removeAll()
        tableTwoCC.removeAll()
        tableThreeCC.removeAll()
        
        limitationNumber = 0
        variableNumber = 0
    }
    
    init(_ limitationNumber: Int, _ variableNumber: Int)
    {
        self.limitationNumber = limitationNumber
        self.variableNumber = variableNumber
        //resultCC = new double[variableNumber]
      //  resultPM = new double[variableNumber]
       // resultCon = new double[variableNumber]
    }
    
    func InzializeTableOneLimitations(_ elementsMatrix: [Int], _ elementsMatrixZnach: [Int], _ IsMore: [Bool]) {
        //tableOnePM = new double[limitationNumber+1, variableNumber+1];
        var counter = 0
        for i in 0..<limitationNumber {
            for j in 1..<(variableNumber + 1) {
                tableOnePM[i][j] = Double(elementsMatrix[counter])
                counter += 1
            }
        }
        for j in 0..<limitationNumber {
            tableOnePM[j][0] = Double(elementsMatrixZnach[j])
        }
        for i in 0..<limitationNumber {
            if IsMore[i] == false {
                for j in 0..<(variableNumber + 1){
                    tableOnePM[i][j] *= -1
                }
            }
        }
    
        //tableOneCC = new double[limitationNumber + 1, variableNumber + 1];
        counter = 0
        for i in 0..<limitationNumber {
            for j in 1..<(variableNumber + 1) {
                tableOneCC[i][j] = Double(elementsMatrix[counter])
                counter += 1
            }
        }
        for j in 0..<limitationNumber {
            tableOneCC[j][0] = Double(elementsMatrixZnach[j])
        }
        for i in 0..<limitationNumber {
            if IsMore[i] == false {
                for j in 0..<(variableNumber + 1) {
                    tableOneCC[i][j] *= -1
                }
            }
        }
    
   // tableCon = new double[limitationNumber + 1, variableNumber + 1];
        counter = 0
        for i in 0..<limitationNumber {
            for j in 1..<(variableNumber + 1) {
                tableCon[i][j] = Double(elementsMatrix[counter])
                counter += 1
            }
        }
        for j in 0..<limitationNumber {
            tableCon[j][0] = Double(elementsMatrixZnach[j])
        }
        for i in 0..<limitationNumber {
            if IsMore[i] == false {
                for j in 0..<(variableNumber + 1) {
                    tableCon[i][j] *= -1
                }
            }
        }
    }
    
    func InzializeTableOneObjFunctions(_ elementsMatrix: [Int], _ IsMore: [Bool])
    {
        var counter = 0
        for i in 0..<3  {
            var objFunction = [Double]()
            objFunction[0] = 0
            for j in 1..<(variableNumber + 1) {
                objFunction[j] = Double(elementsMatrix[counter])
                counter += 1
            }
            objFunctionsPM.append(objFunction)
        }
        for VARIABLE in IsMore {
            if VARIABLE == false {
                objFunctionsType.append("max")
            } else {
                objFunctionsType.append("min")
            }
        }
        for i in 0..<objFunctionsPM[0].count {
            tableOnePM[tableOnePM[0].count - 1][i] = -objFunctionsPM[0][i];
        }
        counter = 0
        for i in 0..<3 {
            var objFunction = [Double]()
            objFunction[0] = 0
            for j in 1..<(variableNumber + 1) {
                objFunction[j] = Double(elementsMatrix[counter])
                counter += 1
            }
            objFunctionsCC.append(objFunction)
        }
        for VARIABLE in IsMore {
            if VARIABLE == false {
                objFunctionsType.append("max")
            } else {
                objFunctionsType.append("min")
            }
        }
        for i in 0..<objFunctionsCC[0].count {
            tableOneCC[tableOneCC[0].count - 1][i] = -objFunctionsCC[0][i]
        }
    }
    
    
    func RunAlrorythms() {
       // try {
            RunAlrorythm(&tableOnePM, &tableTwoPM, &tableThreePM, &resultPM, &objFunctionsPM, &optimumOnePM, &optimumTwoPM, &optimumThreePM, "PM");
            RunAlrorythm(&tableOneCC, &tableTwoCC, &tableThreeCC, &resultCC, &objFunctionsCC, &optimumOneCC, &optimumTwoCC, &optimumThreeCC, "CC");
            Convolution()
        //} catch (NotSupportedException ex) {
         //   Error = "No solution"
       // }
    }
    
    func RunAlrorythm(_ tableOne: inout [[Double]], _ tableTwo: inout [[Double]], _ tableThree: inout [[Double]], _ result : inout [Double], _ objFunctions: inout [[Double]], _ optimumOne : inout Double, _ optimumTwo : inout Double, _ optimumThree : inout Double, _ TypeAlgorythm :  String) {
        //try {
        var simplexMethod : SimplexMethod = SimplexMethod(source: tableOne, type: objFunctionsType[0], rezult: result)
            for i in 0..<self.variableNumber {
                objFunctions[0][0] += result[i] * objFunctions[0][i + 1]
            }
            switch TypeAlgorythm {
            case "PM":
                for j in 0..<objFunctions[0].count {
                    tableOne[self.limitationNumber][j] = -1 * objFunctions[0][j]  //написать условие!!!!!!
                }
            case "CC":
                if self.objFunctionsType[0] == "max" {
                    tableOne[self.limitationNumber][0] = -1 * (objFunctions[0][0] - self.CONST_ONE)
                } else if self.objFunctionsType[0] == "min" {
                    tableOne[self.limitationNumber][0] = -1 * (objFunctions[0][0] + self.CONST_ONE)
                }
            default: return
            }
        
       // tableTwo = new double[tableOne.GetLength(0) + 1, tableOne.GetLength(1)];
            for i in 0..<tableOne[0].count {
                for j in 0..<tableOne[0].count {
                    tableTwo[i][j] = tableOne[i][j]
                }
            }
            for j in 0..<objFunctions.count {
                tableTwo[tableOne[0].count][j] = -1 * objFunctions[1][j]
            }
            simplexMethod = SimplexMethod(source: tableTwo, type: objFunctionsType[1], rezult: result)
            for i in 0..<variableNumber {
                //objFunctions[0][0] += result[i]*objFunctions[0][i+1];
                objFunctions[1][0] += result[i] * objFunctions[1][i + 1]
            }
            switch TypeAlgorythm {
            case "PM":
                for j in 0..<objFunctions[0].count {
                    tableTwo[limitationNumber + 1][j] = -1 * objFunctions[1][j]  //написать условие!!!!!!
                }
            case "CC":
                if objFunctionsType[1] == "max" {
                    tableTwo[limitationNumber + 1][0] = -1 * (objFunctions[1][0] - CONST_TWO)
                } else if objFunctionsType[1] == "min" {
                    tableTwo[limitationNumber + 1][0] = -1 * (objFunctions[1][0] + CONST_TWO)
                }
            default: return
            }
        
            //tableThree = new double[tableTwo.GetLength(0) + 1, tableTwo.GetLength(1)];
            for i in 0..<tableTwo[0].count {
                for j in 0..<tableTwo[0].count {
                    tableThree[i][j] = tableTwo[i][j]
                }
            }
            for j in 0..<objFunctions.count {
                tableThree[tableTwo[0].count][j] = -1 * objFunctions[2][j]
            }
            simplexMethod = SimplexMethod(source: tableThree, type: objFunctionsType[2], rezult: result)
            for i in 0..<variableNumber {
            //objFunctions[0][0] += result[i]*objFunctions[0][i+1];
                optimumOne += result[i] * objFunctions[0][i + 1]
                optimumTwo += result[i] * objFunctions[1][i + 1]
                optimumThree += result[i] * objFunctions[2][i + 1]
            }
       // }
        //catch(NotSupportedException ex) {
        //    throw new NotSupportedException()
        //}
    }
}
