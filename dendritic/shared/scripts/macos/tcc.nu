#!@nushell@/bin/nu

const common_services = [
  "Accessibility"
  "AddressBook"
  "All"
  "AppleEvents"
  "BluetoothAlways"
  "Calendar"
  "Camera"
  "ContactsFull"
  "ContactsLimited"
  "DeveloperTool"
  "Facebook"
  "FileProviderPresence"
  "Liverpool"
  "MediaLibrary"
  "Microphone"
  "Motion"
  "Photos"
  "PhotosAdd"
  "PostEvent"
  "Reminders"
  "ScreenCapture"
  "ShareKit"
  "SinaWeibo"
  "Siri"
  "SpeechRecognition"
  "SystemPolicyAllFiles"
  "SystemPolicyDesktopFolder"
  "SystemPolicyDeveloperFiles"
  "SystemPolicyDocumentsFolder"
  "SystemPolicyDownloadsFolder"
  "SystemPolicyNetworkVolumes"
  "SystemPolicyRemovableVolumes"
  "TencentWeibo"
  "Twitter"
  "Ubiquity"
  "Willow"
]

def db-path [] {
  $"($env.HOME)/Library/Application Support/com.apple.TCC/TCC.db"
}

def service-name [service: string] {
  if $service == "All" {
    return "All"
  }

  if ($service | str starts-with "kTCCService") {
    return $service
  }

  $"kTCCService($service)"
}

def run-tccutil [service: string, client?: string] {
  let resolved = (service-name $service)

  if ($client | is-empty) {
    ^/usr/bin/tccutil reset $resolved
    return
  }

  ^/usr/bin/tccutil reset $resolved $client
}

def "main services" [] {
  $common_services | sort
}

def "main list" [] {
  let db = (db-path)

  if not ($db | path exists) {
    print $"No user TCC database found: ($db)"
    return
  }

  let query = "select service, client, client_type, auth_value, auth_reason, last_modified from access order by service, client;"

  ^/usr/bin/sqlite3 -header -column $db $query
}

def "main reset" [
  service: string
  client?: string
] {
  run-tccutil $service $client
}

def main [] {
  print "usage: tcc [services|list|reset <service> [bundle-id]]"
  print "examples:"
  print "  tcc list"
  print "  tcc reset All"
  print "  tcc reset Accessibility com.mitchellh.ghostty"
  print "  tcc reset ScreenCapture com.apple.Terminal"
}
