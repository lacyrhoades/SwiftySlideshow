Pod::Spec.new do |s|
  s.name             = "SwiftySlideshow"
  s.version          = "0.9"
  s.summary          = "Tools for connecting external display to iPad / iPhone and displaying arbitrary content via HDMI / AirPlay"
  s.homepage         = "https://github.com/lacyrhoades/SwiftySlideshow"
  s.license          = { type: 'MIT', file: 'LICENSE' }
  s.author           = { "Lacy Rhoades" => "lacy@colordeaf.net" }
  s.source           = { git: "https://github.com/lacyrhoades/SwiftySlideshow.git" }
  s.ios.deployment_target = '10.0'
  s.requires_arc = true
  s.ios.source_files = 'Source/**/*'
end
