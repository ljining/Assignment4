//
//  WishListTableViewController.swift
//  WishList
//
//  Created by 이유진 on 4/17/24.
//

import UIKit
import CoreData

class WishListTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var wishListTableView: UITableView!
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        tableView.addGestureRecognizer(longPressRecognizer)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "productCell")
        
        fetchProducts()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataManager.shared.products.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath)
        let product = DataManager.shared.products[indexPath.row]
        
        cell.textLabel?.text = product.title
        cell.detailTextLabel?.text = "\(product.price)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
    
    
// MARK: - Fetching and Deleting Products
    
extension WishListTableViewController {
          
        // 코어 데이터에서 상품 정보 가져오는 함수
        func fetchProducts() {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
            
            do {
                DataManager.shared.products = try context.fetch(fetchRequest)
                tableView.reloadData()
            } catch {
                print("Error fetching products: \(error)")
            }
        }
        
        // 상품 정보 셀에서 삭제하는 함수
        func deleteProduct(at indexPath: IndexPath) {
            let product = DataManager.shared.products[indexPath.row]
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let context = appDelegate.persistentContainer.viewContext
            
            context.delete(product)
            
            do {
                try context.save()
                DataManager.shared.products.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } catch {
                print("Error deleting product: \(error)")
            }
        }
    }

// MARK: - Gesture Recognizer

extension WishListTableViewController {
    
    // 길게 누르는 제스처 처리하는 함수
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let point = gesture.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: point) {
                showDeleteAlert(for: indexPath)
            }
        }
    }

    // 길게 눌린 셀에 대한 알림창 표시 함수
    func showDeleteAlert(for indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Delete Product", message: "Are you sure you want to delete this product?", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.deleteProduct(at: indexPath)
        }

        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)

        present(alertController, animated: true, completion: nil)
    }
}
