//
//  TextGetter.swift
//  tellomee
//
//  Created by Michael Miller on 1/6/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

protocol TextGetterDelegate: class {
    func didGetText(_ text: String)
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
        delegate?.didGetText(textView.text)
        close()
    }
    
    func close() {
        // TODO: Possibly call a "close me" method on the delegate and let the creating ViewController close this one. Apparently that's better practice so they can handle cases when, for example, this isn't popped up modally but is part of a NavigationController.
        self.presentingViewController?.dismiss(animated: true, completion:nil)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
