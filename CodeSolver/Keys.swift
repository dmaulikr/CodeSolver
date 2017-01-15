//
//  Keys.swift
//  CodeSolver
//
//  Created by Apple on 16/10/25.
//  Copyright © 2016年 Findaldudu. All rights reserved.
//

import Foundation
import Cocoa

//color type: white black blue red yellow green
enum Color:String {
    case white = "White"
    case black = "Black"
    case blue = "Blue"
    case red = "Red"
    case yellow = "Yellow"
    case green = "Green"
}

//Keys: One line of guess, combination of six colors
class Keys {
    //array of colors in the guess
    let colors:[Color]
    
    //initialize with a guess
    init(newColor:[Color])
    {
        colors = newColor
    }
    
    //comparing with another key, gives hint
    func compareTo(new:Keys) -> (Int,Int) {
        var a = colors
        var b = new.colors
        var black = 0
        var white = 0
        var i = 0
        while i<a.count
        {
            if(a[i] == b[i])
            {
                black += 1
                a.remove(at: i)
                b.remove(at: i)
                i -= 1
            }
            i+=1
        }
        i = 0
        while i<a.count
        {
            if let index = b.index(of: a[i])
            {
                white += 1
                a.remove(at: i)
                b.remove(at: index)
                i -= 1
            }
            i+=1
        }
        return (black,white)
    }
    func toString(_ type:String) -> NSAttributedString {
        
        switch type
        {
        case "SaveFile":
            var outString = ""
            
            for color in colors{
                switch color{
                case .black:
                    outString+="z"
                case .blue:
                    outString+="b"
                case .green:
                    outString+="g"
                case .white:
                    outString+="w"
                case .red:
                    outString+="r"
                case .yellow:
                    outString+="y"
                }
            }
            return NSAttributedString(string: outString)
            
        case "Display":
            fallthrough
        default:
            let outString = NSMutableAttributedString()
            for color in colors{
                switch color{
                case .black:
                   outString.append(NSAttributedString(string: color.rawValue))
                case .blue:
                    outString.append(NSAttributedString(string: color.rawValue, attributes: [NSForegroundColorAttributeName:NSColor.init(red: 0, green: 0, blue: 1, alpha: 1)]))
                case .green:
                    outString.append(NSAttributedString(string: color.rawValue, attributes: [NSForegroundColorAttributeName:NSColor.init(red: 0, green: 1, blue: 0, alpha: 1)]))
                case .white:
                    outString.append(NSAttributedString(string: color.rawValue, attributes: [NSForegroundColorAttributeName:NSColor.white]))
                case .red:
                    outString.append(NSAttributedString(string: color.rawValue, attributes: [NSForegroundColorAttributeName:NSColor.init(red: 1, green: 0, blue: 0, alpha: 1)]))
                case .yellow:
                    outString.append(NSAttributedString(string: color.rawValue, attributes: [NSForegroundColorAttributeName:NSColor.init(red: 1, green: 1, blue: 0, alpha: 1)]))
                }
                
                outString.append(NSAttributedString(string: " "))
            }
            return outString
        }
    }
}

class ActionList
{
    private var keysAndHintsUsed:[(Keys,(Int,Int))] = []
    var onStep = 0
    func addElimination(with key:Keys, and hint:(Int,Int)) {
        if onStep == keysAndHintsUsed.count
        {
            keysAndHintsUsed.append((key,hint))
            onStep+=1
        }
        else
        {
            keysAndHintsUsed = Array(keysAndHintsUsed[0..<onStep])
            keysAndHintsUsed.append((key,hint))
            onStep+=1
        }
    }
    func toString(_ type:String) -> NSAttributedString
    {
        let out:NSMutableAttributedString = NSMutableAttributedString()
        var a = 1

        if keysAndHintsUsed.count != 0{
            if onStep == 0{out.append(NSAttributedString(string:"--- Current state ---\n"))}
            for (key,(hint1,hint2)) in keysAndHintsUsed
            {
                out.append(NSAttributedString(string:String(a)+"."))
                out.append(key.toString(type))
                out.append(NSAttributedString(string:"  "+String(hint1)+" "+String(hint2)+"\n"))
                
                if a == onStep { out.append(NSAttributedString(string:"--- Current state ---\n"))}
                a+=1

            }
        }
        else
        {
            out.append(NSAttributedString(string:"--- No Input ---\n"))
        }
        return out
    }
    
    func undo() -> [(Keys,(Int,Int))]
    {
        if onStep > 1
        {
            onStep-=1
            
            return (Array(keysAndHintsUsed[0..<onStep]))
        }
        else
        {
            onStep = 0
            return []
        }
    }
    func redo() -> (Keys,(Int,Int))?
    {
        if onStep < keysAndHintsUsed.count
        {
            onStep+=1
            return (keysAndHintsUsed[onStep-1])
        }
        else
        {
            return nil
        }
    }
    func clear() {
        keysAndHintsUsed = []
        onStep = 0
    }
}

