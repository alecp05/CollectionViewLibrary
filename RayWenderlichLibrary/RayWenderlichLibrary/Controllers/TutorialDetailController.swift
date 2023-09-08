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

// /////////////////////////////////////////////////////////////////////////
// MARK: - TutorialDetailViewController -
// /////////////////////////////////////////////////////////////////////////

// DetailView can be styled how we want
final class TutorialDetailViewController: UIViewController {
    
    // /////////////////////////////////////////////////////////////////////////
    // MARK: - Properties
    
    var tutorialCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        return label
    }()
    
    var publishDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = .systemGray
        return label
    }()
    
    lazy var queueButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add to queue", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(toggleQueued), for: .touchUpInside)
        return button
    }()
    
    private var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, Video> = UICollectionViewDiffableDataSource(collectionView: self.collectionView, cellProvider: {_,_,_  in return nil })
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    private let tutorial: Tutorial
    
    // /////////////////////////////////////////////////////////////////////////
    // MARK: - Life Cycle
    
    init?(tutorial: Tutorial) {
        self.tutorial = tutorial
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // /////////////////////////////////////////////////////////////////////////
    // MARK: - TutorialDetailViewController
    // /////////////////////////////////////////////////////////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.title = self.tutorial.title
        
        // collectionView
        self.collectionView.register(ContentCell.self, forCellWithReuseIdentifier: ContentCell.reuseIdentifier)
        self.collectionView.register(TitleSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TitleSupplementaryView.reuseIdentifier)
        self.collectionView.collectionViewLayout =  self.configureCollectionView()
        self.configureDataSource()
        self.configureSnapshot()
        
        self.tutorialCoverImageView.image = self.tutorial.image
        self.tutorialCoverImageView.backgroundColor = self.tutorial.imageBackgroundColor
        self.titleLabel.text = self.tutorial.title
        self.publishDateLabel.text = self.tutorial.formattedDate(using: self.dateFormatter)
        let buttonTitle = tutorial.isQueued ? "Remove from queue" : "Add to queue"
        self.queueButton.setTitle(buttonTitle, for: .normal)
        
        self.view.addSubview(self.tutorialCoverImageView)
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.publishDateLabel)
        self.view.addSubview(self.queueButton)
        self.view.addSubview(self.collectionView)
        
        self.makeConstraints()
    }
    
    // /////////////////////////////////////////////////////////////////////////
    // MARK: - Functions
    
    func makeConstraints() {
        
        self.tutorialCoverImageView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(200)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.tutorialCoverImageView.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(35)
        }
        
        self.publishDateLabel.snp.makeConstraints { make in
            make.top.lessThanOrEqualTo(self.titleLabel.snp.bottom)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(35)
        }
        
        self.queueButton.snp.makeConstraints { make in
            make.top.lessThanOrEqualTo(self.publishDateLabel.snp.bottom)
            make.leading.equalToSuperview().inset(16)
            make.trailing.lessThanOrEqualToSuperview()
        }
        
        self.collectionView.snp.makeConstraints { make in
            make.top.lessThanOrEqualTo(self.queueButton.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
    }
    
    @objc
    func toggleQueued() {
        
        self.tutorial.isQueued.toggle()
        
        if self.tutorial.isQueued {
            self.queueButton.setTitle("Remove from queue", for: .normal)
        } else {
            self.queueButton.setTitle("Add to queue", for: .normal)
        }
        
    }
    
    // /////////////////////////////////////////////////////////////////////////
    // MARK: - CollectionView Configuration
    
    // Sidenote: CollectionView can by styled how we want
    
    func configureCollectionView() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.2))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
            section.boundarySupplementaryItems = [sectionHeader]
            
            return section
        }
        
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
        
    }
    
    func configureDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource<Section, Video>(collectionView: self.collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, video: Video) in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContentCell.reuseIdentifier, for: indexPath) as? ContentCell else { return nil }
            
            cell.textLabel.text = video.title
            
            return cell
        }
        
        self.dataSource.supplementaryViewProvider = { [weak self](collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            
            if let self = self, let titleSupplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TitleSupplementaryView.reuseIdentifier, for: indexPath) as? TitleSupplementaryView {
                
                let tutorialCollection = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
                titleSupplementaryView.textLabel.text = tutorialCollection.title
                titleSupplementaryView.textLabel.textColor = .white
                titleSupplementaryView.backgroundColor = .systemGray
                
                return titleSupplementaryView
            } else {
                return nil
            }
        }
    }
    
    func configureSnapshot() {
        var currentSnapshot = NSDiffableDataSourceSnapshot<Section, Video>()
        
        self.tutorial.content.forEach { section in
            currentSnapshot.appendSections([section])
            currentSnapshot.appendItems(section.videos)
        }
        
        self.dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
}
