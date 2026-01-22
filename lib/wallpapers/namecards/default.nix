{ lib, ... }: let

sources = {
    # SECTION: Achievements
    infinitum = {
        url = "https://static.wikia.nocookie.net/gensin-impact/images/9/9d/Namecard_Background_Achievement_Infinitum.png/revision/latest?cb=20230412034747";
        hash = "sha256-jMQxPdsQ9yBLU7VQ6pQ7nIuwcFe5X+8KKkUQ2GW1CEg=";
    };

    woodlands = {
        url = "https://static.wikia.nocookie.net/gensin-impact/images/f/f8/Namecard_Background_Travel_Notes_Woodlands.png/revision/latest?cb=20220826151244";
        hash = "sha256-gkPwxr7lptBqn2+n8KxbPoQt3k3oxB6B3/VyMm1UDxE=";
    };

    # kujou-insigna = {
    #     url = "https://static.wikia.nocookie.net/gensin-impact/images/1/17/Namecard_Background_Inazuma_Kujou_Insignia.png/revision/latest?cb=20210725071326";
    #     hash = "sha256-PgLuAV4Ne/6GpaiMdF40lBaSm7N9K63RLuTOiamkRE4=";
    # };

    # eagleplume = {
    #     url = "https://static.wikia.nocookie.net/gensin-impact/images/4/4c/Namecard_Background_Inazuma_Eagleplume.png/revision/latest?cb=20211013104446";
    #     hash = "sha256-R+5tGwnYXogq0rzrhf0IuO9KMyXWyRap1NCTzE+8mW0=";
    # };

    fighting-spirit = {
        url = "https://static.wikia.nocookie.net/gensin-impact/images/8/8b/Namecard_Background_Achievement_Fighting_Spirit.png/revision/latest?cb=20241129014713";
        hash = "sha256-irU1PXPinvoFeWD1UxzV7w32OUBT2j1nAAMmuPPVSCY=";
    };

    # sandstorm = {
    #     url = "https://static.wikia.nocookie.net/gensin-impact/images/e/e9/Namecard_Background_Sumeru_Sandstorm.png/revision/latest?cb=20230118035112";
    #     hash = "sha256-wixXEN/zhgspD9RMjj2ozc7FFPbXoclHa/vMvgpUHcM=";
    # };

    # irodori = {
    #     url = "https://static.wikia.nocookie.net/gensin-impact/images/e/ef/Namecard_Background_Travel_Notes_Irodori.png/revision/latest?cb=20220330033749";
    #     hash = "sha256-mOTQJcYa0G2VfJfHWsg7Cs+6nfd5gxpDrqYtGseQmj4=";
    # };

    # lord-of-the-night = {
    #     url = "https://static.wikia.nocookie.net/gensin-impact/images/d/da/Namecard_Background_Achievement_Lord_of_the_Night.png/revision/latest?cb=20240829153319";
    #     hash = "sha256-2jWHoJP/FtecEM8k8llqwzrHg0yqZEN850XmQADhhYc=";
    # };

    # blaze = {
    #     url = "https://static.wikia.nocookie.net/gensin-impact/images/3/39/Namecard_Background_Achievement_Blaze.png/revision/latest?cb=20250102024021";
    #     hash = "sha256-FVxB3A8fdaqnQFwSmCownZAAXoFky46hvneecFhXbK4=";
    # };

    sacred-realm = {
        url = "https://static.wikia.nocookie.net/gensin-impact/images/d/d0/Namecard_Background_Nod-Krai_Sacred_Realm.png/revision/latest?cb=20250910075325";
        hash = "sha256-ayk+65z/kH2ZtHQPRo3rtLTSTMmnSvofrNMzEDgHMSg=";
    };

    # sangonomiya-crest = {
    #     url = "https://static.wikia.nocookie.net/gensin-impact/images/3/31/Namecard_Background_Inazuma_Sangonomiya_Crest.png/revision/latest?cb=20210902035053";
    #     hash = "sha256-Eol94J2dOK2RLP6BPVUWPypbHikNjWzeOxzkRL71w7I=";
    # };

    vibrant-harriers = {
        url = "https://static.wikia.nocookie.net/gensin-impact/images/d/da/Namecard_Background_Travel_Notes_Vibrant_Harriers.png/revision/latest?cb=20240131020037";
        hash = "sha256-An06hU00xxlI2i3G1Q9APv7pSntjI/OPJpNk3sj2+yw=";
    };

    flowing-hues = {
        url = "https://static.wikia.nocookie.net/gensin-impact/images/1/18/Namecard_Background_Travel_Notes_Flowing_Hues.png/revision/latest?cb=20220105061656";
        hash = "sha256-6mYGDifXYE+U1uazAOBV/qc+HBUu3gPVQ3I6Gj1RJIM=";
    };

    adeptal-valley = {
        url = "https://static.wikia.nocookie.net/gensin-impact/images/f/ff/Namecard_Background_Achievement_Adeptal_Valley.png/revision/latest?cb=20240131020030";
        hash = "sha256-o4zKt2Bgx+4/NdLuBiVF3HRZy9eJmJ++AbKK9VTesH0=";
    };

    # SECTION: Character namecards
    raiden-enlightenment = {
        url = "https://static.wikia.nocookie.net/gensin-impact/images/5/5e/Namecard_Background_Raiden_Shogun_Enlightenment.png/revision/latest?cb=20210902035057";
        hash = "sha256-H8pwdxjeWbnb270Ic656rJHZMxqM7GPyzqVWQYRo1JQ=";
    };

    # flins-oathkeepers-lantern = {
    #     url = "https://static.wikia.nocookie.net/gensin-impact/images/6/60/Namecard_Background_Flins_Oathkeeper%27s_Lantern.png/revision/latest?cb=20250910075522";
    #     hash = "sha256-FWOgcJA2pcyq83Rp+soHRys1KplyI1FS9ye6GbmQbQ8=";
    # };

    # kujou-sara-tengu = {
    #     url = "https://static.wikia.nocookie.net/gensin-impact/images/f/f6/Namecard_Background_Kujou_Sara_Tengu.png/revision/latest?cb=20210902035055";
    #     hash = "sha256-DbtFfyGsqi3CxcBH4rfh34itvOzCcDihaGn3jS8U90A=";
    # };
};

in {
    wallpapers.namecards = sources
        |> lib.attrsToList
        |> builtins.map (source: {
            inherit (source) name;
            inherit (source.value) url hash;
        });
}
