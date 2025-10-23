{
  config,
  lib,
  mainUser,
  ...
}:
let
  moduleSet = "mySharedModules";
  moduleCategory = "projects";
  moduleName = "pricefx-core";

  cfg = config.${moduleSet}.${moduleCategory}.${moduleName};

in
{

  options.${moduleSet}.${moduleCategory}.${moduleName} = with lib; {
    enable = mkEnableOption moduleName;
  };

  config = lib.mkIf cfg.enable {

    home-manager.users.${mainUser.username} =
      { config, lib, ... }:
      let

        mavenUserPath = config.sops.secrets.PRICEFX_MAVEN_USER.path;
        mavenPassPath = config.sops.secrets.PRICEFX_MAVEN_PASS.path;
      in
      {
        home.activation = {
          applyPricefxMavenSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            mkdir -p ${config.home.homeDirectory}/.m2
            cat > ${config.home.homeDirectory}/.m2/settings.xml << EOF
            <settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
                      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                      xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                                  http://maven.apache.org/xsd/settings-1.0.0.xsd">
                <servers>
                    <server>
                        <id>Pricefx maven artifacts</id>
                        <username>$(cat ${mavenUserPath})</username>
                        <password>$(cat ${mavenPassPath})</password>
                    </server>
                </servers>
                
                <profiles>
                    <profile>
                        <id>default</id>
                        <activation>
                            <activeByDefault>true</activeByDefault>
                        </activation>
                        <repositories>
                            <repository>
                                <id>Default repo</id>
                                <url>https://repo1.maven.org/maven2</url>
                                <snapshots>
                                    <enabled>false</enabled>
                                </snapshots>
                                <releases>
                                    <enabled>true</enabled>
                                </releases>
                            </repository>
                            <repository>
                                <id>SmartGWT official repo</id>
                                <url>http://www.smartclient.com/maven2</url>
                                <snapshots>
                                    <enabled>false</enabled>
                                </snapshots>
                                <releases>
                                    <enabled>true</enabled>
                                </releases>
                            </repository>
                            <repository>
                                <id>Pricefx maven artifacts</id>
                                <url>https://maven.pricefx.eu</url>
                                <snapshots>
                                    <enabled>true</enabled>
                                </snapshots>
                                <releases>
                                    <enabled>true</enabled>
                                </releases>
                            </repository>
                        </repositories>
                        <pluginRepositories>
                            <pluginRepository>
                                <releases>
                                    <enabled>false</enabled>
                                </releases>
                                <snapshots/>
                                <id>Apache Snapshot Repository</id>
                                <url>http://repository.apache.org/snapshots</url>
                            </pluginRepository>
                            <pluginRepository>
                                <releases>
                                    <enabled>true</enabled>
                                </releases>
                                <snapshots/>
                                <id>Pricefx nexus maven</id>
                                <url>https://nexus.pricefx.net/maven</url>
                            </pluginRepository>
                        </pluginRepositories>
                    </profile>
                </profiles>
            </settings>
            EOF
          '';
        };
      };
  };
}