//Solve class, stores remaining keys available
class Solve {
    //remaining keys available
    private var remainKeys:[Keys]=[]
    var actionList:ActionList = ActionList()
    //all colors, for convinience
    private let colors = [Color.black,Color.blue,Color.green,Color.red,Color.white,Color.yellow]
    
    //initialize, all keys available
    init() {
        initializeAvailableKeys()
    }
    
    //initialize, with provided remaining keys
    init(with remainingKey:[Keys]) {
        remainKeys = remainingKey
    }
    func initializeActionList()
    {
        actionList.clear()
    }
    
    //initialize remainKeys
    func initializeAvailableKeys(){
        remainKeys=[]
        for a in colors
        {
            for b in colors
            {
                for c in colors
                {
                    for d in colors
                    {
                        for e in colors
                        {
                                let key = [a,b,c,d,e]
                                remainKeys.append(Keys(newColor: key))
                        
                        }
                    }
                }
            }
        }
    }
    
    
    //eliminate keys that are not possible, given key and hint
    func eliminateKeys(withKey key:Keys,andHint hint:(Int,Int),addAction:Bool) {
        if addAction{
            actionList.addElimination(with: key, and: hint)
        }
        remainKeys = remainKeys.filter({$0.compareTo(new: key) == hint})
    }
    
    func undo()
    {
        let keyHintPairs = actionList.undo()
        initializeAvailableKeys()
        
        if keyHintPairs.count != 0
        {
            for (key,hint) in keyHintPairs
            {
                eliminateKeys(withKey: key, andHint: hint, addAction: false)
            }
        }
    }
    func redo()
    {
        if let keyHintPair = actionList.redo()
        {
            let (key,hint) = keyHintPair
            eliminateKeys(withKey: key, andHint: hint, addAction: false)
        }
        
    }
    //get remainKeys
    func outputRemainingKeys() -> [Keys]
    {
        return remainKeys
    }
    
    //convert to string
    func toString(_ type:String) -> NSAttributedString
    {
        let out = NSMutableAttributedString()
        for key in remainKeys
        {
            out.append(key.toString(type))
            out.append(NSAttributedString(string: "\n"))
        }
        return out
    }
    
    //analyze single key under current circumstance
    //color:color array of guessing key
    func doAnalyze(_ color:[Color]) ->Int
    {
        //output
        var out = 0
        
        //hint black
        for i in 0...5
        {
            //hint white
            for j in 0...5-i
            {
                
                //guessing key
                let key = Keys(newColor: color)
                
                //copy alg
                let algs = Solve(with: outputRemainingKeys())
                //elimination
                algs.eliminateKeys(withKey: key, andHint: (i,j),addAction:false)
                //check if maximum
                out = max(out, algs.outputRemainingKeys().count)
            }
        }
        return out
    }
    
        //analyze best move under such circumstance
    func analyzeAll() -> (Keys,Int,Int)?
    {
        let colors = [Color.black,Color.blue,Color.green,Color.red,Color.white,Color.yellow]
        if outputRemainingKeys().count != 0 {
            //output
            var out = 1000000
            //where the output comes from
            var indexes:[Int] = []
            var anKey:[Keys]=[]
            anKey = outputRemainingKeys()
            // guessing key
            for (index , key) in anKey.enumerated()
            {
                let temp = doAnalyze(key.colors)
                if temp <= out
                {
                    if temp < out
                    {
                        indexes=[index]
                        out = temp
                    }
                    else
                    {
                        indexes+=[index]
                    }
                }
            }
            //(anKey,out,indexes.count)
            var result = (anKey[indexes[0]], out, indexes.count)
            
            if out != 1 && anKey.count <= 19
            {
                anKey = []
                for a in colors
                {
                    for b in colors
                    {
                        for c in colors
                        {
                            for d in colors
                            {
                                for e in colors
                                {
                                    let key = [a,b,c,d,e]
                                    anKey.append(Keys(newColor: key))
                                    
                                }
                            }
                        }
                    }
                }
                var flag = false
                for (index , key) in anKey.enumerated()
                {
                    let temp = doAnalyze(key.colors)
                    if temp <= out
                    {
                        if temp < out
                        {
                            
                            indexes=[index]
                            out = temp
                            flag = true
                            if temp == 1
                            {
                                break
                                
                            }
                        }
                        else
                        {
                            indexes+=[index]
                        }
                    }
                }
                if flag{
                    result = (anKey[indexes[0]], out, indexes.count)
                }
            }
            return result
            
            
        }
        else{
            return nil
        }
    }
}
