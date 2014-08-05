module NewsItemsHelper
  def news_results_class_hash(search)
    if search.rss_feed
      case
        when search.rss_feed.is_managed?
          { class: 'videos' }
        when search.rss_feed.show_only_media_content?
          { class: 'images' }
      end
    end
  end

  def unique_news_items(news_items)
    news_items.uniq { |n| n.link }
  end

  def news_item_partial_by_results_class(css_class_name)
    css_class_name ||= ''
    template = css_class_name.present? ? "#{css_class_name.singularize}_" : ''
    "searches/#{template}news_item"
  end

  def news_item_time_ago_in_words(published_at, separator = '')
    if published_at < Time.current
      [time_ago_in_words(published_at), separator].join
    end
  end
end
