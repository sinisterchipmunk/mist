atom_feed do |feed|
  feed.title @title
  feed.updated @updated
  
  @posts.each do |post|
    feed.entry(post) do |entry|
      entry.title(post.title)
      entry.content(post.content_as_html, :type => 'html')
      entry.summary(post.content_as_html_preview, :type => 'html')

      entry.author do |author|
        author.name  Mist.author.name
        author.email Mist.author.email
      end
    end
  end
end
