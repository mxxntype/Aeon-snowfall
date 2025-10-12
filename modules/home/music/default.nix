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
                main_window_color = "white";
                statusbar_color = "white";
                header_window_color = "blue";
                volume_color = "magenta";
                alternative_ui_separator_color = "cyan";
                window_border_color = "blue";
                active_window_border = "magenta";

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

        home.packages = with pkgs; [
            mpc-cli
            rmpc
        ];

        xdg.configFile = {
            "rmpc/config.ron".text = /* ron */ ''
                #![enable(implicit_some)]
                #![enable(unwrap_newtypes)]
                #![enable(unwrap_variant_newtypes)]
                (
                    address: "127.0.0.1:6600",
                    password: None,
                    theme: Some("nix"),
                    cache_dir: None,
                    on_song_change: None,
                    volume_step: 5,
                    max_fps: 60,
                    scrolloff: 0,
                    wrap_navigation: false,
                    enable_mouse: true,
                    status_update_interval_ms: 200,
                    select_current_song_on_change: false,
                    album_art: (
                        method: Auto,
                        max_size_px: (width: 1200, height: 1200),
                        disabled_protocols: ["http://", "https://"],
                        vertical_align: Center,
                        horizontal_align: Center,
                    ),
                    keybinds: (
                        global: {
                            ":":       CommandMode,
                            ",":       VolumeDown,
                            "s":       Stop,
                            ".":       VolumeUp,
                            "<Tab>":   NextTab,
                            "<S-Tab>": PreviousTab,
                            "1":       SwitchToTab("Artists"),
                            "2":       SwitchToTab("Albums"),
                            "3":       SwitchToTab("Queue"),
                            "4":       SwitchToTab("Directories"),
                            "5":       SwitchToTab("Search"),
                            "6":       SwitchToTab("Playlists"),
                            // "7":       SwitchToTab("Search"),
                            "q":       Quit,
                            ">":       NextTrack,
                            "p":       TogglePause,
                            "<":       PreviousTrack,
                            "f":       SeekForward,
                            "z":       ToggleRepeat,
                            "x":       ToggleRandom,
                            "c":       ToggleConsume,
                            "v":       ToggleSingle,
                            "b":       SeekBack,
                            "~":       ShowHelp,
                            "I":       ShowCurrentSongInfo,
                            "O":       ShowOutputs,
                            "P":       ShowDecoders,
                        },
                        navigation: {
                            "k":         Up,
                            "j":         Down,
                            "h":         Left,
                            "l":         Right,
                            "<Up>":      Up,
                            "<Down>":    Down,
                            "<Left>":    Left,
                            "<Right>":   Right,
                            "<C-k>":     PaneUp,
                            "<C-j>":     PaneDown,
                            "<C-h>":     PaneLeft,
                            "<C-l>":     PaneRight,
                            "<C-u>":     UpHalf,
                            "N":         PreviousResult,
                            "a":         Add,
                            "A":         AddAll,
                            "r":         Rename,
                            "n":         NextResult,
                            "g":         Top,
                            "<Space>":   Select,
                            "<C-Space>": InvertSelection,
                            "G":         Bottom,
                            "<CR>":      Confirm,
                            "i":         FocusInput,
                            "J":         MoveDown,
                            "<C-d>":     DownHalf,
                            "/":         EnterSearch,
                            "<C-c>":     Close,
                            "<Esc>":     Close,
                            "K":         MoveUp,
                            "D":         Delete,
                        },
                        queue: {
                            "D":       DeleteAll,
                            "<CR>":    Play,
                            "<C-s>":   Save,
                            "a":       AddToPlaylist,
                            "d":       Delete,
                            "i":       ShowInfo,
                            "C":       JumpToCurrent,
                        },
                    ),
                    search: (
                        case_sensitive: false,
                        mode: Contains,
                        tags: [
                            (value: "any",         label: "Any Tag"),
                            (value: "artist",      label: "Artist"),
                            (value: "album",       label: "Album"),
                            (value: "albumartist", label: "Album Artist"),
                            (value: "title",       label: "Title"),
                            (value: "filename",    label: "Filename"),
                            (value: "genre",       label: "Genre"),
                        ],
                    ),
                    artists: (
                        album_display_mode: SplitByDate,
                        album_sort_by: Date,
                    ),
                    tabs: [
                        (
                            name: "Artists",
                            pane: Pane(Artists),
                        ),
                        (
                            name: "Albums",
                            pane: Pane(Albums),
                        ),
                        (
                            name: "Queue",
                            pane: Pane(Queue),
                        ),
                        (
                            name: "Directories",
                            pane: Pane(Directories),
                        ),
                        (
                            name: "Search",
                            pane: Pane(Search),
                        ),
                        (
                            name: "Playlists",
                            pane: Pane(Playlists),
                        ),
                    ],
                )
            '';

            "rmpc/themes/nix.ron".text = with config.aeon.theme; let
                primary = ui.accent;
                secondary = let preferred = colors.pink;
                            in if (ui.accent != preferred) then preferred else colors.mauve;
                tetriary = ui.fg.subtext1;
            in /* ron */ ''
                #![enable(implicit_some)]
                #![enable(unwrap_newtypes)]
                #![enable(unwrap_variant_newtypes)]
                (
                    default_album_art_path: None,
                    show_song_table_header: true,
                    draw_borders: true,
                    browser_column_widths: [30, 35, 35],
                    background_color: None,
                    text_color: None,
                    header_background_color: None,
                    modal_background_color: None,
                    tab_bar: (
                        enabled: true,
                        active_style: (fg: "black", bg: "#${tetriary}", modifiers: "Bold"),
                        inactive_style: (),
                    ),
                    highlighted_item_style: (fg: "#${primary}", modifiers: "Bold"),
                    current_item_style: (fg: "#${ui.bg.base}", bg: "#${primary}", modifiers: "Bold"),
                    borders_style: (fg: "#${ui.bg.surface1}"),
                    highlight_border_style: (fg: "#${primary}"),
                    symbols: (song: " ", dir: " ", marker: "󰃂 ", ellipsis: "..."),
                    progress_bar: (
                        symbols: ["=", ">", "-"],
                        track_style: (fg: "#${ui.bg.overlay1}"),
                        elapsed_style: (fg: "#${primary}"),
                        thumb_style: (fg: "#${primary}"),
                    ),
                    scrollbar: (
                        symbols: [".", "|", "▲", "▼"],
                        track_style: (fg: "#${ui.bg.overlay1}"),
                        ends_style: (fg: "#${ui.bg.overlay1}"),
                        thumb_style: (fg: "#${primary}"),
                    ),
                    song_table_format: [
                        (
                            prop: (kind: Property(Artist),
                                default: (kind: Text("Unknown"))
                            ),
                            width: "20%",
                        ),
                        (
                            prop: (kind: Property(Title),
                                default: (kind: Text("Unknown"))
                            ),
                            width: "35%",
                        ),
                        (
                            prop: (kind: Property(Album), style: (fg: "#${ui.fg.text}"),
                                default: (kind: Text("Unknown Album"), style: (fg: "#${ui.fg.text}"))
                            ),
                            width: "30%",
                        ),
                        (
                            prop: (kind: Property(Duration),
                                default: (kind: Text("-"))
                            ),
                            width: "15%",
                            alignment: Right,
                        ),
                    ],
                    layout: Split(
                        direction: Vertical,
                        panes: [
                            (
                                pane: Pane(Header),
                                size: "2",
                            ),
                            (
                                pane: Pane(Tabs),
                                size: "3",
                            ),
                            (
                                pane: Pane(TabContent),
                                size: "100%",
                            ),
                            (
                                pane: Pane(ProgressBar),
                                size: "1",
                            ),
                        ],
                    ),
                    header: (
                        rows: [
                            (
                                left: [
                                    (kind: Text("["), style: (fg: "#${secondary}", modifiers: "Bold")),
                                    (kind: Property(Status(StateV2(playing_label: "Playing", paused_label: "Paused", stopped_label: "Stopped"))), style: (fg: "#${secondary}", modifiers: "Bold")),
                                    (kind: Text("]"), style: (fg: "#${secondary}", modifiers: "Bold"))
                                ],
                                center: [
                                    (kind: Property(Song(Title)), style: (modifiers: "Bold"),
                                        default: (kind: Text("No Song"), style: (modifiers: "Bold"))
                                    )
                                ],
                                right: [
                                    (kind: Property(Widget(Volume)), style: (fg: "#${primary}"))
                                ]
                            ),
                            (
                                left: [
                                    (kind: Property(Status(Elapsed))),
                                    (kind: Text(" / ")),
                                    (kind: Property(Status(Duration))),
                                    (kind: Text(" (")),
                                    (kind: Property(Status(Bitrate))),
                                    (kind: Text(" kbps)"))
                                ],
                                center: [
                                    (kind: Property(Song(Artist)), style: (fg: "#${secondary}", modifiers: "Bold"),
                                        default: (kind: Text("Unknown"), style: (fg: "#${secondary}", modifiers: "Bold"))
                                    ),
                                    (kind: Text(" - ")),
                                    (kind: Property(Song(Album)),
                                        default: (kind: Text("Unknown Album"))
                                    )
                                ],
                                right: [
                                    (
                                        kind: Property(Widget(States(
                                            active_style: (fg: "#${ui.fg.text}", modifiers: "Bold"),
                                            separator_style: (fg: "#${ui.fg.text}")))
                                        ),
                                        style: (fg: "#${ui.bg.overlay1}")
                                    ),
                                ]
                            ),
                        ],
                    ),
                    browser_song_format: [
                        (
                            kind: Group([
                                (kind: Property(Track)),
                                (kind: Text(" ")),
                            ])
                        ),
                        (
                            kind: Group([
                                (kind: Property(Artist)),
                                (kind: Text(" - ")),
                                (kind: Property(Title)),
                            ]),
                            default: (kind: Property(Filename))
                        ),
                    ],
                )
            '';
        };
    };
}
