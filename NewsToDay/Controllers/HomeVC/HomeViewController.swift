//
//  ViewController.swift
//  NewsToDay
//
//  Created by Артем Орлов on 07.05.2023.
//

import UIKit
import SnapKit

final class HomeViewController: UIViewController, UISearchBarDelegate {
    
    var searchController  = UISearchController()
    var collectionView: UICollectionView!
    
    var networkManadger = NetworkManager.shared
    var categoryStorage = CategoriesStorage.shared

    var categories: Category?
    
    var news: [Article] = []
    var soureces: [Source] = []
    
    var headline: HeadlineSources?
    
   lazy var sections: [Section] = [.categories, .lastNews(news: news), .recommended(sources: soureces)]
    
    // MARK: - UI Properties
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Browse"
        label.textColor = Resources.Colors.blackPrimary
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .left
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Discover things of this world"
        label.textColor = Resources.Colors.greyPrimary
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .left
        return label
    }()
    
    lazy var searchBar: UISearchBar = {
        let sbar = UISearchBar()
        sbar.placeholder = "Search"
        sbar.searchBarStyle = .minimal
        sbar.delegate = self
        return sbar
    }()
    
// MARK: - View's lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupCollectionView()
        configure()
        loadData()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    
    
    // MARK: - Fetch data
    
    func loadData() {
        networkManadger.fetchTopHeadlines(categories: [Category.business], country: Country.us) { [weak self] result in
            switch result {
            case .success(let news):
               
                self?.news = news.articles
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        networkManadger.fetchHeadlinesSources(category: categories, country: Country.ru) { [weak self] result in
            switch result {
            case .success(let source):
                self?.headline = source
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
    // MARK: - setup Collection View
    
    private func setupCollectionView() {
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        
        // Cells
        collectionView.register(CategoriesViewCell.self, forCellWithReuseIdentifier: "cell1")
        collectionView.register(LastNewsViewCell.self, forCellWithReuseIdentifier: "cell2")
        collectionView.register(RecommendedViewCell.self, forCellWithReuseIdentifier: "cell3")
        
        // Header
        collectionView.register(HeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        // CompositionLayout
        collectionView.collectionViewLayout = creatCompositionalLayout()
    
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
}

// MARK: - Extention, setup constraints

extension HomeViewController {
    private func configure() {
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(100)
            
        }
        
        view.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(20)
        }
        
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(subtitleLabel.snp.bottom).offset(25)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(70)
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(searchBar.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}


