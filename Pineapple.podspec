Pod::Spec.new do |spec|
  spec.name = "Pineapple"
  spec.version = "1.3.0"
  spec.summary = "Simplify TCP Socket & MQTT"
  spec.homepage = "http://git.oschina.net/i-focusing-app/Pineapple"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Fan Li Lin" => 'fanlilin@i-focusing.com' }
  spec.platform = :ios, "8.4"
  spec.requires_arc = true
  spec.source = { git: "https://git.oschina.net/i-focusing-app/Pineapple.git", tag: spec.version, submodules: true }
  spec.public_header_files = "Sources/Pineapple.h"
  spec.source_files = "Sources/Pineapple.h"
  
  spec.subspec "Commmand" do |ss|
    ss.source_files = "Sources/Commmand/**/*"
  end
  
  spec.subspec "MQTT" do |ss|
    ss.source_files = "Sources/MQTT/**/*"
    ss.dependency "MQTTClient", "~> 0.9"
    ss.dependency "Pineapple/Commmand"
    ss.dependency "Pineapple/Device"
    ss.dependency "Pineapple/Ability"
  end
  
  spec.subspec "Socket" do |ss|
    ss.source_files = "Sources/Socket/**/*"
    ss.dependency "CocoaAsyncSocket"
    ss.dependency "Pineapple/Commmand"
    ss.dependency "Pineapple/Device"
    ss.dependency "Pineapple/Ability"
  end
  
  spec.subspec "Device" do |ss|
    ss.source_files = "Sources/Device/**/*"
  end
  
  spec.subspec "Bluetooth" do |ss|
    ss.source_files = "Sources/Bluetooth/**/*"
  end
  
  spec.subspec "Ability" do |ss|
    ss.source_files = "Sources/Ability/**/*"
    ss.dependency "Pineapple/Commmand"
  end
  
  spec.subspec "Usable" do |ss|
    ss.source_files = "Sources/Usable/**/*"
    ss.dependency "Pineapple/Commmand"
  end
  
  spec.subspec "RMQ" do |ss|
    ss.source_files = "Sources/RMQ/**/*"
    ss.dependency "Pineapple/Device"
    ss.dependency "Pineapple/Ability"
    ss.dependency "RMQClient"
  end
  
  spec.resources = "Sources/*.bundle"
end
