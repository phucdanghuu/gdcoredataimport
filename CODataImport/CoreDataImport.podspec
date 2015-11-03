Pod::Spec.new do |s|
  s.name             = "CODataImport"
  s.version          = "0.4"
  s.summary          = "The Cogini Data Import Data."
  s.homepage         = "https://gitlab.cogini.com/kien.tran/gdcoredataimport.git"
  s.license          = 'Code is MIT, then custom font licenses.'
  s.author           = { "ttkien" => "kien.tran@cogini.com" }
  s.source           = { :git => "https://gitlab.cogini.com/kien.tran/gdcoredataimport.git" }
  s.social_media_url = 'https://www.facebook.com/ttkien.it'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'CODataImport/**/*.{h,m}'

  s.frameworks = 'UIKit', 'CoreData', 'Crashlytics', 'Fabric'
  s.module_name = 'CODataImport'
  s.dependency 'MagicalRecord', '~> 2.3'
  s.dependency 'Crashlytics', '3.3.4'
  s.dependency 'Fabric', '1.5.5'

  s.pod_target_xcconfig = {
    'FRAMEWORK_SEARCH_PATHS' => '$(inherited) $(PODS_ROOT)/Crashlytics',
    'OTHER_LDFLAGS'          => '$(inherited) -undefined dynamic_lookup'
  }
end