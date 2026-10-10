{ inputs, moduleWithSystem, ... }:
{
  flake.nixosModules.hyprlandConfiguration = moduleWithSystem (
    { pkgs, lib, self', system, ... }:
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

      environment.systemPackages = with pkgs; [
        inputs.zen-browser.packages.${system}.default 
        kitty
      ] ++ (with self'.packages; [
        spicetify 
        hyprland
        nvim 
        nvim-config
      ]);

      fonts.packages = with pkgs; [
        noto-fonts
        noto-fonts-color-emoji
        noto-fonts-cjk-serif
        self'.packages.firaCodeIScript
      ];

      xdg.portal = {
        enable = true;
        configPackages = [ self'.packages.hyprland ];
        extraPortals = [
          pkgs.xdg-desktop-portal-gtk
        ];
      };

      programs.nixcord = {
        enable = true;
        user = "lili";
        discord.equicord.enable = true; 

        config.plugins = 
          let
            basicPlugins = [
              "webRichPresence" "betterFolders" 
              "betterGifPicker" "betterRoleDot"
              "crashHandler" "customRPC" 
              "dontRoundMyTimeStamps" "fakeNitro" 
              "fixImagesQuality" "fixYoutubeEmbeds" 
              "gifPaste" "PetPet" "youtubeADblock" 
              "betterActivities" "gifMaker" 
              "noNitroUpsell" "cancelFriendRequest"
              "richPresence" "rPCEditor"
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
                showLastFmLogo = true;
                showLogo = true;
              };
            };
          in
            enabledPlugins // customPlugins;
      };
      imports = [ ./_hardware-configuration.nix inputs.nixcord.nixosModules.nixcord ];
    }
  );
}
