#!@nushell@/bin/nu

def main [] {
  cd $env.NIX_CONFIG_HOME
  ^nxrebuild switch out+err>| tee build.log
}
