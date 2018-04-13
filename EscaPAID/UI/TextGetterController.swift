//
//  TextGetter.swift
//  EscaPAID
//
//  Created by Michael Miller on 1/6/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

protocol TextGetterDelegate: class {
    func didGetText(title: String, text: String)
}

class TextGetterController: UIViewController {
    
    weak var delegate: TextGetterDelegate?
    
    var initialText: String = ""

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationBar.topItem?.title = title
        textView.text = initialText
    }
    
    func setTitle(_ title: String) {
        self.title = title
    }
    func setText(_ text: String) {
        initialText = text
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel_click(_ sender: Any) {
        close()
    }
    
    @IBAction func done_click(_ sender: Any) {
        delegate?.didGetText(title: self.title!, text: textView.text)
        close()
    }
    
    func close() {
        // TODO: Possibly call a "close me" method on the delegate and let the creating ViewController close this one. Apparently that's better practice so they can handle cases when, for example, this isn't popped up modally but is part of a NavigationController.
        self.presentingViewController?.dismiss(animated: true, completion:nil)
    }
}
