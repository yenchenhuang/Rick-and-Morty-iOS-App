//
//  CharactersViewController.swift
//  RickAndMortyiOS
//
//  Created by Alperen Ünal on 31.10.2020.
//

import UIKit
import Combine
import Resolver

class CharactersViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Character>!
    
    private var cancellables = Set<AnyCancellable>()
    
    @LazyInjected private var charactersViewModel: CharactersViewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        setupCollectionView()
        configureDataSource()
        setViewModelListeners()
        charactersViewModel.getCharacters()
    }
    
    private func configureNavBar() {
       // navigationItem.searchController = searchController
        title = "Characters"
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.register(CharacterCollectionViewCell.self, forCellWithReuseIdentifier: CharacterCollectionViewCell.reuseIdentifier)
        view.addSubview(collectionView)
        // NSLayoutConstraint.activate(collectionView.constraintsForAnchoringTo(boundsOf: view))
        
    }
   
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.30),
                                              heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        // item spacing
        group.interItemSpacing = .fixed(5)
        
        let section = NSCollectionLayoutSection(group: group)
        
        // group spacing
        section.interGroupSpacing = 5
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    
    
    private func setViewModelListeners() {
        charactersViewModel.charactersSubject.sink {[weak self] (characters) in
            self?.createSnapshot(from: characters)
            //            if episodes.isEmpty {
            //                self?.tableView.setEmptyMessage(message: "No episode found")
            //            } else {
            //                self?.tableView.restore()
            //            }
        }
        .store(in: &cancellables)
    }
    
    
}

//Collection View Data Source Configurations
extension CharactersViewController: UICollectionViewDelegate {
    fileprivate enum Section {
        case main
    }
    
    
    
    private func configureDataSource(){
        dataSource = UICollectionViewDiffableDataSource<Section, Character>(collectionView: collectionView) {(collectionView, indexPath, characterModel) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CharacterCollectionViewCell.reuseIdentifier, for: indexPath) as? CharacterCollectionViewCell
            cell?.configure(with: characterModel)
            return cell
        }
    }
    
    private func createSnapshot(from addedCharacters: [Character]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Character>()
        snapshot.appendSections([.main])
        snapshot.appendItems(addedCharacters)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let collectionViewContentSizeHeight = collectionView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        
        if position > (collectionViewContentSizeHeight - 100 - scrollViewHeight) {
            charactersViewModel.getCharacters()
        }
    }
}
