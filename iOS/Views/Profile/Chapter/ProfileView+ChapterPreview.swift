//
//  ProfileView+ChapterPreview.swift
//  Suwatte (iOS)
//
//  Created by Mantton on 2022-03-17.
//

import RealmSwift
import SwiftUI
extension ProfileView.Skeleton {
    struct ChapterView {}
}

private typealias CView = ProfileView.Skeleton.ChapterView

extension ProfileView.Skeleton.ChapterView {
    struct PreviewView: View {
        @EnvironmentObject var model: ProfileView.ViewModel
        var body: some View {
            HStack {
                switch model.chapterState {
                case .loaded:
                    if !model.chapters.isEmpty {
                        LoadedView(model.previewChapters)
                            .transition(.opacity)
                    } else {
                        LoadedEmptyView()
                            .transition(.opacity)
                    }
                case let .failed(error):
                    ErrorView(error: error, action: {
                        await model.loadChapters()
                    })
                    .transition(.opacity)
                default:
                    LoadedView(ThreadSafeChapter.placeholders(count: 6), redacted: true)
                        .redacted(reason: .placeholder)
                        .shimmering()
                        .transition(.opacity)
                }
            }
        }

        @ViewBuilder
        func LoadedEmptyView() -> some View {
            VStack {
                Text("No Chapters Available")
                    .font(.headline.weight(.light))
                    .padding()
                Divider()
            }
        }

        @ViewBuilder
        func LoadedView(_ chapters: [ThreadSafeChapter], redacted: Bool = false) -> some View {
            VStack(alignment: .center, spacing: 10) {
                if !model.linked.isEmpty {
                    ChapterSectionsView()
                }
                HStack {
                    Text("\(chapters.count) \(chapters.count > 1 ? "Chapters" : "Chapter")")
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 6) {
                    ForEach(chapters) { chapter in
                        let completed = isChapterCompleted(chapter)
                        let newChapter = isChapterNew(chapter)
                        let progress = chapterProgress(chapter)
                        let download = getDownload(chapter)
                        VStack(alignment: .leading, spacing: 2) {
                            ChapterListTile(chapter: chapter,
                                            isCompleted: completed,
                                            isNewChapter: newChapter,
                                            progress: progress,
                                            download: download,
                                            isLinked: chapter.sourceId != model.source.id,
                                            showLanguageFlag: model.source.ablityNotDisabled(\.disableLanguageFlags),
                                            showDate: model.source.ablityNotDisabled(\.disableChapterDates),
                                            isBookmarked: model.bookmarkedChapters.contains(chapter.id))
                            if chapter.chapterId != chapters.last?.chapterId {
                                Divider().padding(.top, 6)
                            }
                        }
                        .onTapGesture {
                            guard !redacted else { return }

                            if model.content.contentType == .novel {
                                StateManager.shared.alert(title: "Novel Reading", message: "Novel reading is currently not supported until version 6.1")
                                return
                            }
                            model.selection = chapter
                        }
                    }
                }
                .padding()
                .background(Color.fadedPrimary)
                .cornerRadius(12)
                .animation(.default, value: model.bookmarkedChapters)

                VStack(alignment: .center) {
                    NavigationLink {
                        ChapterList(model: model)
                    } label: {
                        Text(chapters.count >= 5 ? "View All Chapters" : "Manage Chapters")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.vertical, 12.5)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(redacted)
                }

                Divider()
            }
        }
    }
}

extension ProfileView.Skeleton.ChapterView.PreviewView {
    func isChapterCompleted(_ chapter: ThreadSafeChapter) -> Bool {
        model.readChapters.contains(chapter.chapterOrderKey)
    }

    func isChapterNew(_ chapter: ThreadSafeChapter) -> Bool {
        guard let date = model.actionState.marker?.date else {
            return false
        }
        return chapter.date > date
    }

    func chapterProgress(_ chapter: ThreadSafeChapter) -> Double? {
        guard let id = model.actionState.chapter?.id, id == chapter.id else {
            return nil
        }
        return model.actionState.marker?.progress
    }

    func getDownload(_ chapter: ThreadSafeChapter) -> DownloadStatus? {
        model.downloads[chapter.id]
    }
}

extension ProfileView.Skeleton.ChapterView.PreviewView {
    struct ChapterSectionsView: View {
        @EnvironmentObject private var model: ProfileView.ViewModel

        private func isSelected(id: String) -> Bool {
            model.currentChapterSection == id
        }

        var body: some View {
            ScrollView(.horizontal) {
                HStack {
                    if isSelected(id: model.sourceID) {
                        Button(model.source.name) {
                            model.currentChapterSection = model.sourceID
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button(model.source.name) {
                            model.currentChapterSection = model.sourceID
                        }
                        .buttonStyle(.bordered)
                        .tint(.accentColor)
                    }

                    ForEach(model.linked, id: \.source.id) { linked in
                        if isSelected(id: linked.source.id) {
                            Button(linked.source.name) {
                                model.currentChapterSection = linked.source.id
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.accentColor)
                            .coloredBadge(.blue)
                        } else {
                            Button(linked.source.name) {
                                model.currentChapterSection = linked.source.id
                            }
                            .buttonStyle(.bordered)
                            .tint(.accentColor)
                            .coloredBadge(.blue)
                        }
                    }
                }
                .padding(.top, 4)
                .animation(.easeOut(duration: 0.25), value: model.currentChapterSection)
            }
        }
    }
}
