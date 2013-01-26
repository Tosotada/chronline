require 'rss'


Layout.add_schema(:markdown, {
                    "type" => "string",
                    # "description" => "Markdown text",
                    "format" => "multiline",  # for onde.js
                  }) do |markdown_strings|
  markdown_strings.map {|str| RDiscount.new(str).to_html}
end

Layout.add_schema(:article, {
                    "type" => "integer",
                    "display" => "article-picker"
                  }) do |article_ids|
  Article.includes(:authors, :image).find_in_order(article_ids)
end

Layout.add_schema(:disqus_popular, {"type" => "null"}) do |invocations|
  disqus = Disqus.new(Settings.disqus.api_key)
  article_slugs = disqus.popular_articles(Settings.disqus.shortname, 7)
  articles = Article.includes(:authors, :image).find_in_order(article_slugs)
  [articles] * invocations.length
end


Layout.add_schema(:popular, {
                    'type' => 'string',
                    'enum' => Taxonomy.main_sections.map {|t| t.name.downcase},
                  }) do |sections|
  sections.map do |section|
    Article.popular(section, limit: 7)
  end
end

Layout.add_schema(:section_articles, {
                    'type' => 'string',
                  }) do |sections|
  sections.map do |section|
    # TODO: Magic number
    Article.limit(7).order('created_at DESC').find_by_section(section)
  end
end

Layout.add_schema(:rss, {'type' => 'string'}) do |feeds|
  x = feeds.map do |feed_url|
    feed = HTTParty.get(feed_url).body
    RSS::Parser.parse(feed).items
  end
  p x
  x
end
