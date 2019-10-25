Pod::Spec.new do |s|
    s.name         = "AMOuijaBoard"
    s.version      = "1.0.1"
    s.summary      = "AMOuijaBoard is a view can select text."
    s.license      = { :type => 'MIT', :file => 'LICENSE' }
    s.homepage     = "https://github.com/adventam10/AMOuijaBoard"
    s.author       = { "am10" => "adventam10@gmail.com" }
    s.source       = { :git => "https://github.com/adventam10/AMOuijaBoard.git", :tag => "#{s.version}" }
    s.platform     = :ios, "11.0"
    s.requires_arc = true
    s.source_files = 'Source/*.{swift}'
    s.swift_version = "5.0"
end
