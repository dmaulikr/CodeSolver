//
//  ViewController.swift
//  CodeSolver
//
//  Created by Apple on 16/10/25.
//  Copyright © 2016年 Findaldudu. All rights reserved.
//

import Cocoa

class ViewController: NSViewController,NSMenuDelegate {
    var alg:Solve = Solve()
    var buttons:[NSPopUpButton]=[]

    @IBOutlet weak var labelScroll: NSScrollView!
    
    //use this as result Display
    var labelDisplay:NSTextView = NSTextView()
    func menu(_ menu: NSMenu, willHighlight item: NSMenuItem?) {
        if let ite = item
        {
            if ite.isEqual(menu.item(at: 3)) || ite.isEqual(menu.item(at: 4)){
                
            }
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        whiteNo.addItems(withTitles: ["3","4","5"])
        blackNo.addItems(withTitles: ["3","4","5"])
        buttons = [Color1,Color2,Color3,Color4,Color5]
        for button in buttons
        {
            button.addItems(withTitles: ["Yellow","Green","Red"])
            button.item(at: 1)?.attributedTitle = NSAttributedString(string: "Black", attributes: [NSBackgroundColorAttributeName:NSColor.black,NSForegroundColorAttributeName:NSColor.white])
            button.item(at: 2)?.attributedTitle = NSAttributedString(string: "Blue", attributes: [NSBackgroundColorAttributeName:NSColor.init(red: 0, green: 0, blue: 1, alpha: 1),NSForegroundColorAttributeName:NSColor.white])
            button.item(at: 3)?.attributedTitle = NSAttributedString(string: "Yellow", attributes: [NSBackgroundColorAttributeName:NSColor.init(red: 1, green: 1, blue: 0, alpha: 1)])
            button.item(at: 4)?.attributedTitle = NSAttributedString(string: "Green", attributes: [NSBackgroundColorAttributeName:NSColor.init(red: 0, green: 1, blue: 0, alpha: 1)])
            button.item(at: 5)?.attributedTitle = NSAttributedString(string: "Red", attributes: [NSBackgroundColorAttributeName:NSColor.init(red: 1, green: 0, blue: 0, alpha: 1),NSForegroundColorAttributeName:NSColor.white])
            button.selectItem(withTitle: "White")
            button.menu?.delegate = self
        }
        labelDisplay = labelScroll.contentView.documentView as! NSTextView

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBOutlet weak var Color1: NSPopUpButton!
    @IBOutlet weak var Color2: NSPopUpButton!
    @IBOutlet weak var Color3: NSPopUpButton!
    @IBOutlet weak var Color4: NSPopUpButton!
    @IBOutlet weak var Color5: NSPopUpButton!
    
    @IBOutlet weak var whiteNo: NSPopUpButton!
    
    @IBOutlet weak var blackNo: NSPopUpButton!
    
    @IBAction func changeWhite(_ sender: NSPopUpButton) {
        if whiteNo.indexOfSelectedItem + blackNo.indexOfSelectedItem > 5
        {
            blackNo.selectItem(at: 5-whiteNo.indexOfSelectedItem)
        }
    }
    
    @IBAction func changeBlack(_ sender: AnyObject) {
        if whiteNo.indexOfSelectedItem + blackNo.indexOfSelectedItem > 5
        {
            whiteNo.selectItem(at: 5-blackNo.indexOfSelectedItem)
        }
    }
    @IBAction func Undo(_ sender: AnyObject) {
        alg.undo()
        displayEliminated()
        displayAnalyzed.title = String(alg.actionList.onStep)
    }
    @IBAction func Redo(_ sender: AnyObject) {
        alg.redo()
        displayEliminated()
        displayAnalyzed.title = String(alg.actionList.onStep)
    }
    @IBAction func showPreviousSteps(_ sender: AnyObject) {
        labelDisplay.textStorage?.setAttributedString(alg.actionList.toString("Display"))
    } 
    

    @IBOutlet weak var eliminateButton: NSButton!

    @IBOutlet weak var keyInputBox: NSTextField!

    @IBAction func eliminate(_ sender: AnyObject) {
        
        var hint:(Int,Int)
        var colors:[Color] = []
        if sender as! NSObject == eliminateButton
        {
             hint = (blackNo.indexOfSelectedItem,whiteNo.indexOfSelectedItem)
             colors = []
            
            for button in buttons
            {
                switch button.indexOfSelectedItem
                {
                case 0:
                    colors.append(Color.white)
                case 1:
                    colors.append(Color.black)
                case 2:
                    colors.append(Color.blue)
                case 3:
                    colors.append(Color.yellow)
                case 4:
                    colors.append(Color.green)
                case 5:
                    colors.append(Color.red)
                default:
                    colors.append(Color.white)
                }
            }
        }
        else{
            (hint,colors) = readTextKey()

        }
        if colors.count != 5 || hint.1 == -1
        {
            showPreviousSteps(0 as AnyObject)
            labelDisplay.textStorage?.append(NSAttributedString(string:"Error input, please re-eliminate, previous process won't be cleared."))
        }
        else{
            let key = Keys(newColor: colors)
            alg.eliminateKeys(withKey: key, andHint: hint, addAction: true)
            displayEliminated()
        }
    }
    
    @IBAction func reset(_ sender: AnyObject) {
        alg.initializeAvailableKeys()
        alg.initializeActionList()
    }

    func readTextKey()->((Int,Int),[Color]){
        var a = keyInputBox.cell!.title
        var hint:(Int,Int) = (-1,-1)
        var colors:[Color] = []
        for bit in a.characters
        {
            switch bit {
            case "w":
                colors.append(Color.white)
            case "z":
                colors.append(Color.black)
            case "b":
                colors.append(Color.blue)
            case "y":
                colors.append(Color.yellow)
            case "g":
                colors.append(Color.green)
            case "r":
                colors.append(Color.red)
            case "0","1","2","3","4","5":
                if hint.0 == -1 {hint.0 = Int(String(bit))!}
                else if hint.1 == -1
                {
                    hint.1 = Int(String(bit))!
                    if hint.1+hint.0>=6
                    {
                        hint.1 = -1
                    }
                }
            default:
                break
            }
        }
        return (hint,colors)
    }


    @IBOutlet weak var displayAnalyzed: NSTextFieldCell!
    @IBOutlet weak var analyzeButton: NSButton!
    

    @IBAction func Analyze(_ sender: AnyObject) {

        //color array of guessing key
        var colors:[Color] = []
        if sender as! NSObject == analyzeButton
        {
            for button in buttons
            {
                switch button.indexOfSelectedItem
                {
                case 0:
                    colors.append(Color.white)
                case 1:
                    colors.append(Color.black)
                case 2:
                    colors.append(Color.blue)
                case 3:
                    colors.append(Color.yellow)
                case 4:
                    colors.append(Color.green)
                case 5:
                    colors.append(Color.red)
                default:
                    colors.append(Color.white)
                }
            }
        }
        else{
            (_,colors) = readTextKey()
        }
        
        if colors.count != 5
        {
            showPreviousSteps(0 as AnyObject)
            labelDisplay.textStorage?.append(NSAttributedString(string:"Error input, please re-analyze, previous process won't be cleared."))
        }
        else{
        displayAnalyzed.title = String(alg.doAnalyze(colors))
        }
    }
    
       
    //analyze best move under such circumstance
    @IBAction func analyzeAll(_ sender: AnyObject) {
        if  let (key, power, number) = alg.analyzeAll()
        {
            for(index, selection) in buttons.enumerated()
            {
                selection.selectItem(withTitle: key.colors[index].rawValue)
            }
            resultOfAll.title = String(power)
            displayAnalyzed.title = String(number)
        }
        else
        {
            labelDisplay.textStorage?.setAttributedString(NSAttributedString(string: "Error, please reset.", attributes:[NSFontAttributeName:NSFont.systemFont(ofSize: 22)]))
        }
      // TODO
    }
    
    @IBOutlet weak var resultOfAll: NSTextFieldCell!

    func displayEliminated()
    {
        labelDisplay.textStorage?.setAttributedString(alg.toString("Display"))
    }
    func save()
    {

    }
}

