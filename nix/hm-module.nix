self:
{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkOption
    types
    mkIf
    literalExpression
    ;

  packages = self.packages.${pkgs.stdenv.hostPlatform.system};

  cfg = config.programs.lobster;
in
{
  options = {
    programs.lobster = {
      enable = mkEnableOption "lobster";
      package = mkPackageOption packages "lobster" {
        default = "default";
        pkgsText = "lobster.packages.\${pkgs.stdenv.hostPlatform.system}";
      };

      config = mkOption {
        type = types.attrs;
        default = { };
        description = ''
          Configuration written to `$XDG_CONFIG_HOME/lobster/lobster_config.sh`.

          See the wiki at <https://github.com/justchokingaround/lobster/wiki/Configuration> for the full list of options.
        '';
        example = literalExpression ''
          {
            provider = "VidCloud";
            player = "mpv";
          }
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."lobster/lobster_config.sh".text = mkIf (cfg.config != { }) (
      lib.toShellVars cfg.config
    );
  };
}
