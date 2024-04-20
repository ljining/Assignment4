//
//  ViewController.swift
//  WishList
//
//  Created by 이유진 on 4/16/24.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchData()
    }
   
    // MARK: - Actions
    
    @IBAction func showRandomProduct(_ sender: UIButton) {
        fetchData()
    }
    
    @IBAction func addWishList(_ sender: UIButton) {
        guard let product = DataManager.shared.currentProduct else {
            print("No Product Data to Save")
            return
        }
        
        // 중복 여부 확인
        if checkDuplicateProduct(product) {
            print("Product already exists in Core Data")
        } else {
            saveProductToCoreData(product: product)
        }
    }
        
    @IBAction func showWishList(_ sender: UIButton) {
        let modalVC = WishListTableViewController()
        present(modalVC, animated: true, completion: nil)
    }
}

// MARK: - Extensions

extension ViewController {
    
    // MARK: - Data Handling
    
    func fetchData() {
        // URLSession 인스턴스 생성
        let session = URLSession.shared
        let wishListID = Int.random(in: 1...100)
        
        //URLSessionDataTask 사용해 비동기적으로 데이터 요청
        if let url = URL(string: "https://dummyjson.com/products/\(wishListID)" ) {
            let task = session.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Error: \(error)")
                } else if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let remoteProduct = try decoder.decode(RemoteProduct.self, from: data)
                        print("Decode Product: \(remoteProduct)")
                        
                        DispatchQueue.main.sync {
                            DataManager.shared.currentProduct = remoteProduct
                            self.updateUI(with: remoteProduct)
                        }
                    } catch {
                        print("Decode Error: \(error)")
                    }
                }
            }
            
            task.resume()
        }
    }
    
    func updateUI(with product: RemoteProduct) {
        
        //받아온 데이터 UI 요소에 할당
        titleLabel.text = product.title
        descriptionLabel.text = product.description
        priceLabel.text = formatPrice(product.price)
        
        //이미지 로딩 및 업데이트
        if let imageUrl = URL(string: product.thumbnail){
        let task = URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
                guard let data = data, error == nil else {return}
                guard let image = UIImage(data: data) else { return }
                    
                DispatchQueue.main.async {
                    self.productImageView.image = image
                }
            }
                
                task.resume()
            }
    }
    // MARK: - Utility Functions
    
    // 가격 1000 단위로 콤마 처리
    func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: price)) ?? "\(price)"
    }
    
    // 현재 상품 정보를 코어 데이터에 저장
    func saveProductToCoreData(product: RemoteProduct) {
        guard let context = DataManager.shared.persistentContainer?.viewContext else { return }
        
        let newProduct = Product(context: context)
        newProduct.title = product.title
        newProduct.detail = product.description
        newProduct.price = product.price
        newProduct.thumbnail = URL(string: product.thumbnail)
        
        // 변경사항 저장
        do {
            try context.save()
            print("Product Saved to Core Data")
        } catch {
            print("Failed to Save Product to Core Data: \(error)")
        }
    }
    
    //중복값 확인 함수
    func checkDuplicateProduct(_ product: RemoteProduct) -> Bool {
        guard let context = DataManager.shared.persistentContainer?.viewContext else { return false }
        
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title = %@", product.title)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error checking duplicate product: \(error)")
            return false
        }
    }
}
