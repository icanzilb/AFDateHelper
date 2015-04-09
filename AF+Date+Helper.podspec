Pod::Spec.new do |s|
  s.name     = 'AFDateHelper(icanzilb)'
  s.version  = '1.1'
  s.platform = :ios
  s.license  = 'MIT'
  s.summary  = 'Convenience extension for NSDate in Swift.'
  s.homepage = 'https://github.com/icanzilb/AFDateHelper'
  s.author   = { 'Melvin Rivera' => 'melvin@allforces.com', "Marin Todorov" => "touch-code-magazine@underplot.com" }
  s.source   = { :git => 'https://github.com/icanzilb/AFDateHelper.git', :tag => s.version.to_s }
  s.description = 'Convenience extension for NSDate in Swift for creating, modifying or comparing dates.'
  s.source_files = 'AF+Date+Helper/*'
  s.requires_arc = true
end
