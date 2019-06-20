{ config, pkgs, lib, ... }:

with lib;

let
  dataDir = "/var/lib/mautrix-telegram";
in {
  options = {
    services.mautrix-telegram = {
      enable = mkEnableOption "Mautrix-Telegram, a Matrix-Telegram hybrid puppeting/relaybot bridge";

      config = mkOption rec {
        type = types.attrs;
        apply = recursiveUpdate default;
        default = {
          appservice = rec {
            database = "sqlite:///${dataDir}/mautrix-telegram.db";
            hostname = "0.0.0.0";
            port = 8080;
            address = "http://localhost:${toString port}";
          };

          bridge = {
            permissions."*" = "relaybot";
            relaybot.whitelist = [ ];
          };

          # disable logging to file, defaulting to console/systemd
          logging.version = 1;
        };
        example = literalExample ''
          {
            homeserver = {
              address = "http://localhost:8008";
              domain = "public-domain.tld";
            };

            appservice.public = {
              prefix = "/public";
              external = "https://public-appservice-address/public";
            };

            bridge.permissions = {
              "example.com" = "full";
              "@admin:example.com" = "admin";
            };
          }
        '';
        description = ''
          <filename>config.yaml</filename> configuration as a Nix attribute set.
          Configuration options should match those described in
          <link xlink:href="https://github.com/tulir/mautrix-telegram/blob/master/example-config.yaml">
          example-config.yaml</link>.
        '';
        # TODO: uncomment this once mautrix-telegram v0.5.3 is out (https://github.com/tulir/mautrix-telegram/pull/332)
        #
        #  Secret tokens should be specified using <option>environmentFile</option>
        #  instead of this world-readable attribute set.
        #'';
      };

      # TODO: uncomment this once mautrix-telegram v0.5.3 is out (https://github.com/tulir/mautrix-telegram/pull/332)
      #environmentFile = mkOption {
      #  type = types.nullOr types.path;
      #  default = null;
      #  description = ''
      #    File containing environment variables to be passed to the mautrix-telegram service,
      #    in which secret tokens can be specified securely by defining values for
      #    <literal>MAUTRIX_TELEGRAM_TELEGRAM_API_ID</literal>,
      #    <literal>MAUTRIX_TELEGRAM_TELEGRAM_API_HASH</literal> and optionally
      #    <literal>MAUTRIX_TELEGRAM_TELEGRAM_BOT_TOKEN</literal>.
      #  '';
      #};

      homeserverService = mkOption {
        type = types.nullOr types.string;
        default = "matrix-synapse.service";
        description = ''
          Matrix homeserver service to wait for when starting the application service.
        '';
      };
    };
  };

  config = let
    cfg = config.services.mautrix-telegram;
    overrideConfigFile = pkgs.writeText "mautrix-telegram-config.json" (builtins.toJSON cfg.config);
    serviceConfig = pkgs.runCommand "mautrix-telegram-config" { preferLocalBuild = true; } ''
      mkdir -p "$out"

      # the configuration file is rewritten to include the registration tokens
      cp '${overrideConfigFile}' "$out/config.yaml"
      chmod +w "$out/config.yaml"

      ${pkgs.mautrix-telegram}/bin/mautrix-telegram \
        --generate-registration \
        --base-config='${pkgs.mautrix-telegram}/example-config.yaml' \
        --config="$out/config.yaml" \
        --registration="$out/registration.yaml"
    '';
  in mkIf cfg.enable {
    systemd.services.mautrix-telegram = {
      description = "Mautrix-Telegram, a Matrix-Telegram hybrid puppeting/relaybot bridge.";

      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ] ++ optional (cfg.homeserverService != null) cfg.homeserverService;
      after = [ "network-online.target" ] ++ optional (cfg.homeserverService != null) cfg.homeserverService;

      preStart = ''
        cd ${pkgs.mautrix-telegram}
        ${pkgs.mautrix-telegram.alembic}/bin/alembic -x config='${serviceConfig}/config.yaml' upgrade head
      '';

      serviceConfig = {
        Type = "simple";
        ExecStart = ''
          ${pkgs.mautrix-telegram}/bin/mautrix-telegram \
            --config='${serviceConfig}/config.yaml'
        '';
        Restart = "always";
        DynamicUser = true;
        StateDirectory = baseNameOf dataDir;
        # TODO: uncomment this once mautrix-telegram v0.5.3 is out (https://github.com/tulir/mautrix-telegram/pull/332)
        #EnvironmentFile = cfg.environmentFile;
      };
    };

    # TODO: define a common option to be used by all future Matrix homeserver implementations
    # instead of assuming the use of Synapse.
    services.matrix-synapse.app_service_config_files = [ "${serviceConfig}/registration.yaml" ];
  };

  meta.maintainers = with maintainers; [ pacien vskilet ];
}

