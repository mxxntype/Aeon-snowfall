# INFO: MPD & Ncmpcpp configuration

{ config, pkgs, lib, ... }: with lib; let

visualizer = rec {
    type = "fifo";
    name = "visualizer_${type}";
    path = "/tmp/mpd_visualizer.${type}";
};

in {
    options.aeon.music = with types; {
        enable = mkOption {
            type = bool;
            default = false;
        };
    };

    config = mkIf config.aeon.music.enable {
        services.mpd = {
            enable = true;
            musicDirectory = "${config.xdg.userDirs.music}";
            extraConfig = /* kdl */ ''
                audio_output {
                    type "pipewire"
                    name "PipeWire Sound Server"
                }
                audio_output {
                    type     "${visualizer.type}"
                    name     "${visualizer.name}"
                    path     "${visualizer.path}"
                    format "44100:16:2"
                }
            '';
        };

        programs.ncmpcpp = {
            enable = true;
            package = pkgs.ncmpcpp.override { visualizerSupport = true; };
            bindings = [
                { key = "h"; command = "previous_column"; }
                { key = "j"; command = "scroll_down"; }
                { key = "k"; command = "scroll_up"; }
                { key = "l"; command = "next_column"; }
                { key = "J"; command = [ "select_item" "scroll_down" ]; }
                { key = "K"; command = [ "select_item" "scroll_up" ]; }
            ];
            settings = {
                connected_message_on_startup = "no";
                startup_screen = "media_library";

                # Theme
                # main_window_color = "white";
                # statusbar_color = "white";
                # header_window_color = "blue";
                # volume_color = "magenta";
                # alternative_ui_separator_color = "cyan";
                # window_border_color = "blue";
                # active_window_border = "magenta";

                visualizer_color = "blue,cyan,magenta";
                visualizer_fps = 30;
                visualizer_data_source = visualizer.path;
                visualizer_output_name = visualizer.name;
                visualizer_in_stereo = "yes";
                visualizer_type = "ellipse";
                visualizer_look = "";

                # progressbar_color = "blue";
                # progressbar_elapsed_color = "magenta";

                # color1 = "magenta";
                # color2 = "cyan";

                empty_tag_color = "black";
                empty_tag_marker = "...";
            };
        };

        home.packages = with pkgs; [ mpc-cli ];
    };
}
