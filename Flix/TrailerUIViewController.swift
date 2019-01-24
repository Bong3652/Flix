//
//  TrailerUIViewController.swift
//  Flix
//
//  Created by APPLE on 1/23/19.
//  Copyright © 2019 Bong. All rights reserved.
//

import UIKit
import WebKit

class TrailerUIViewController: UIViewController {
    
    var youtubeLink: String!
    
    @IBOutlet weak var trailer: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trailer.load(URLRequest(url: URL(string: youtubeLink)!))

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
