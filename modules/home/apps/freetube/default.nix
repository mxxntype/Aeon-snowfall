{ lib, config, pkgs, ... }:

{
    options.aeon.apps.freetube = {
        enable = lib.mkEnableOption "FreeTube";
    };

    config = let cfg = config.aeon.apps.freetube;
    in lib.mkIf cfg.enable {
        programs.freetube = {
            enable = true;
            package = pkgs.freetube;
            settings = {
                autoplayPlaylists = false;
                backendFallback = false;
                backendPreference = "invidious";
                barColor = false;
                baseTheme = "black";
                blurThumbnails = false;
                # bounds = { "x" = 0; "y" = 0; "width" = 1920; "height" = 1080; "maximized" = false; "fullScreen" = true; };
                checkForUpdates = false;
                defaultAutoplayInterruptionIntervalHours = 1;
                defaultInvidiousInstance = "http://localhost:8890";
                defaultQuality = "2160";
                defaultVolume = 0.1;
                enableScreenshot = false;
                enableSearchSuggestions = false;
                expandSideBar = false;
                externalLinkHandling = "openLinkAfterPrompt";
                hideActiveSubscriptions = false;
                hideHeaderLogo = true;
                hideLabelsSideBar = true;
                hidePlaylists = false;
                hidePopularVideos = true;
                hideSharingActions = false;
                hideVideoViews = true;
                landingPage = "subscriptions";
                mainColor = "GruvboxDarkAqua";
                proxyVideos = true;
                quickBookmarkTargetPlaylistId = "favorites";
                secColor = "GruvboxDarkAqua";
                showDistractionFreeTitles = true;
                sponsorBlockFiller = { "color" = "EverforestDarkPurple"; "skip" = "showInSeekBar"; };
                sponsorBlockInteraction = { "color" = "EverforestDarkRed"; "skip" = "showInSeekBar"; };
                sponsorBlockIntro = { "color" = "EverforestLightAqua"; "skip" = "showInSeekBar"; };
                sponsorBlockMusicOffTopic = { "color" = "EverforestDarkYellow"; "skip" = "showInSeekBar"; };
                sponsorBlockOutro = { "color" = "EverforestDarkBlue"; "skip" = "showInSeekBar"; };
                sponsorBlockRecap = { "color" = "EverforestDarkPurple"; "skip" = "showInSeekBar"; };
                sponsorBlockSelfPromo = { "color" = "EverforestDarkYellow"; "skip" = "showInSeekBar"; };
                sponsorBlockSponsor = { "color" = "EverforestDarkGreen"; "skip" = "autoSkip"; };
                thumbnailPreference = "";
                useDeArrowThumbnails = false;
                useDeArrowTitles = false;
                useRssFeeds = true;
                useSponsorBlock = true;
                videoVolumeMouseScroll = true;
            };
        };
    };
}
