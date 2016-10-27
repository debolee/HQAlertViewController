#
#  Be sure to run `pod spec lint HQAlertViewController.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "HQAlertViewController"
  s.version      = "0.0.1"
  s.summary      = "AlertViewController like UIAlertController."
  s.description  = <<-DESC
                    AlertViewController like UIAlertController，the titleLabel, messageLabel, textField and ohters is custom.
                   DESC

  s.homepage     = "https://github.com/debolee/HQAlertViewController"
  s.license      = "MIT"
  s.author             = { "BobooO" => "debolee@qq.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/debolee/HQAlertViewController.git", :tag => "0.0.1" }
  s.source_files  = "HQAlertViewController", "HQAlertViewController/**/*.{h,m}"
  s.framework  = "UIKit"
  s.requires_arc = true
  
  s.dependency "pop", "~> 1.0"
  s.dependency "Masonry"
end
