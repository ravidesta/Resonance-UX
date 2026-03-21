// WriterViewModel.swift
// Resonance — Design for the Exhale

import SwiftUI

@Observable
final class WriterViewModel {
    var documents: [WriterDocument] = WriterDocument.sampleDocuments
    var selectedDocument: WriterDocument?
    var isEditing = false
    var isFocusMode = false
    var editingText: String = ""

    var currentWordCount: Int {
        editingText.split(separator: " ").count
    }

    var currentReadingTime: String {
        let minutes = max(1, currentWordCount / 200)
        return "\(minutes) min"
    }

    func selectDocument(_ doc: WriterDocument) {
        selectedDocument = doc
        editingText = doc.body
        isEditing = true
    }

    func createNew() {
        let doc = WriterDocument(
            title: "Untitled",
            body: "",
            createdAt: .now,
            wordCount: 0,
            isFavorite: false
        )
        documents.insert(doc, at: 0)
        selectDocument(doc)
    }

    func saveCurrentDocument() {
        guard let selected = selectedDocument,
              let index = documents.firstIndex(where: { $0.id == selected.id }) else { return }
        documents[index].body = editingText
        documents[index].wordCount = currentWordCount
    }
}
