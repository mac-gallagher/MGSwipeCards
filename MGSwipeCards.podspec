Pod::Spec.new do |s|

  s.name         = "MGSwipeCards"
  s.version      = "1.0.0"
  s.summary      = "A modern swipeable card interface inspired by Tinder"
  s.description  = <<-DESC
A modern swipeable card interface inspired by Tinder and built with Facebook's Pop animation library.
DESC
  s.homepage     = "https://github.com/mac-gallagher/MGSwipeCards"
  s.documentation_url = "https://github.com/mac-gallagher/MGSwipeCards/tree/master/README.md"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author             = { "Mac Gallagher" => "jmgallagher36@gmail.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/mac-gallagher/MGSwipeCards.git", :tag => "1.0.0" }
  s.source_files = "Sources/**/*"
  s.swift_version = "4.1"
  s.framework    = "UIKit", "pop"
  s.dependency "pop", "~> 1.0"

end
