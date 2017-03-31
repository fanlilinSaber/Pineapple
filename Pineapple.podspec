Pod::Spec.new do |spec|
  spec.name = "Pineapple"
  spec.version = "1.0.0"
  spec.summary = "Simplify TCP Socket"
  spec.homepage = "http://git.oschina.net/i-focusing-app/Pineapple"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Dan Jiang" => 'dan@danthought.com' }
  spec.platform = :ios, "8.4"
  spec.requires_arc = true
  spec.source = { git: "https://git.oschina.net/i-focusing-app/Pineapple.git", tag: spec.version, submodules: true }
  spec.source_files = "Sources/**/*.{h,m}"
  spec.resources = "Sources/*.bundle"
  spec.dependency "CocoaAsyncSocket"
end
