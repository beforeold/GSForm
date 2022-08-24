#  引用命令 pod 'GSForm', :svn =>"https://192.168.1.9/svn/IOS/otherprojects/GSKit/GSForm"


Pod::Spec.new do |s|

  s.name         = "GSForm"

  s.version      = "2.3"
  s.summary      = "this is a GSForm."

  s.description  = <<-DESC
                   just use it!
                   DESC
  s.homepage     = "http://www.souhuow.com"

  s.license      = "MIT"

  s.author       = { "Brook" => "cirpxpp@163.com"}
 
  s.platform     = :ios, "8.0"

  s.source       = { :svn => "https://192.168.1.9/svn/IOS/otherprojects/GSKit/GSForm", :tag => "#{s.version}" }

  s.source_files = 'GSForm/*.{h,m}'

end
