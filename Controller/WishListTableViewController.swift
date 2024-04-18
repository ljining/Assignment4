//
//  WishListTableViewController.swift
//  WishList
//
//  Created by 이유진 on 4/17/24.
//

import UIKit
import CoreData

class WishListTableViewController: UITableViewController {
    
    
    @IBOutlet weak var wishListTableView: UITableView!
    
    var products: [Product] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "productCell")
            
        fetchProducts()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath)
        let product = products[indexPath.row]
        
        cell.textLabel?.text = product.title
        cell.detailTextLabel?.text = "\(product.price)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension WishListTableViewController {
    
    //코어 데이터에서 상품 정보 가져오는 함수
    func fetchProducts() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        
        do {
            self.products = try context.fetch(fetchRequest)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("Error fetching products: \(error)")
        }
    }
}
