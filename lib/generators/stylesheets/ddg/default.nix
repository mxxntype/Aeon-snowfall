{ lib, ... }:

{
    generators.stylesheets.ddg = { theme }: let
        metadata = /* css */ ''
            /* ==UserStyle==
            @name DuckDuckGo Catppuccin
            @namespace github.com/catppuccin/userstyles/styles/duckduckgo
            @homepageURL https://github.com/catppuccin/userstyles/tree/main/styles/duckduckgo
            @version 2025.09.24
            @updateURL https://github.com/catppuccin/userstyles/raw/main/styles/duckduckgo/catppuccin.user.less
            @supportURL https://github.com/catppuccin/userstyles/issues?q=is%3Aopen+is%3Aissue+label%3Aduckduckgo
            @description Soothing pastel theme for DuckDuckGo
            @author Catppuccin
            @license MIT

            @preprocessor less
            @var select lightFlavor "Light Flavor" ["latte:Latte*", "frappe:Frappé", "macchiato:Macchiato", "mocha:Mocha"]
            @var select darkFlavor "Dark Flavor" ["latte:Latte", "frappe:Frappé", "macchiato:Macchiato", "mocha:Mocha*"]
            @var select accentColor "Accent" ["rosewater:Rosewater", "flamingo:Flamingo", "pink:Pink", "mauve:Mauve*", "red:Red", "maroon:Maroon", "peach:Peach", "yellow:Yellow", "green:Green", "teal:Teal", "blue:Blue", "sapphire:Sapphire", "sky:Sky", "lavender:Lavender", "subtext0:Gray"]
            ==/UserStyle== */
        '';

        stylesheet = /* css */ ''
            @-moz-document domain("duckduckgo.com") {
                :root:not(.dark-bg, .no-theme) {
                    #catppuccin(@lightFlavor);
                }

                :root.dark-bg {
                    #catppuccin(@darkFlavor);
                }

                :root.no-theme {
                    @media (prefers-color-scheme: light) {
                        #catppuccin(@lightFlavor);
                    }
                    @media (prefers-color-scheme: dark) {
                        #catppuccin(@darkFlavor);
                    }
                }

                #catppuccin(@flavor) {
                    #lib.palette();

                    --sds-color-text-02: @text !important;
                    --sds-color-text-disabled: @overlay0 !important;
                    --theme-col-txt-page-separator: @text !important;
                    --theme-col-page-separator: @text !important;
                    --theme-col-txt-url: @text !important;
                    --theme-col-txt-title-visited: @mauve !important;
                    --theme-col-txt-snippet: @text !important;
                    --theme-col-txt-card-title: @text;
                    --theme-col-txt-url-domain: @subtext1 !important;
                    --theme-col-txt-title: @blue !important;
                    --theme-col-bg-card: @surface0 !important;
                    --theme-col-about-link: @blue;
                    --theme-col-border-ui: @surface1 !important;
                    --theme-col-bg-expandcollapse: @surface0 !important;
                    --sds-color-palette-gray-60: @accent !important;
                    --sds-color-text-accent-01: @accent !important;
                    --theme-col-txt-msg: @text !important;
                    --theme-col-txt-url-path: @subtext0 !important;
                    --theme-col-border-expandcollapse: @surface1;
                    --col-blue-50: @sapphire !important;
                    --col-blue-60: @blue !important;
                    --theme-col-bg-page: @base !important;
                    --sds-color-text-01: @text !important;
                    --sds-color-text-on-color: @base !important;
                    --theme-spp-high-contrast-text-secondary: @accent !important;
                    --theme-spp-high-contrast-card-indicator-color: @surface0 !important;
                    --theme-spp-high-contrast-title-span-text: @text !important;
                    --theme-spp-high-contrast-bg: @surface0 !important;
                    --sds-color-palette-yellow-50: @yellow !important;
                    --sds-color-text-04: @subtext1 !important;
                    --theme-col-txt-card-body: @text !important;
                    --theme-col-txt-qna-details: @subtext0 !important;
                    --theme-col-txt-card: @text !important;
                    --sds-color-text-03: @subtext0 !important;
                    --col-slate-light: @subtext0;
                    --col-silver-dark: @overlay1;
                    --theme-col-txt-button-secondary: @accent !important;
                    --theme-bg-legacy-home: @base !important;
                    --theme-bg-cta-cards: @surface0 !important;
                    --theme-button-primary-bg: @blue !important;
                    --theme-button-primary-bg--hover: @blue !important;
                    --theme-button-primary-bg--active: @blue !important;
                    --theme-button-primary-text: @crust !important;
                    --theme-badge-fg--green: @crust !important;
                    --theme-browser-comparison-table-check-bg: @green !important;
                    --theme-browser-comparison-table-cross-bg: @red !important;
                    --theme-searchbox-bg: @surface0 !important;
                    --theme-searchbox-bg--hover: @surface0 !important;
                    --theme-searchbox-bg--active: @surface0 !important;
                    --theme-searchbox-bg--focused: @surface0 !important;
                    --theme-border-color-legacy-home-searchbox: @surface2 !important;
                    --theme-button-link-text: @blue !important;
                    --theme-browser-comparison-table-badge-text: @text !important;
                    --theme-badge-bg--green: @green !important;
                    --theme-badge-bg--yellow: @yellow !important;
                    --theme-atb-button-bg: @blue;
                    --theme-atb-button-bg--hover: @blue;
                    --theme-atb-button-bg--active: @blue;
                    --col-silver-light: @surface1 !important;
                    --theme-col-card-inner-border: @surface2 !important;
                    --sds-color-text-link-02: @text !important;
                    --sds-color-text-link-02--hover: @subtext1 !important;
                    --theme-text-legacy-home: @text !important;
                    --theme-browser-comparison-table-row-bg: @surface0 !important;
                    --theme-browser-comparison-table-row-alt-bg: @surface1 !important;
                    --theme-bg-home-bottom: @base !important;
                    --theme-atb-card-back-bg: @surface0 !important;
                    --theme-atb-card-front-bg: @surface1 !important;
                    --theme-text-bg: @text !important;
                    .featureCards_root__brAX3 {
                        --feature-card-background-color: @surface0 !important;
                    }
                    --theme-accordion-background--expanded: @surface0 !important;
                    --theme-accordion-background: @surface1 !important;
                    --theme-footer-link-text: @blue !important;
                    --theme-sidemenu-bg: @surface0 !important;
                    --theme-col-txt-button-tertiary: @text !important;
                    --theme-bg-legacy-home-searchbox: @surface0 !important;
                    --theme-bg-info-snippet: @surface2 !important;
                    --theme-button-tertiary-txt: @text !important;
                    --theme-browser-comparison-table-icon-bg: @mantle !important;
                    --theme-col-bg-ui: @mantle !important;
                    --theme-col-bg-header: @mantle !important;
                    --theme-col-bg-header-modal: @surface0 !important;
                    --theme-col-bg-button-primary: @blue !important;
                    --sds-color-background-dark: @crust !important;
                    /* ai chat */
                    --sds-color-text-link-02-hover: @text !important;
                    --theme-dc-color-background-dark: @base !important;
                    --theme-dc-color-gpt-main: @mauve !important;
                    --theme-dc-color-gpt-bg: @mauve !important;
                    --theme-dc-color-claude-main: @green !important;
                    --theme-dc-color-claude-bg: @green !important;
                    --sds-color-background-destructive: @red !important;
                    --sds-color-text-on-dark-01: @text !important;
                    --theme-dc-color-fire-button: fade(@red, 40%) !important;
                    --sds-color-background-destructive-state-01: @red !important;
                    --sds-color-background-destructive-state-02: @red !important;
                    --sds-color-text-destructive: @red !important;
                    --sds-color-text-success: @green !important;
                    --sds-color-text-link-01: @blue !important;
                    --sds-color-background-container-01: @surface0 !important;
                    --sds-color-border-accent-01: @accent !important;
                    --theme-dc-color-container-message: @surface0 !important;
                    --sds-color-palette-gray-85: @surface1 !important;
                    --sds-color-palette-white: @crust !important;
                    --sds-color-background-accent-01: @accent !important;
                    --theme-col-txt-card-body-light: @text !important;
                    --theme-col-bg-page-alt-2: @surface0 !important;
                    --theme-col-bg-ui-active: @surface1 !important;
                    --theme-dc-color-llama-main: @pink !important;
                    --theme-dc-color-mixtral-main: @peach !important;
                    --theme-dc-color-anchor-sleep: @subtext0 !important;
                    --theme-assist-bg-chat-system: @mantle !important;
                    --theme-assist-gradient-stop: @mantle !important;
                    --sds-color-palette-gray-40: @text !important;
                    /* maps */
                    --sds-color-background-01: @base !important;
                    --sds-color-background-02: @mantle !important;
                    --sds-color-palette-red-40: @red !important;
                    --sds-color-border-01: @surface0 !important;
                    --col-blue-30: @blue !important;
                    --sds-color-palette-green-60: @green !important;
                    --sds-color-background-utility: @surface0 !important;

                    .address-detail {
                        background-color: @mantle;
                        color: @text;
                        border-color: @surface0;
                    }

                    .footer,
                    .footer--mobile,
                    .modal--dropdown--settings,
                    .settings-dropdown--section,
                    .frm__field,
                    .frm__switch,
                    .tileview .metabar--fixed,
                    body,
                    .zci,
                    html,
                    .body--home,
                    html.displayable-atb-banner .body--home,
                    .site-wrapper,
                    .region__body,
                    .badge-link,
                    .module--carousel__image-wrapper,
                    .result__image,
                    .vertical--map__sidebar,
                    .vertical--map__sidebar__header,
                    .page-chrome_newtab,
                    .js-carousel-module-more,
                    .zci--type--tiles:not(.is-fallback).is-full-page.is-expanded,
                    .zci--type--tiles:not(.is-fallback).is-full-page.is-expanded
                        .metabar:not(.is-stuck) {
                        background-color: @base !important;
                    }
                    /* .dropdown--settings--icon .dropdown__button:after needs visibility: hidden, otherwise we get a case of clashing icons */
                    .dropdown__button::after {
                        visibility: hidden;
                    }

                    .privacy-reminder__modal-hide,
                    .privacy-reminder__modal-link {
                        color: @text !important;
                    }

                    /* stopwatch */
                    .zci--stopwatch .time {
                        color: @text !important;
                    }
                    .label {
                        color: @text;
                        background-color: @crust;
                    }
                    .stopwatch__btn.start {
                        border-color: @green !important;
                        background-color: @green;
                        color: @mantle !important;
                    }
                    .stopwatch__btn[disabled] {
                        color: @text !important;
                        background-color: @surface0 !important;
                        border-color: @surface0;
                    }
                    .stopwatch__btn.stop {
                        color: @mantle;
                        background-color: @red !important;
                        border-color: @red !important;
                    }
                    .stopwatch__btn {
                        background-color: @surface2;
                        border-color: @surface2;
                        color: @text;
                    }
                    .zci--stopwatch td {
                        color: @text;
                    }

                    /* html chars */
                    .record__body,
                    .chomp--link__mr,
                    .tx-clr--lt2 {
                        color: @text;
                    }
                    .c-list__item {
                        border-color: @mantle;
                    }
                    .chomp--link__icn::before {
                        color: @text;
                    }

                    /* cal */
                    .calendar .t_right,
                    .calendar .t_left {
                        background-color: @surface2;
                    }
                    .calendar__header {
                        color: @text;
                    }
                    table.calendar tr {
                        color: @text;
                    }
                    .calendar__today {
                        color: @mantle;
                        background-color: @accent;
                    }

                    .zci.is-active {
                        border-color: @surface0;
                    }

                    .module__toggle--more::after {
                        background: linear-gradient(transparent, @surface0);
                    }

                    /* button on hover */
                    .btn:hover:not(.is-disabled) {
                        background-color: @mantle;
                        color: @blue;
                        border-color: @mantle;
                    }

                    /* stocks infobox */
                    .stocks-module__currentPrice,
                    .stocks-module__exchange,
                    .stocks-module__currency,
                    .stocks-module__stats {
                        color: @text;
                    }
                    .stocks-module__timePeriod {
                        background-color: @surface2;
                        color: @text;
                    }
                    .stocks-module__latestUpdate,
                    .ia-module--stocks a.stocks-module__attribution,
                    .stocks-module__footer {
                        color: @subtext1;
                    }
                    .stocks-module__timePeriod.selected {
                        color: @mantle;
                        background-color: @accent;
                    }
                    .ia-module--stocks.increase .color-coded {
                        color: @green !important;
                    }
                    .stocks-module__hover-label {
                        &[style*="color: rgb(222, 88, 51);"] {
                            color: @red !important;
                        }
                        &[style*="color: rgb(91, 158, 77);"] {
                            color: @green !important;
                        }
                    }
                    .ia-module--stocks.increase .color-coded path {
                        stroke: @green;
                        fill: @green;
                    }
                    .ia-module--stocks
                        .stocks-module__chart-area-row
                        .stocks-module__chart
                        svg {
                        [stroke="#de5833"] {
                            stroke: @red !important;
                        }
                        [fill="#de5833"] {
                            fill: @red !important;
                        }
                        [stroke="#5b9e4d"] {
                            stroke: @green !important;
                            [fill="#5b9e4d"] {
                                fill: @green !important;
                            }
                        }
                    }
                    .ia-module--stocks.decrease .color-coded {
                        color: @red;
                    }
                    .ia-module--stocks.decrease .color-coded path {
                        stroke: @red;
                        fill: @red;
                    }
                    .ia-module--stocks
                        .stocks-module__stats-wrapper
                        .stocks-module__stats
                        .stocks-module__stat-col
                        .stocks-module__stat {
                        border-bottom-color: @overlay0;
                    }
                    .stocks-module__chart .horizontal-line,
                    .stocks-module__chart .vertical-line,
                    .stocks-module__chart .prev-close-line {
                        stroke: @surface2;
                    }

                    /* color box */
                    .tx-clr--lt {
                        color: @text;
                    }
                    .tx-clr--dk2 {
                        color: @subtext0;
                    }

                    /* ai chat >:( */
                    .feedback-external__link {
                        color: @blue;
                    }
                    .feedback-duckchat-modal__disclaimer {
                        color: @text;
                    }
                    .feedback-modal__radio {
                        color: @text;
                    }
                    .modal__close {
                        color: @text;
                    }
                    /* lyrics box */
                    .js-lyrics-module {
                        color: @subtext1 !important;
                    }
                    .module--lyrics__subtitle-box {
                        border-color: @surface2;
                    }
                    .module__inner-toggle--chevron {
                        color: @accent !important;
                        background-color: @surface1 !important;
                        border-color: @surface2;
                    }
                    .module__inner-toggle::before,
                    .module__inner-toggle::after {
                        background-color: @surface2 !important;
                    }
                    .module--lyrics:not(.is-expanded)
                        .module--lyrics__footer.can-expand::after {
                        background: linear-gradient(transparent, @surface0);
                    }
                    .module--lyrics__explicit-tag {
                        border-color: @subtext1;
                        color: @subtext0;
                    }

                    // translation boxes
                    .module--translations .dropdown--translation-select,
                    .module--translations-translatedtext {
                        background: @surface0 !important;
                        border-color: @surface0;
                    }
                    .module--translations .module--translations-translatedtext.is-placeholder {
                        color: @subtext0;
                    }
                    .module--translations-swap-svg {
                        fill: @text !important;
                    }
                    .module--translations-original textarea,
                    .module--translations-translatedtext,
                    .module--translations-footer a {
                        color: @text;
                    }
                    .module--translations-clear,
                    .module--translations-copy {
                        color: @subtext0 !important;
                    }
                    .modal__list__filter input {
                        background: @mantle;
                    }

                    //coding info box
                    .module:not(
                        .module--carousel,
                        .module--placeholder,
                        .module--images,
                        .module--translations,
                        .module__chromeless
                    ) {
                        background: @surface0 !important;
                        border-color: @surface1 !important;
                    }
                    .module__toggle,
                    .tile__expand {
                        background-color: @surface0 !important;
                        border-color: @surface1 !important;
                    }

                    .module__title__link,
                    .module__text,
                    .pln,
                    .pun,
                    code,
                    .module__more-at-bottom {
                        color: @text !important;
                    }
                    code {
                        background-color: @mantle !important;
                    }
                    .lit {
                        color: @peach !important;
                    }
                    .com {
                        color: @subtext1 !important;
                    }
                    .str {
                        color: @green !important;
                    }
                    .atv {
                        color: @teal !important;
                    }
                    .module__title__sub {
                        color: @subtext0;
                    }
                    .prettyprint {
                        background-color: @mantle;
                    }
                    .is-link-style-exp .btn--primary:not(.is-disabled) {
                        background-color: @blue !important;
                        border-color: @blue !important;
                        color: @mantle !important;
                    }

                    .featureCards_dark__5Xbsn {
                        background: linear-gradient(180deg, @yellow, @blue);
                    }

                    .modal__box.modal__box--feedback.modal__box--headed .modal__box__header {
                        background-color: @surface0 !important;
                    }

                    // defentions info box
                    .module--definitions__pronunciation {
                        color: @subtext0 !important;
                    }

                    .module--definitions__group ol li::before {
                        color: @accent !important;
                    }

                    .module--definitions__usage {
                        color: @subtext0 !important;
                    }
                    .module__title,
                    .module--definitions__definition {
                        color: @text !important;
                    }

                    .play-btn__icn_hollow {
                        fill: @accent !important;
                    }
                    .module__toggle {
                        color: @accent !important;
                    }

                    // weather info box
                    .forecast-wrapper .module__weather-warning--red,
                    .module__weather-warning--red:hover,
                    .module__weather-warning--red:focus,
                    .module__weather-warning--red:visited {
                        color: @red !important;
                    }
                    .module__weather-warning {
                        color: @yellow !important;
                    }
                    .text--primary,
                    .tx-clr--dk,
                    .tx-clr--slate,
                    .module__temperature-unit:not(.module__temperature-unit--on),
                    .module__items-day {
                        color: @subtext0 !important;
                    }
                    .module__temperature-unit,
                    .module__temperature-unit:hover {
                        color: @accent !important;
                    }
                    .module__detail__precip-label,
                    .module__items-precip-label,
                    .ia-module--module--definitions__reference,
                    .js-definitions-internal {
                        color: @blue !important;
                    }
                    .module__detail__hour-label,
                    .module__current,
                    .module__detail__temp-label,
                    .module__items-unit--on {
                        color: @text !important;
                    }
                    .module__items-item {
                        background: @surface0 !important;
                        border-color: @surface2 !important;
                    }
                    .module__weatherkit-logo {
                        fill: @accent;
                    }
                    .module__warnings,
                    .module__temperature-unit--on {
                        border-color: @surface2 !important;
                    }

                    //calculator
                    .tile__ctrl__btn,
                    .tile__history,
                    .tile__past-calc {
                        background: @surface0 !important;
                        border-color: @surface2 !important;
                        color: @text !important;
                    }
                    .attribution--link__icon {
                        color: @text;
                    }
                    .tile__ctrl__toggle-slider {
                        background: @surface1 !important;
                    }
                    .tile__ctrl__toggle-slider::before {
                        background-color: @mantle !important;
                    }
                    .tile__tab__sci .tile__ctrl__btn,
                    .tile__ctrl__toggle {
                        background-color: @surface2 !important;
                        color: @text !important;
                        border-color: @overlay0 !important;
                    }
                    .tile__display__main,
                    .tile__past-result {
                        color: @text !important;
                    }
                    .tile__display__main {
                        background-color: @base !important;
                    }
                    .tile__display {
                        box-shadow:
                            inset -1px -1px 0 @overlay0,
                            inset 1px 1px 0 @overlay0 !important;
                        background-color: @base !important;
                        border-color: @surface2 !important;
                        color: @text !important;
                    }
                    .tile__display.selected {
                        box-shadow: inset -1px -1px 0 @blue, inset 1px 1px 0 @blue !important;
                    }
                    .tile__ctrl--important {
                        background-color: @yellow !important;
                        color: @mantle !important;
                    }
                    .tile__display__aside,
                    .tile__past-formula,
                    .tile__option {
                        color: @subtext0 !important;
                    }
                    .tile__option--active {
                        color: @accent !important;
                    }

                    .bg-delayed-color {
                        background-color: @red;
                    }

                    #error_homepage {
                        background-color: @rosewater !important;
                        color: @red !important;
                    }

                    .search--adv {
                        background-color: @surface0 !important;
                        border-color: @surface0 !important;
                    }

                    .open-in-app__deep-link {
                        color: @mantle;
                    }

                    .modal__header__clear,
                    .sep--before,
                    .js-region-filter-clear,
                    .result__a,
                    .module--carousel__body__title,
                    .js-carousel-module-more,
                    .js-no-results-web,
                    .bing .tile__title--pr a,
                    .sidebar-filter__show-more,
                    .module__footer,
                    .js-settings-dropdown-reset-appearance,
                    .modal--dropdown--settings .settings-dropdown--button,
                    .settings-page-wrapper a:not(.btn, .set-tab),
                    .module__link--blue,
                    .place-list-item__cta-item__text {
                        color: @blue !important;
                    }

                    .tile__title a:visited {
                        color: @mauve;
                    }

                    .place-detail__status--off {
                        color: @red;
                    }

                    .place-detail__status--on {
                        color: @green;
                    }

                    .result__a:visited {
                        color: @mauve !important;
                    }
                    .bg-clr--green {
                        background-color: @green;
                    }
                    .tile__status,
                    .osGBsMSM4O7_HVv5OcxQ,
                    .C68Y1fiPXCZijXmzVAbe {
                        color: @mantle !important;
                    }

                    .modal__header,
                    .modal__footer,
                    .modal__box,
                    .tile,
                    .related-searches__item,
                    .bg-clr--white,
                    .tile__media__free-shipping-label,
                    .sidebar-filter__options,
                    .sidebar-filter__option.is-size,
                    .module__footer,
                    .frm__select,
                    .set-bookmarklet,
                    .set-reset,
                    .search__autocomplete,
                    .frm__input,
                    .frm__color__swatch {
                        border-color: @surface0 !important;
                        background-color: @crust !important;
                    }

                    .sep--before::before,
                    .sep {
                        border-left-color: @surface2;
                    }

                    .header-wrap {
                        box-shadow: none !important;
                    }

                    .header-wrap,
                    .module--carousel__left,
                    .module--carousel__right,
                    .detail,
                    .btn {
                        background-color: @mantle;
                    }

                    .set-header--fixed .tileview--grid .metabar--fixed,
                    .tileview--grid .metabar--fixed.is-stuck {
                        background-color: @surface0;
                        border-top-color: @surface0;
                    }

                    .modal--dropdown--region.modal--popout .frm__input,
                    .js-region-filter-list,
                    .tile__body,
                    .bg-clr--white,
                    .acp-wrap,
                    .tile__media__free-shipping-label,
                    .tile__media--pr,
                    .modal__box,
                    .nav-menu__list,
                    .set-tab.is-active,
                    .frm__select select,
                    .cloudsave,
                    .feedback-btn__send,
                    .set-bookmarklet__input,
                    .howItWorksSection_downloadsCard__U3Ph9,
                    .metabar__grid-btn,
                    .feedback-btn__icon-wrap .set-bookmarklet__input .btn,
                    .btn.btn--secondary,
                    .btn.is-disabled,
                    input,
                    textarea,
                    .frm__input,
                    .frm__text,
                    .detail--xd .c-detail__btn,
                    .set-bookmarklet,
                    .set-reset,
                    .zci--json_validator textarea,
                    .colorpicker,
                    .feedback-modal__submit.is-disabled,
                    .feedback-modal__submit.is-disabled:active,
                    .feedback-modal__submit.is-disabled:focus,
                    .module__section,
                    .module--carousel__item,
                    .is-related-search-exp.dark-bg,
                    .related-searches__item,
                    .detail--xd .tile-nav--sm,
                    .set-bookmarklet__detail,
                    .set-reset__detail,
                    .module__footer,
                    .js-definitions-internal {
                        background-color: @surface0 !important;
                    }
                    .module--carousel__item {
                        border-color: @surface1 !important;
                    }

                    .modal__header,
                    .module__section,
                    .module__section:first-child.place-detail__section--tab,
                    .module__clickable-header {
                        border-color: @surface1 !important;
                    }

                    .btn.is-disabled:hover,
                    .frm__switch__label:hover,
                    .feedback-modal__submit.is-disabled:hover,
                    .btn.btn--skeleton:hover,
                    .module__footer-carousel__label:hover {
                        background-color: @surface2 !important;
                        border-color: @surface2 !important;
                    }
                    .is-checked .frm__switch__label.btn {
                        background-color: @accent !important;
                        color: @mantle !important;
                    }
                    .js-set-exit {
                        background-color: @accent !important;
                        border-color: @accent !important;
                        color: @base !important;
                    }
                    .js-set-exit:hover {
                        background-color: fade(@accent, 80%) !important;
                        border-color: fade(@accent, 80%) !important;
                        color: @base !important;
                    }
                    .set-bookmarklet__data {
                        background-color: @surface2;
                        color: @text;
                    }

                    .modal__list__link.is-highlighted,
                    .modal__list li:hover {
                        background-color: @overlay1;
                    }

                    .metabar__dropdowns-wrap::before {
                        background-image: linear-gradient(90deg, @base, transparent);
                    }

                    .metabar__dropdowns-wrap::after {
                        background-image: linear-gradient(90deg, transparent, @base);
                    }

                    .nav-menu__item__badge {
                        background-color: @yellow;
                        color: @mantle;
                    }

                    .settings-dropdown--section,
                    .set-head,
                    .frm__hr {
                        border-bottom-color: @surface2;
                    }

                    .zcm--right-fade::before {
                        background: linear-gradient(90deg, transparent, @mantle);
                    }
                    .search-filters-wrap::before {
                        background: linear-gradient(90deg, @base, transparent);
                    }

                    .search-filters-wrap::after {
                        background: linear-gradient(90deg, transparent, @base);
                    }

                    .footer,
                    .footer--mobile {
                        border-top-color: @surface0;
                    }

                    .is-vertical-tabs-exp,
                    #duckbar,
                    .zcm__link:not(.dropdown__button).is-active,
                    .set-main-footer {
                        border-color: @accent !important;
                    }

                    #more-results {
                        background-color: @surface0 !important;
                    }

                    input,
                    select,
                    h1,
                    h2,
                    h4,
                    h5,
                    h6,
                    ul,
                    ol,
                    blockquote,
                    p,
                    body,
                    .module--carousel__footer,
                    .set-tab.is-active,
                    .zcm__link,
                    .feedback-prompt__link,
                    .feedback-btn__send,
                    .tile--img__sub,
                    .result__snippet,
                    .result__snippet b,
                    .modal__list__link,
                    .acp,
                    .header_headerButton__cLYU3,
                    .is-vertical-tabs-exp,
                    .module.module--images,
                    .module__header.module__header--link,
                    .text--title,
                    .text--airline-flight,
                    .timing,
                    .flight-details__values,
                    .airlines-footer,
                    .tx-clr--slate,
                    .nav-menu__heading,
                    .zci,
                    .metabar__grid-btn,
                    .module--carousel__left,
                    .module--carousel__right,
                    .c-detail__title__sub,
                    .c-detail__desc,
                    .c-detail__filemeta,
                    .c-detail__more,
                    .frm__label,
                    .js-cloudsave-new-suggestion,
                    .zci__body,
                    .zci__body a,
                    .c-base__title {
                        color: @text !important;
                    }

                    .zci--airlines .text--title svg path {
                        fill: @text;
                    }

                    .star {
                        color: @overlay2;
                    }

                    .set-tab,
                    .set-tab:visited,
                    .tile-nav.can-scroll {
                        background-color: @mantle;
                        color: @overlay1;
                    }

                    .js-cloudsave-save-btn,
                    .js-cloudsave-load-btn {
                        background-color: @surface2;
                        border-color: @overlay0;
                        color: @text;
                    }

                    .video-source,
                    .tile__count,
                    .result__url,
                    .tile__time,
                    .feedback-prompt,
                    .footer__text,
                    .vertical--news .result__url,
                    .result__timestamp,
                    .js-metabar-secondary,
                    .sidebar-filters,
                    .tile--pr__original-price,
                    .nav-menu__item a,
                    .nav-menu__close,
                    .frm__desc,
                    .dropdown__button,
                    .tx-clr--slate-light,
                    .flight-details__labels,
                    .scheduled-time,
                    .source-link,
                    .tile__source,
                    .zci__more-at,
                    .cloudsave__close,
                    .module--definitions__attribution-text,
                    .module__attribution,
                    .module__attribution-link {
                        color: @subtext0 !important;
                    }

                    .dropdown--region.has-inactive-region .dropdown__button::after,
                    .modal--dropdown--region.modal--popout .modal__header::before,
                    .js-carousel-module-title,
                    .tile--pr__brand,
                    .frm__select,
                    .star::after,
                    .feedback-btn__icon,
                    .detail--xd .tile-nav--sm,
                    .detail__close,
                    .module--definitions__collapsed-group ol li::before {
                        color: @accent !important;
                    }

                    .search__button:hover,
                    .search--header.has-text.search--hover .search__button {
                        background-color: @accent !important;
                        color: @base !important;
                    }

                    .settings-page-wrapper.is-checked {
                        border-color: @blue;
                        background-color: @sapphire !important;
                        color: @mantle !important;
                    }
                    .modal--dropdown--settings
                        .settings-dropdown--section
                        .settings-dropdown--header {
                        .settings-dropdown--header--link,
                        .settings-dropdown--header--label {
                            color: @text !important;
                        }
                    }
                    .ddgsi-check::before {
                        color: @mantle !important;
                    }
                    .set-bookmarklet__title,
                    .set-reset__title {
                        color: @text !important;
                    }
                    .frm__select::after {
                        color: @accent !important;
                    }

                    .switch,
                    .frm__switch__label {
                        background-color: @crust !important;
                    }

                    .frm__switch__label::after {
                        background: @overlay2 !important;
                    }

                    .is-checked .frm__switch__label::after {
                        background: @base !important;
                    }

                    .switch__knob {
                        background: @overlay2 !important;
                    }

                    .is-on .switch__knob {
                        background: @base !important;
                    }

                    .switch.is-on {
                        background-color: @accent !important;
                    }

                    .dropdown__switch.is-on::before {
                        color: @base !important;
                    }

                    .search--header {
                        background-color: @surface0;
                        border-color: @surface0;
                    }

                    .acp--highlight,
                    .bg-clr--platinum-light {
                        background-color: @overlay0;
                    }
                }
            }

            @-moz-document domain("start.duckduckgo.com") {
                :root:not(.theme-dark) {
                    #catppuccin(@lightFlavor);
                }

                :root.theme-dark {
                    #catppuccin(@darkFlavor);
                }

                #catppuccin(@flavor) {
                    #lib.palette();

                    color-scheme: if(@flavor = latte, light, dark);

                    ::selection {
                        background-color: fade(@accent, 30%);
                    }

                    // TODO: Why does this ::placeholder from defaults explicitly not apply to <input>?
                    textarea {
                        &::placeholder {
                            color: @subtext0 !important;
                        }
                    }

                    input {
                        background-color: @surface0 !important;
                        color: @text !important;
                    }
                    li:hover {
                        background-color: @surface2 !important;
                    }
                    ul {
                        background-color: @surface0 !important;
                    }
                    body {
                        background-color: @base !important;
                    }
                    h1,
                    h2,
                    h3,
                    p,
                    a,
                    span {
                        color: @text !important;
                    }

                    --color-yellow60: @yellow !important;
                    --theme-button-primary-bg: @blue !important;
                    --theme-searchbox-caret-bg: @accent !important;

                    .home_root__naJUp {
                        --theme-bg-home: @base !important;
                        --theme-button-secondary-text: @text !important;
                        --theme-text-bg: @text !important;
                        --theme-bg-home-searchbox: @surface0 !important;
                        --theme-border-color-home-searchbox: @surface0 !important;
                    }
                    .searchbox_suggestions__umkQH {
                        --theme-searchbox-bg: @surface0 !important;
                    }
                    .header_headerButton__cLYU3 {
                        color: @text !important;
                    }
                    .sideMenu_sideMenuContent__OE7n9,
                    .searchbox_iconWrapper__suWUe {
                        background-color: @surface0 !important;
                    }
                    .button_primary__e2_Sy {
                        color: @mantle !important;
                    }
                    .searchbox_hasQuery__j8_VE:hover
                        .searchbox_searchButton__F5Bwq:not(:disabled),
                    .searchbox_hasQuery__j8_VE:focus-within {
                        color: @mantle !important;
                        background-color: @accent !important;
                    }
                }
            }
        '';
    in lib.aeon.generators.stylesheets.fromCatppuccin.intoDynamicStylesheet {
        inherit metadata stylesheet theme;
    };
}
