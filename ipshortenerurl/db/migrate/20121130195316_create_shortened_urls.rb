class CreateShortenedUrls < ActiveRecord::Migration
  def up
    create_table :shortened_urls do |t|
      t.string :url
      t.string :custom
      t.string :visits
    end
    add_index :shortened_urls, :url
    add_index :shortened_urls, :custom
  end

  def down
    drop_table :shortened_urls
  end
end
