//
//  FMDBWidget.swift
//  FMDBWidget
//
//  Created by Daniel on 10/2/21.
//  Copyright © 2021 dk. All rights reserved.
//

import WidgetKit
import SwiftUI

let defaultContent = WidgetEntry(date: Date(), articles: Article.testArticles)

struct Provider: TimelineProvider {

    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> Void) {
        completion(defaultContent)
    }

    func placeholder(in context: Context) -> WidgetEntry {
        defaultContent
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entryDate = Date()

        WidgetEntry.loadData { (model) in

            if var model = model {
                entryDate = Calendar.current.date(byAdding: .minute, value: 10, to: entryDate)!

                model.date = entryDate
                let timeline = Timeline(entries: [model], policy: .atEnd)
                Log.log("creates timeline with entries: \(model.articles.count)")
                completion(timeline)
            } else {
                Log.log("Articles are zero")
            }

        }
    }

}

@main
struct NewsWidget: Widget {

    let kind: String = "NewsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            NewsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("FastMDb")
        .description("Latest entertainment news.")
    }

}

struct Small: View {

    var article: Article
    let size: CGFloat = 26

    var body: some View {
        VStack {
            HStack() {
                NetworkImage(url: URL(string: article.urlToSourceLogo)!)
                    .frame(width: size, height: size)
                    .background(Color.secondary)
                    .clipShape(Circle())
                Spacer()
                Text(article.publishedAt?.timeAgo ?? "2 minutes ago")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Text(article.safeTitleNoSource)
                .font(.caption)
                .lineLimit(5)
        }
    }

}

struct Medium: View {

    var article: Article
    var line: Int = 2
    var size: CGFloat = 27

    var body: some View {
        HStack {
            NetworkImage(url: URL(string: article.urlToSourceLogo)!)
                .frame(width: size, height: size)
                .background(Color.secondary)
                .clipShape(Circle())
            Text(article.safeTitleNoSource)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .lineLimit(line)
        }
    }

}

struct NewsWidgetEntryView : View {

    @Environment(\.widgetFamily) var widgetFamily
    var entry: WidgetEntry

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            entry.articles.first.map {
                Small(article: $0)
            }
            .padding()
        case .systemMedium:
            VStack(alignment: .leading) {
                ForEach(entry.articles.prefix(3), id: \.self) {
                    Medium(article: $0)
                }
            }
            .padding()
        default:
            VStack(alignment: .leading) {
                ForEach(entry.articles.prefix(8), id: \.self) {
                    Medium(article: $0, line: 2)
                }
            }
            .padding()
        }
    }

}

struct NetworkImage: View {

    let url: URL?

    var body: some View {
        Group {
            if let url = url, let imageData = try? Data(contentsOf: url),
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            else {
                Rectangle()
            }
        }
    }

}

struct NewsWidgetEntryView_Previews: PreviewProvider {

    static var previews: some View {
        let entry = defaultContent
        NewsWidgetEntryView(entry: entry).previewContext(WidgetPreviewContext(family: .systemSmall))
        NewsWidgetEntryView(entry: entry).previewContext(WidgetPreviewContext(family: .systemMedium))
        NewsWidgetEntryView(entry: entry).previewContext(WidgetPreviewContext(family: .systemLarge))
    }

}

struct WidgetEntry: TimelineEntry {

    var date: Date
    let articles: [Article]

}

extension WidgetEntry {

    static func loadData(completion: @escaping (WidgetEntry?) -> ()) {
        NewsApi.category(NewsCategory.Entertainment.rawValue, completion: { (result: Result<Headline, ApiError>) in
            guard case .success(let headline) = result else { return }

            let json = WidgetEntry(date: Date(), articles: headline.articlesWithoutExclusions)
            completion(json)
        })
    }

}

extension Article {

    static var testArticles: [Article] {
        let article1 = Article(title: "Squid Game subtitles 'change meaning' of Netflix show - BBC News", description: "A Korean speaker claims the drama's meaning has been \"botched\" for English-speaking viewers.", url: "https://www.bbc.com/news/world-asia-58787264")
        let article2 = Article(title: "The Morning After: What is it with Netflix cropping ‘Seinfeld’? - Engadget", description: "Today’s headlines: \nNBCUniversal's channels are staying on YouTube TV, Apple’s new MacBook Pro should land this fall, Modern TV screen ratios are cropping jokes out of Seinfeld..", url: "https://www.cnn.com")
        let article3 = Article(title: "Olivia Rodrigo Makes Historic No. 1 Debut on UK Chart", description: "The Maine Center for CDC and Prevention reported 6 new COVID-19-related deaths.", url: "https://www.yahoo.com")

        return [article1, article2, article3, article1, article2, article3, article1, article2, article3]
    }

}

private struct Log {

    static func log(_ value: String) {
//        print(value)
    }

}

private extension Headline {

    static var excludeDomains: [String] = [
        "foxbusiness.com",
        "foxnews.com",
        "pagesix.com",
        "news.google.com",
        "nypost.com",
        "tmz.com"
    ]

    static var excludeKeywords: [String] = [
        "aew",
        "horoscope",
        "wwe"
    ]

    var articlesWithoutExclusions: [Article] {
        let articlesWithoutExcludedDomains = articles.filter({ item in
            var condition: Bool = true
            for domain in Headline.excludeDomains {
                if (item.url ?? "").contains(domain)  {
                    condition = false
                }
            }
            return condition
        })

        let articlesWithoutExcluded = articlesWithoutExcludedDomains.filter { item in
            var condition: Bool = true
            for keyword in Headline.excludeKeywords {
                if let title = item.title {
                    let sub = title.split(separator: " ")
                    for string in sub {
                        if string.lowercased().contains(keyword) {
                            condition = false
                        }
                    }
                }
            }
            return condition
        }

        return articlesWithoutExcluded
    }

}

private extension Date {

    var timeAgo: String {
        guard #available(iOS 13, *) else { return shortTimeAgoSinceDate }

        let dateFormatter = RelativeDateTimeFormatter()
        return dateFormatter.localizedString(for: self, relativeTo: Date())
    }

    var shortTimeAgoSinceDate: String {
        // From Time
        let fromDate = self

        // To Time
        let toDate = Date()

        // Estimation
        // Year
        if let interval = Calendar.current.dateComponents([.year], from: fromDate, to: toDate).year, interval > 0  {

            return "\(interval)y ago"
        }

        // Month
        if let interval = Calendar.current.dateComponents([.month], from: fromDate, to: toDate).month, interval > 0  {

            return "\(interval)mo ago"
        }

        // Day
        if let interval = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day, interval > 0  {

            return "\(interval)d ago"
        }

        // Hours
        if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: toDate).hour, interval > 0 {

            return "\(interval)h ago"
        }

        // Minute
        if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: toDate).minute, interval > 0 {

            return "\(interval)m ago"
        }

        return "a moment ago"
    }

}
