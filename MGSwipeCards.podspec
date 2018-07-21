Pod::Spec.new do |s|

  s.name         = "MGSwipeCards"
  s.version      = "2.0.1"
  s.platform     = :ios, "9.0"
  s.summary      = "A modern swipeable card framework inspired by Tinder"

  s.description  = <<-DESC
A modern swipeable card framework inspired by Tinder and built with Facebook's Pop animation library.
DESC

  s.homepage     = "https://github.com/mac-gallagher/MGSwipeCards"
  s.screenshots  = ["https://raw.githubusercontent.com/mac-gallagher/MGSwipeCards/master/Images/swipe_example.gif"]
  s.documentation_url = "https://github.com/mac-gallagher/MGSwipeCards/tree/master/README.md"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Mac Gallagher" => "jmgallagher36@gmail.com" }
  s.source       = { :git => "https://github.com/mac-gallagher/MGSwipeCards.git", :tag => "v2.0.1" }

  s.swift_version = "4.1"
  s.source_files = "MGSwipeCards/Classes/**/*"

  s.dependency "pop", "~> 1.0"

end
