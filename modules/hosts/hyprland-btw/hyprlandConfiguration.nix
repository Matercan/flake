{ inputs, lib, moduleWithSystem, ... }:
{
  flake.nixosModules.hyprlandConfiguration = moduleWithSystem (
    { pkgs, inputs', self', system, ... }:
    {
      networking = {
        hostName = "hyprland-btw";
        networkmanager.enable = true;
      };

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      programs.xwayland.enable = true;

      environment.systemPackages = with pkgs; [
        inputs'.zen-browser.packages.default
        inputs'.hyprland.packages.default
        proton-vpn
        prismlauncher
        vicinae
        wl-clipboard
        grim
        slurp
      ] ++ (with self'.packages; [
        xcursor-pixel 
        spicetify 
        hyprland
        nvim 
        nvim-config
        kitty
      ]);

      fonts.packages = with pkgs; [
        noto-fonts
        noto-fonts-color-emoji
        noto-fonts-cjk-serif
        fira-code
        self'.packages.script12
      ];

      xdg.portal = {
        enable = true;
        configPackages = [ inputs'.hyprland.packages.default ];
        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
        ];
      };

      hjem.users.lili = {
        enable = true;
        xdg.config.files."hypr".source = ../../../assets/hypr;
      };

      programs.nixcord = {
        enable = true;
        user = "lili";
        equibop.enable = true; 
        discord.equicord.enable = true;

        config.plugins = 
          let
            basicPlugins = [
              "webRichPresence" "betterFolders" 
              "betterGifPicker" "betterRoleDot"
              "crashHandler" "customRpc" 
              "dontRoundMyTimestamps" "fakeNitro" 
              "fixImagesQuality" "fixYoutubeEmbeds" 
              "gifPaste" "petpet" "youtubeAdblock" 
              "betterActivities" "gifMaker" 
              "noNitroUpsell" "cancelFriendRequest"
              "richPresence" "rpcEditor"
              "splitLargeMessages"
            ];

            enabledPlugins = lib.genAttrs basicPlugins (name: { enable = true; });

            customPlugins = {
              musicRichPresence = {
                enable = true;
                scrobblerBackend = "lastfm";
                shareUsername = false;
                clickableLinks = true;
                hideWithSpotify = true;
                hideWithActivity = false;
                statusName = "{album} | {title}";
                statusDisplayType = "artist";
                nameFormat = "artist-first";
                useListeningStatus = false;
                missingArt = "logo";
                showAlbumCover = true;
                username = "Matercan";
                showLogo = true;
              };
            };
          in
        enabledPlugins // customPlugins;
      };

      programs.steam = {
        enable = true;
        gamescopeSession.enable = true;
      };

      imports = [ ./_hardware-configuration.nix inputs.nixcord.nixosModules.nixcord ];
    }
  );
}
