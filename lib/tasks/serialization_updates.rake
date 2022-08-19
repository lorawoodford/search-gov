# frozen_string_literal: true

namespace :usasearch do
  namespace :serialization_updates do
    desc 'Run all serialization update tasks'
    task run_all: [:environment,
                   'news_item',
                   'tweet',
                   'twitter_list',
                   'watcher',
                   'youtube_playlist']

    desc 'update news_item properties'
    task news_item: [:environment] do
      # create a faux model to attempting to JSON parse still-YAML content
      faux_news = Class.new(ActiveRecord::Base)
      faux_news.table_name = 'news_items'

      faux_news.select([:id, :properties]).find_in_batches do |news|
        news.each do |item|
          next if item.properties.nil?

          item.properties = YAML.load(item.properties).to_json
          item.save!
        rescue StandardError => e
          puts("Could not fix news item #{item.id} for #{e.message}")
        end
      end
    end

    desc 'update tweet urls'
    task tweet: [:environment] do
      # create a faux model to avoid JSON parsing of still-YAML content
      faux_tweets = Class.new(ActiveRecord::Base)
      faux_tweets.table_name = 'tweets'

      faux_tweets.select([:id, :urls]).find_in_batches do |tweets|
        tweets.each do |tweet|
          next if tweet.urls.nil?

          tweet.urls = YAML.load(tweet.urls).to_json
          tweet.save!
        rescue StandardError => e
          puts("Could not fix tweet #{tweet.id} for #{e.message}")
        end
      end
    end

    desc 'update twitter_list member_ids'
    task twitter_list: [:environment] do
      TwitterList.all.each do |twitter_list|
        member_ids = twitter_list.member_ids_before_type_cast
        next if member_ids.nil?

        twitter_list.update_column(:member_ids, YAML.load(member_ids).to_json)
        twitter_list.save!

      rescue StandardError => e
        puts("Could not fix twitter list #{twitter_list.id} for #{e.message}")
      end
    end

    desc 'update watcher conditions'
    task watcher: [:environment] do
      # create a faux model to avoid JSON parsing of still-YAML content
      faux_watchers = Class.new(ActiveRecord::Base)
      faux_watchers.table_name = 'watchers'

      faux_watchers.select([:id, :conditions]).find_in_batches do |watchers|
        watchers.each do |watcher|
          watcher.conditions = YAML.load(watcher.conditions).to_json
          watcher.save!
        rescue StandardError => e
          puts("Could not fix watcher #{watcher.id} for #{e.message}")
        end
      end
    end

    desc 'update youtube_playlist news_item_ids'
    task youtube_playlist: [:environment] do
      # create a faux model to avoid JSON parsing of still-YAML content
      faux_youtube_playlists = Class.new(ActiveRecord::Base)
      faux_youtube_playlists.table_name = 'youtube_playlists'

      faux_youtube_playlists.select([:id, :news_item_ids]).find_in_batches do |youtube_playlists|
        youtube_playlists.each do |youtube_playlist|
          next if youtube_playlist.news_item_ids.nil?

          youtube_playlist.news_item_ids = YAML.load(youtube_playlist.news_item_ids).to_json
          youtube_playlist.save!
        rescue StandardError => e
          puts("Could not fix youtube playlist #{youtube_playlist.id} for #{e.message}")
        end
      end
    end
  end
end
