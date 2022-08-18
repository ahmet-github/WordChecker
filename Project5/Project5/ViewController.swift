//
//  ViewController.swift
//  Project5
//
//  Created by Ahmet İyidoğan on 8/1/22.
//

import UIKit

class ViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
   
        if let startWordUrl = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWord = try? String(contentsOf: startWordUrl) {
                allWords = startWord.components(separatedBy: "\n")
            }
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startgame))
        
        if allWords.isEmpty == true{
            allWords = ["slikworm"]
        }
        
        startgame()
    }
    
     @objc func startgame() {
        title = allWords.randomElement()
        usedWords.removeAll()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    @objc func promptForAnswer() {
        
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] action in
    
            guard let answer = ac?.textFields?[0].text else {return}
            self?.submit(answer)
    
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
        
    }
    
    func submit(_ answer: String) {
        
        let lowerAnswer = answer.lowercased()
              
        if isPossible(word: lowerAnswer){
            if isOriginal(word: lowerAnswer){
                if isReal(word: lowerAnswer){
                    
                    usedWords.insert(answer.lowercased(), at: 0)
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    return
                    
                } else { showErrorMessage(errorTitle: "Word is not real", errorMessage: "You can't just make them up, you know!") }
            } else { showErrorMessage(errorTitle: "Word is used before", errorMessage: "Be more original. Try again!") }
        } else { showErrorMessage(errorTitle: "Word is not possible", errorMessage: "You can't spell that word from \(title!.lowercased())")}
        
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else {return false}
        
        if tempWord == word {return false}
        
        for letter in word {

            if let index = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: index)
            } else {
                return false
            }
        }
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        if range.length < 3 { return false }
        let missSpelled = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return missSpelled.location == NSNotFound
    }
    
    func showErrorMessage(errorTitle: String, errorMessage: String) {
        
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    
}

