module Mist::Permalink
  def permalink(text)
    text.underscore.gsub(/[^a-zA-Z0-9\.]/, '-')
  end
end
