//
//  ViewController.swift
//  SampleAMOuijaBoard
//
//  Created by am10 on 2019/10/22.
//  Copyright © 2019 am10. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var boardView: AMOuijaBoardView!
    @IBOutlet private weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        boardView.delegate = self
        label.text = ""
    }
    
    private func showFontFamily() {
        boardView.superview?.isHidden = true
        let view = UIScrollView(frame: self.view.bounds)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.contentSize = .zero

        UIFont.familyNames.forEach { (familyName) in
            let fontsInFamily = UIFont.fontNames(forFamilyName: familyName)
            fontsInFamily.forEach({ (fontName) in
                print(fontName)
                let label = UILabel()
                label.textColor = .white
                label.text = "フォント：" + fontName
                label.font = UIFont(name: fontName, size: UIFont.labelFontSize)
                label.sizeToFit()
                label.frame.origin.y = view.contentSize.height
                view.contentSize.width = max(view.contentSize.width, label.frame.width)
                view.contentSize.height += label.frame.height + 10
                view.addSubview(label)
            })
        }

        self.view.addSubview(view)
    }
}

extension ViewController: AMOuijaBoardViewDelegate {
    func didSelectGoodBye(in ouijaBoardView: AMOuijaBoardView) {
        label.text = ""
    }
    
    func ouijaBoardView(_ ouijaBoardView: AMOuijaBoardView, didSelectText text: String) {
        label.text! += text
    }
}
