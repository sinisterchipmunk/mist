Before("@without_repo") do
  FileUtils.rm_rf Mist.repository_location
end
