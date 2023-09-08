/// These materials have been reviewed and are updated as of September, 2020
///
/// Copyright (c) 2020 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.
///

import UIKit
import SnapKit

// /////////////////////////////////////////////////////////////////////////
// MARK: - QueuedTutorialController -
// /////////////////////////////////////////////////////////////////////////

class QueuedTutorialController: UIViewController {
    
    // /////////////////////////////////////////////////////////////////////////
    // MARK: - Properties
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    private lazy var deleteButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.trash, target: self, action: #selector(deleteSelectedItems))
    private lazy var updateButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"), style: .plain,target: self, action: #selector(deleteButtonClicked))
    private lazy var applyUpdatesButton: UIBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "play.fill"), style: .plain, target: self, action: #selector(deleteButtonClicked))
    
    private var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private lazy var dataSource: UICollectionViewDiffableDataSource<QueuedSection, Tutorial> = UICollectionViewDiffableDataSource(collectionView: self.collectionView, cellProvider: {_,_,_  in return nil })
    
    // /////////////////////////////////////////////////////////////////////////
    // MARK: - QueuedTutorialController
    // /////////////////////////////////////////////////////////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.setupView()
        
        self.makeConstraints()
    }
    
    private func setupView() {
        self.title = "Queue"
        self.navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItems = [self.applyUpdatesButton, self.updateButton]
        
        self.collectionView.collectionViewLayout = self.configureCollectionViewLayout()
        self.collectionView.register(QueueCell.self, forCellWithReuseIdentifier: QueueCell.reuseIdentifier)
        self.collectionView.backgroundColor = .lightGray.withAlphaComponent(0.1)
        self.configureDataSource()
        
        self.view.addSubview(self.collectionView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureSnapshot()
    }
    
    func makeConstraints() {
        self.collectionView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    // /////////////////////////////////////////////////////////////////////////
    // MARK: - Functions
    
    @objc
    func deleteButtonClicked() {
        print("clicked")
    }
    
    @objc
    func deleteSelectedItems() {
        guard let selectedIndexPaths = self.collectionView.indexPathsForSelectedItems else { return}
        
        let tutorials = selectedIndexPaths.compactMap { self.dataSource.itemIdentifier(for: $0) }
        
        var currentSnapshot = self.dataSource.snapshot()
        currentSnapshot.deleteItems(tutorials)
        
        self.dataSource.apply(currentSnapshot, animatingDifferences: true)
        
        self.isEditing.toggle()
    }
    
    // /////////////////////////////////////////////////////////////////////////
    // MARK: - CollectionView Configuration
    
    func configureCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(120))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func configureDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource<QueuedSection, Tutorial>(collectionView: self.collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, tutorial: Tutorial) in 
            
            guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: QueueCell.reuseIdentifier, for: indexPath) as? QueueCell else {
                return nil
            }
            
            cell.titleLabel.text = tutorial.title
            cell.thumbnailImageView.image = tutorial.image
            cell.thumbnailImageView.backgroundColor = tutorial.imageBackgroundColor
            cell.publishDateLabel.text = tutorial.formattedDate(using: self.dateFormatter)
            
            return cell
        }
    }
    
    func configureSnapshot() {
        var snapShot = NSDiffableDataSourceSnapshot<QueuedSection, Tutorial>()
        snapShot.appendSections([.main])
        
        let queuedTutorials = DataSource.shared.tutorials.flatMap { $0.queuedTutorials }
        snapShot.appendItems(queuedTutorials)
        
        self.dataSource.apply(snapShot, animatingDifferences: true)
    }
}




// MARK: - Queue Events -

extension QueuedTutorialController {
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if self.isEditing {
            self.navigationItem.rightBarButtonItems = nil
            self.navigationItem.rightBarButtonItem = self.deleteButton
        } else {
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.rightBarButtonItems = [self.applyUpdatesButton, self.updateButton]
        }
        
        self.collectionView.allowsMultipleSelection = true
        self.collectionView.indexPathsForVisibleItems.forEach { indexPath in
            guard let cell = self.collectionView.cellForItem(at: indexPath) as? QueueCell else { return }
            cell.isEditing = self.isEditing
            
            if !self.isEditing {
                cell.isSelected = false
            }
        }
    }
    
    @IBAction func triggerUpdates() {
        
    }
    
    @IBAction func applyUpdates() {
    }
}
