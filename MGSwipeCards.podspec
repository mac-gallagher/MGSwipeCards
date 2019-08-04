Pod::Spec.new do |s|

  s.name         = "MGSwipeCards"
  s.version      = "0.0.1"
  s.platform     = :ios, "9.0"
  s.summary      = "A multi-directional card swiping library inspired by Tinder"

  s.description  = <<-DESC
A multi-directional card swiping library inspired by Tinder.
DESC

  s.homepage     = "https://github.com/mac-gallagher/MGSwipeCards"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Mac Gallagher" => "jmgallagher36@gmail.com" }
  s.source       = { :git => "https://github.com/mac-gallagher/MGSwipeCards.git", :tag => "v0.0.1" }

  s.swift_version = "5.0"
  s.source_files = "MGSwipeCards/Classes/**/*"

  s.deprecated_in_favor_of = 'Shuffle-iOS'
end
