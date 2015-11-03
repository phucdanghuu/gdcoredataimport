Pod::Spec.new do |s|
  s.name             = "CODataImport"
  s.version          = "0.1"
  s.summary          = "The Cogini Data Import Data."
  s.homepage         = "https://gitlab.cogini.com/kien.tran/gdcoredataimport.git"
  s.license          = 'Code is MIT, then custom font licenses.'
  s.author           = { "ttkien" => "kien.tran@cogini.com" }
  s.source           = { :git => "https://gitlab.cogini.com/kien.tran/gdcoredataimport.git", :tag => "0.1" }
  s.social_media_url = 'https://www.facebook.com/ttkien.it'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = '**/**/*.{h,m}'

  s.frameworks = 'UIKit', 'CoreData'
  s.module_name = 'CODataImport'
  s.dependency 'MagicalRecord', '~> 2.3'
end