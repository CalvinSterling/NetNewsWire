//
//  RedditLink.swift
//  Account
//
//  Created by Maurice Parker on 5/4/20.
//  Copyright © 2020 Ranchero Software, LLC. All rights reserved.
//

import Foundation

final class RedditLink: Codable {
    
    let kind: String?
	let data: RedditLinkData?
    
    enum CodingKeys: String, CodingKey {
        case kind = "kind"
        case data = "data"
    }
	
}

final class RedditLinkData: Codable {
    
    let title: String?
	let permalink: String?
    let url: String?
    let id: String?
	let subredditNamePrefixed: String?
	let selfHTML: String?
	let selfText: String?
	let postHint: String?
	let author: String?
	let created: Double?
	let isVideo: Bool?
	let media: RedditMedia?
	let mediaEmbed: RedditMediaEmbed?
	let preview: RedditPreview?
	let crossPostParents: [RedditLinkData]?
    
    enum CodingKeys: String, CodingKey {
        case title = "title"
		case permalink = "permalink"
        case url = "url"
        case id = "id"
		case subredditNamePrefixed = "subreddit_name_prefixed"
		case selfHTML = "selftext_html"
		case selfText = "selftext"
		case postHint = "post_hint"
		case author = "author"
		case created = "created_utc"
		case isVideo = "is_video"
		case media = "media"
		case mediaEmbed = "media_embed"
		case preview = "preview"
		case crossPostParents = "crosspost_parent_list"
    }
	
	var createdDate: Date? {
		guard let created = created else { return nil }
		return Date(timeIntervalSince1970: created)
	}
	
	func renderAsHTML(identifySubreddit: Bool) -> String {
		var html = String()
		
		if identifySubreddit, let subredditNamePrefixed = subredditNamePrefixed {
			html += "<h3><a href=\"https://www.reddit.com/\(subredditNamePrefixed)\">\(subredditNamePrefixed)</a></h3>"
		}
		
		if let parent = crossPostParents?.first {
			html += "<blockquote>"
			if let subreddit = parent.subredditNamePrefixed {
				html += "<p><a href=\"https://www.reddit.com/\(subreddit)\">\(subreddit)</a></p>"
			}
			let parentHTML = parent.renderAsHTML(identifySubreddit: false)
			if parentHTML.isEmpty {
				html += renderURLAsHTML()
			} else {
				html += parentHTML
			}
			html += "</blockquote>"
			return html
		}
		
		if let selfHTML = selfHTML {
			html += selfHTML
		}
		html += renderURLAsHTML()
		return html
	}

	func renderURLAsHTML() -> String {
		guard let url = url else { return "" }
		
		if url.hasSuffix(".gif") {
			return "<img src=\"\(url)\">"
		}
		
		if isVideo ?? false, let videoURL = media?.video?.hlsURL {
			var html = "<video "
			if let previewImageURL = preview?.images?.first?.source?.url {
				html += "poster=\"\(previewImageURL)\" "
			}
			if let width = media?.video?.width, let height = media?.video?.height {
				html += "width=\"\(width)\" height=\"\(height)\" "
			}
			html += "src=\"\(videoURL)\" autoplay muted></video>"
			return html
		}
		
		if let videoPreviewURL = preview?.videoPreview?.url {
			var html = "<video "
			if let previewImageURL = preview?.images?.first?.source?.url {
				html += "poster=\"\(previewImageURL)\" "
			}
			if let width = preview?.videoPreview?.width, let height = preview?.videoPreview?.height {
				html += "width=\"\(width)\" height=\"\(height)\" "
			}
			html += "src=\"\(videoPreviewURL)\" autoplay muted></video>"
			html += linkOutURL(url)
			return html
		}
		
		if !url.hasPrefix("https://imgur.com"), let mediaEmbedContent = mediaEmbed?.content {
			return mediaEmbedContent
		}
		
		if let imageSource = preview?.images?.first?.source, let imageURL = imageSource.url {
			var html = "<a href=\"\(url)\"><img src=\"\(imageURL)\" "
			if postHint == "link" {
				html += "class=\"nnw-nozoom\" "
			}
			if let width = imageSource.width, let height = imageSource.height {
				html += "width=\"\(width)\" height=\"\(height)\" "
			}
			html += "></a>"
			html += linkOutURL(url)
			return html
		}
		
		return linkOutURL(url)
	}
	
	func linkOutURL(_ url: String) -> String {
		guard let urlComponents = URLComponents(string: url), let host = urlComponents.host else {
			return ""
		}
		guard !host.hasSuffix("reddit.com") && !host.hasSuffix("redd.it") else {
			return ""
		}
		var displayURL = "\(urlComponents.host ?? "")\(urlComponents.path)"
		if displayURL.count > 30 {
			displayURL = "\(displayURL.prefix(30))..."
		}
		return "<div><a href=\"\(url)\">\(displayURL)</a></div>"
	}
	
}
