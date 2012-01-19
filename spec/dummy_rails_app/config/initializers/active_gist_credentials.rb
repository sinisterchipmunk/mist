unless Rails.env.test?
  ActiveGist::API.username = "sinisterchipmunk"
  ActiveGist::API.password = "h2fklanp"
  Mist.author.name  = "Colin MacKenzie IV"
  Mist.author.email = "sinisterchipmunk@gmail.com"
  Mist.title = "Thoughts in Computation"
  Mist.authorize { true }
end
