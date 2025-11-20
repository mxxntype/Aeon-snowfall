{ lib, ... }: let

sources = {
    infinitum = {
        url = "https://static.wikia.nocookie.net/gensin-impact/images/9/9d/Namecard_Background_Achievement_Infinitum.png/revision/latest?cb=20230412034747";
        hash = "sha256-jMQxPdsQ9yBLU7VQ6pQ7nIuwcFe5X+8KKkUQ2GW1CEg=";
    };

    woodlands = {
        url = "https://static.wikia.nocookie.net/gensin-impact/images/f/f8/Namecard_Background_Travel_Notes_Woodlands.png/revision/latest?cb=20220826151244";
        hash = "sha256-gkPwxr7lptBqn2+n8KxbPoQt3k3oxB6B3/VyMm1UDxE=";
    };

    kujou-insigna = {
        url = "https://static.wikia.nocookie.net/gensin-impact/images/1/17/Namecard_Background_Inazuma_Kujou_Insignia.png/revision/latest?cb=20210725071326";
        hash = "sha256-PgLuAV4Ne/6GpaiMdF40lBaSm7N9K63RLuTOiamkRE4=";
    };

    eagleplume = {
        url = "https://static.wikia.nocookie.net/gensin-impact/images/4/4c/Namecard_Background_Inazuma_Eagleplume.png/revision/latest?cb=20211013104446";
        hash = "sha256-R+5tGwnYXogq0rzrhf0IuO9KMyXWyRap1NCTzE+8mW0=";
    };

    enlightenment = {
        url = "https://static.wikia.nocookie.net/gensin-impact/images/5/5e/Namecard_Background_Raiden_Shogun_Enlightenment.png/revision/latest?cb=20210902035057";
        hash = "sha256-H8pwdxjeWbnb270Ic656rJHZMxqM7GPyzqVWQYRo1JQ=";
    };

    fighting-spirit = {
        url = "https://static.wikia.nocookie.net/gensin-impact/images/8/8b/Namecard_Background_Achievement_Fighting_Spirit.png/revision/latest?cb=20241129014713";
        hash = "sha256-3Q5SEgRKbGTCoy1B+GMC2seC3emr8C22i18G/16ryL0=";
    };

    sandstorm = {
        url = "https://static.wikia.nocookie.net/gensin-impact/images/e/e9/Namecard_Background_Sumeru_Sandstorm.png/revision/latest?cb=20230118035112";
        hash = "sha256-wixXEN/zhgspD9RMjj2ozc7FFPbXoclHa/vMvgpUHcM=";
    };

    irodori = {
        url = "https://static.wikia.nocookie.net/gensin-impact/images/e/ef/Namecard_Background_Travel_Notes_Irodori.png/revision/latest?cb=20220330033749";
        hash = "sha256-mOTQJcYa0G2VfJfHWsg7Cs+6nfd5gxpDrqYtGseQmj4=";
    };
};

in {
    wallpapers.namecards = sources
        |> lib.attrsToList
        |> builtins.map (source: {
            inherit (source) name;
            inherit (source.value) url hash;
        });
}
