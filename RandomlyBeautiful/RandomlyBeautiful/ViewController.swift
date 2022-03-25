//
//  ViewController.swift
//  RandomlyBeautiful
//
//  Created by Abraham Abreu on 23/03/22.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    var categories = ["Airplanes", "Beaches", "Bridges", "Cats", "Cities", "Dogs", "Earth", "Forests", "Galaxies", "Landmarks", "Mountains", "People", "Roads", "Sports", "Sunsets"]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
}

// MARK: -

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "Images") as? ImagesViewController else  {  return }
        vc.category = categories[indexPath.row]
        present(vc, animated: true)
    }
}

