{ lib, ... }:

{
    generators.stylesheets.nixos-wiki = { theme }: let
        metadata = /* css */ ''
            @preprocessor less
            @var select lightFlavor "Light Flavor" ["latte:Latte*", "frappe:Frappé", "macchiato:Macchiato", "mocha:Mocha"]
            @var select darkFlavor "Dark Flavor" ["latte:Latte", "frappe:Frappé", "macchiato:Macchiato", "mocha:Mocha*"]
            @var select accentColor "Accent" ["rosewater:Rosewater", "flamingo:Flamingo", "pink:Pink", "mauve:Mauve*", "red:Red", "maroon:Maroon", "peach:Peach", "yellow:Yellow", "green:Green", "teal:Teal", "blue:Blue", "sapphire:Sapphire", "sky:Sky", "lavender:Lavender", "subtext0:Gray"]
            @var checkbox highlight-redirect "Highlight redirect links" 0
        '';

        stylesheet = /* css */ ''
            @-moz-document domain("wiki.nixos.org") {
                :root {
                    @media (prefers-color-scheme: light) {
                        #catppuccin(@lightFlavor);
                    }
                    @media (prefers-color-scheme: dark) {
                        #catppuccin(@darkFlavor);
                    }
                }

                #catppuccin(@flavor) {
                    #lib.palette();

                    --background-color-base: @base;
                    --home-panel-heading-background: @mantle;
                    --home-panel-border-color: @surface0;
                    --table-border-color: @crust;
                    --table-header-background: @surface1;
                    --table-even-background: @surface2;

                    background-color: @base;

                    body,
                    .vector-feature-zebra-design-enabled .vector-header-container .mw-header,
                    .vector-feature-zebra-design-enabled .mw-page-container,
                    .vector-feature-zebra-design-enabled .vector-pinned-container,
                    .vector-feature-zebra-design-enabled
                        .vector-dropdown
                        .vector-dropdown-content,
                    .uls-lcd,
                    .uls-search,
                    .uls-filtersuggestion,
                    #uls-settings-block.uls-settings-block--vector-2022.uls-settings-block--with-add-languages,
                    .app-badges .footer-sidebar-content,
                    .pure-form input[type="search"],
                    .suggestions-dropdown,
                    .cdx-menu,
                    .vector-header-container .mw-header,
                    .mw-page-container,
                    .vector-pinned-container,
                    .vector-header-container .vector-sticky-header,
                    .mw-mmv-image,
                    .mw-body,
                    .frb-form-wrapper,
                    .mw-echo-ui-placeholderItemWidget,
                    .oo-ui-popupWidget-popup,
                    .mw-echo-ui-notificationItemWidget,
                    .oo-ui-optionWidget-selected {
                        background-color: @base;
                    }

                    body,
                    .mw-heading,
                    h1,
                    h2,
                    h3,
                    h4,
                    h5,
                    h6,
                    .vector-feature-zebra-design-enabled body,
                    .vector-feature-zebra-design-enabled
                        .vector-toc
                        .vector-toc-list-item-active
                        > .vector-toc-link,
                    .vector-feature-zebra-design-enabled
                        .vector-toc
                        .vector-toc-level-1-active:not(.vector-toc-list-item-expanded)
                        > .vector-toc-link,
                    .vector-feature-zebra-design-enabled
                        .vector-toc
                        .vector-toc-list-item-active.vector-toc-level-1-active
                        > .vector-toc-link,
                    .vector-menu-tabs .mw-list-item.selected a,
                    .vector-menu-tabs .mw-list-item.selected a:visited,
                    .cdx-button:enabled,
                    .cdx-button.cdx-button--fake-button--enabled,
                    .mw-footer li,
                    .vector-feature-zebra-design-enabled
                        .vector-toc
                        .vector-toc-level-1-active:not(.vector-toc-list-item-active)
                        > .vector-toc-link,
                    .central-featured-lang small,
                    .footer-sidebar-text,
                    .other-project-tagline,
                    .site-license,
                    .search-container .js-langpicker-label,
                    .langlist > ul > li,
                    .suggestion-title,
                    .cdx-menu-item--enabled .cdx-menu-item__content,
                    .mwe-popups .mwe-popups-extract,
                    .mw-body-content .mw-number-text h3,
                    .vector-pinnable-element .vector-menu-heading,
                    .vector-toc .vector-toc-list-item-active > .vector-toc-link,
                    .vector-toc
                        .vector-toc-level-1-active:not(.vector-toc-list-item-expanded)
                        > .vector-toc-link,
                    .vector-toc
                        .vector-toc-list-item-active.vector-toc-level-1-active
                        > .vector-toc-link,
                    .uls-empty-state .uls-empty-state__header,
                    .uls-empty-state .uls-empty-state__desc,
                    .uls-no-results-found-title,
                    .mw-mmv-post-image,
                    .mw-mmv-credit,
                    .frb-form-wrapper,
                    .mw-echo-ui-notificationItemWidget-content-message-header,
                    .oo-ui-labelElement,
                    #contentSub:not(:empty) {
                        color: @text !important;
                    }

                    .mw-parser-output .fmbox {
                        border-color: @surface2 !important;
                        background-color: @base !important;
                    }

                    .cdx-thumbnail__image {
                        border-color: @text;
                    }

                    /* maths */
                    .equation-box,
                    .equation-box * {
                        background: none !important;
                    }
                    img.mwe-math-fallback-image-display,
                    img.mwe-math-fallback-image-inline {
                        & when (@flavor = latte) {
                            filter: brightness(0) saturate(100%) invert(31%) sepia(9%) saturate(
                                1499%
                            ) hue-rotate(196deg) brightness(90%) contrast(85%);
                        }

                        & when (@flavor = frappe) {
                            filter: brightness(0) saturate(100%) invert(92%) sepia(6%) saturate(
                                3753%
                            ) hue-rotate(184deg) brightness(93%) contrast(106%);
                        }

                        & when (@flavor = macchiato) {
                            filter: brightness(0) saturate(100%) invert(82%) sepia(7%) saturate(
                                1042%
                            ) hue-rotate(193deg) brightness(103%) contrast(92%);
                        }

                        & when (@flavor = mocha) {
                            filter: brightness(0) saturate(100%) invert(83%) sepia(28%) saturate(
                                223%
                            ) hue-rotate(190deg) brightness(99%) contrast(93%);
                        }
                    }

                    .mwe-popups .mwe-popups-extract[dir="ltr"]::after {
                        background-image: linear-gradient(
                            to right,
                            rgba(255, 255, 255, 0),
                            @surface0 50%
                        );
                    }
                    table {
                        background: @surface2 !important;
                    }

                    tr {
                        background-color: @surface0 !important;
                    }

                    th {
                        background: @overlay0 !important;
                        color: @mantle !important;
                    }

                    .quotebox,
                    div.thumbinner {
                        background-color: @surface0 !important;
                        border-color: @surface2 !important;
                    }

                    .navbox-group,
                    .infobox-label {
                        color: @text !important;
                    }

                    .cdx-button:enabled,
                    .cdx-text-input__input:enabled {
                        color: @text;
                        background-color: @base;
                        border-color: @surface2;
                        &:hover {
                            background-color: @mantle;
                            border-color: @text;
                            color: @text;
                        }
                    }

                    .vector-dropdown .vector-dropdown-content,
                    .header-container.header-chrome {
                        background-color: @mantle;
                    }

                    .skin-vector .uls-search {
                        border-bottom-color: @surface2;
                    }

                    .oo-ui-textInputWidget,
                    .oo-ui-inputWidget-input {
                        color: @text !important;
                        background-color: @surface1 !important;
                        border-color: @surface2 !important;
                    }

                    .oo-ui-pendingElement-pending {
                        background-color: @base;
                        background-image: linear-gradient(
                            135deg,
                            @surface0 25%,
                            transparent 25%,
                            transparent 50%,
                            @surface0 50%,
                            @surface0 75%,
                            transparent 75%,
                            transparent
                        );
                    }

                    .oo-ui-tagItemWidget.oo-ui-widget-disabled {
                        color: @text;
                        background-color: @overlay0;
                        text-shadow: 0 0 0 @text;
                        border-color: @surface0;
                    }

                    .oo-ui-buttonElement-frameless.oo-ui-widget-enabled
                        > .oo-ui-buttonElement-button,
                    .mw-mmv-credit,
                    .mw-mmv-options-dialog-header,
                    .mw-mmv-options-text-header {
                        color: @text;
                    }

                    .mw-mmv-options-text-body {
                        color: @subtext0;
                    }

                    .mw-ui-input:not(:disabled) {
                        background-color: @surface0;
                        color: @text;
                        border-color: @surface2;
                    }

                    .mw-ui-button {
                        color: @mantle;
                        background-color: @accent;
                        border-color: @accent;
                    }

                    .imbox-delete {
                        border-color: @red !important;
                        background-color: @surface0 !important;
                    }

                    .imbox {
                        background-color: @overlay0 !important;
                        border-color: @peach !important;
                    }

                    .talkheader-help {
                        background-color: @surface1 !important;
                        border-color: @green !important;
                    }

                    .assess,
                    .assess-NA,
                    .navbox-subgroup {
                        background: @surface0 !important;
                        border-color: @surface1 !important;
                    }

                    .documentation,
                    .documentation-container,
                    .documentation-metadata {
                        background-color: fade(@green, 15%) !important;
                    }

                    .ambox,
                    .portalborder {
                        background-color: @surface1 !important;
                        border-color: @surface2 !important;
                    }

                    .navbox-title {
                        color: @text !important;
                    }

                    .mw-content-ltr.mw-highlight-lines pre,
                    .mw-content-ltr.content .mw-highlight-lines pre {
                        box-shadow: inset 2.75em 0 0 @mantle;
                    }

                    .mw-redirect when (@highlight-redirect = 1) {
                        color: @green !important;
                    }

                    .mbox-text {
                        color: @text !important;
                    }

                    .sidebar-above,
                    .p,
                    .o {
                        color: @text !important;
                    }
                    .ni,
                    .mw-templatedata-doc-muted {
                        color: @subtext1 !important;
                    }
                    .nv,
                    .nn {
                        color: @blue !important;
                    }

                    .sidebar-above a span {
                        color: @text !important;
                    }

                    .sidebar-title-with-pretitle span {
                        color: @text !important;
                    }

                    .nt {
                        color: @green !important;
                    }

                    .nl {
                        color: @teal !important;
                    }

                    .ambox-style {
                        border-left-color: @yellow !important;
                    }

                    .mw-parser-output .mainpage-frame {
                        background: @surface0 !important;
                        border-color: @surface0 !important;
                    }

                    .mw-parser-output .mainpage-heading-title {
                        background: linear-gradient(
                            to right,
                            rgba(saturate(lighten(@accent, 4%), -3%), 0.4),
                            @surface0
                        ) !important;
                    }

                    .hidden-title {
                        background-color: @green !important;
                        color: @mantle !important;
                    }

                    .mw-mmv-post-image,
                    .mw-mmv-options-dialog {
                        background-color: @base;
                        color: @text;
                    }
                    .mw-mmv-image-metadata {
                        background-color: @base;
                        border-color: @base;
                    }

                    .mw-mmv-dialog-down-arrow {
                        background-color: @base !important;
                    }

                    .oo-ui-tagItemWidget.oo-ui-widget-enabled {
                        color: @text;
                        background-color: @overlay0 !important;
                        border-color: @surface0;
                    }

                    ol.references li:target {
                        background-color: @surface2;
                    }

                    .mw-body-content .error {
                        color: @red;
                    }

                    .divbox-gray,
                    .infobox-above {
                        background-color: @surface2 !important;
                        border-color: @overlay0 !important;
                    }

                    .biota > * > tr > th {
                        background-color: @yellow !important;
                        color: @mantle !important;
                    }

                    .cmbox {
                        background-color: @blue !important;
                    }

                    .wikitable {
                        background-color: @surface0 !important;
                        color: @text !important;
                        border-color: @surface2 !important;
                    }

                    .wikitable > * > tr > th {
                        background-color: @surface1 !important;
                    }

                    .wikitable > * > tr > td,
                    .wikitable > * > tr > th {
                        background-color: @surface0 !important;
                        color: @text !important;
                        border-color: @surface2;
                    }

                    .mw-searchresults-has-iw .iw-result__header a {
                        color: @text;
                    }

                    .mw-search-result-data {
                        color: @subtext0;
                    }

                    .navbox-abovebelow {
                        background-color: @overlay2 !important;
                        border-color: @overlay2 !important;
                    }

                    .vector-feature-zebra-design-enabled
                        .vector-pinnable-element
                        .vector-menu-heading {
                        color: @text;
                        border-bottom-color: @surface0;
                    }

                    .mwe-popups .mwe-popups-container {
                        background-color: @surface0;
                    }

                    .vector-pinnable-header-toggle-button {
                        background-color: @surface0;
                        color: @text;
                        &:hover {
                            background-color: @base;
                        }
                    }

                    .mw-parser-output .navbox-list {
                        border-color: @surface0;
                    }

                    .pure-button-primary-progressive,
                    .pure-button-primary-progressive:hover {
                        background-color: @accent;
                        border-color: @accent;
                    }

                    .suggestion-link {
                        border-bottom-color: @surface0;
                    }

                    .cdx-menu,
                    .skin-vector .uls-menu,
                    .suggestiodns-dropdown,
                    .cdx-search-input--has-end-button,
                    .vector-sticky-header,
                    .vector-sticky-header-context-bar,
                    .mw-heading2 {
                        border-color: @surface2;
                    }

                    .suggestion-link.active {
                        background-color: fade(@accent, 20%);
                        .suggestion-title {
                            color: @accent;
                        }
                    }

                    .mw-echo-ui-pageNotificationsOptionWidget.oo-ui-optionWidget-highlighted,
                    .cdx-menu-item--enabled.cdx-menu-item--highlighted {
                        background-color: fade(@accent, 20%);
                    }

                    .mw-echo-ui-sortedListWidget,
                    .mw-echo-ui-sortedListWidget-group,
                    .mw-echo-ui-subGroupListWidget-header {
                        border-color: @surface2;
                    }

                    .mw-mmv-post-image,
                    .cdx-button.cdx-button--fake-button--enabled.cdx-button--weight-primary.cdx-button--action-progressive
                        .cdx-button__icon {
                        background-color: @crust;
                    }

                    .cdx-text-input__input:enabled::placeholder,
                    .cdx-text-input__input:enabled ~ .cdx-text-input__icon-vue,
                    .skin-vector .uls-languagefilter,
                    .skin-vector .uls-lcd-region-title,
                    .suggestion-description,
                    .cdx-menu-item--enabled .cdx-menu-item__text__description,
                    .mw-number-text,
                    .boilerplate > div:nth-child(3) > span:nth-child(1),
                    .boilerplate > div:nth-child(4) > span:nth-child(2) {
                        color: @subtext0 !important;
                    }

                    input:hover + .cdx-button.cdx-button--action-progressive {
                        background-color: fade(@accent, 12.5%);
                    }

                    #pt-notifications-alert .mw-echo-unseen-notifications::after {
                        background-color: @red !important;
                    }

                    #pt-notifications-notice .mw-echo-unseen-notifications::after {
                        background-color: @blue !important;
                    }

                    a,
                    .mw-parser-output a.external:visited {
                        color: @accent;
                        &:visited {
                            color: @mauve;
                        }
                    }

                    a.new,
                    .mw-parser-output .cs1-visible-error,
                    .vector-menu-tabs .mw-list-item.new a,
                    .mw-plusminus-neg {
                        color: @red;
                    }

                    a.mw-selflink {
                        color: @text;
                    }

                    #searchInput {
                        color: @text;
                        &:hover {
                            border-color: @surface2;
                        }
                        &:focus {
                            border-color: @accent;
                        }
                    }

                    .pure-form input[type="search"] {
                        border-color: @surface2;
                        box-shadow: inset 0 0 0 1px @surface2;
                    }

                    #pt-notifications-alert .mw-echo-notifications-badge::after,
                    #pt-notifications-notice .mw-echo-notifications-badge::after,
                    .mw-echo-notification-badge-nojs::after {
                        border-color: @crust;
                        background-color: @accent;
                        color: @base;
                    }

                    h2 {
                        border-bottom-color: @surface2;
                    }

                    .mw-footer {
                        border-top-color: @surface2;
                    }

                    .bookshelf {
                        border-top-color: @surface0;
                        box-shadow: 0 -1px 0 @surface0;
                    }

                    body.ns-talk .mw-parser-output .mp-toolbox,
                    .mw-parser-output .tmbox,
                    #talkheader {
                        border-color: fade(@yellow, 20%) !important;
                        background-color: fade(@yellow, 10%) !important;
                    }

                    body.ns-talk .mw-parser-output .mp-toolbox-daily th {
                        border-color: fade(@yellow, 80%) !important;
                        background-color: fade(@yellow, 20%) !important;
                    }

                    .fn.org {
                        color: @accent;
                    }

                    .mw-parser-output .mp-toolbox-daily th,
                    .mw-parser-output td.mp-toolbox-tfl-not {
                        background: fade(@yellow, 20%) !important;
                        border-color: fade(@yellow, 20%) !important;
                    }

                    body.ns-talk .mw-parser-output .mp-toolbox-daily {
                        border-color: fade(@yellow, 20%) !important;
                        background: none !important;
                    }

                    .mw-parser-output tr + tr > .navbox-list,
                    .mw-parser-output tr + tr > .navbox-group {
                        border-top-color: @surface0;
                    }

                    .ext-phonos-PhonosButton.oo-ui-buttonElement-frameless.oo-ui-buttonWidget
                        > .oo-ui-buttonElement-button:hover {
                        background-color: fade(@accent, 20%);
                    }

                    .styled-select:hover {
                        background-color: @surface0;
                    }

                    .lang-list-button,
                    .lang-list-button:hover {
                        background-color: @base;
                        border-color: @surface1;
                        outline-color: @base;
                    }

                    .cdx-typeahead-search__search-footer__icon.cdx-icon {
                        color: @subtext0;
                    }

                    .vector-toc
                        .vector-toc-level-1-active:not(.vector-toc-list-item-active)
                        > .vector-toc-link {
                        color: @text !important;
                    }

                    .lang-list-active .lang-list-button {
                        background-color: @base;
                        border-color: @surface1;
                        outline-color: @base;
                    }

                    .lang-list-button:focus {
                        box-shadow: inset 0 0 0 1px @accent;
                    }

                    .lang-list-border {
                        background-color: @surface1;
                    }

                    .infobox-header {
                        background-color: @surface1 !important;
                        color: @text !important;
                    }

                    td[style*="background-color"],
                    td[style*="background-color"] * {
                        color: @crust !important;
                    }

                    #toc-Services > a:nth-child(1) > div:nth-child(1) {
                        color: @text !important;
                    }

                    .cdx-button.cdx-button--fake-button--enabled.cdx-button--weight-quiet.cdx-button--action-progressive,
                    .vector-menu-tabs .mw-list-item a,
                    .vector-feature-zebra-design-enabled .vector-toc .vector-toc-link,
                    .mw-parser-output a.extiw,
                    .mw-parser-output a.external,
                    .mw-collapsible-toggle-default .mw-collapsible-text,
                    .vector-feature-zebra-design-enabled
                        .vector-pinnable-element
                        .mw-list-item
                        a,
                    .vector-feature-zebra-design-enabled
                        .vector-dropdown-content
                        .mw-list-item
                        a,
                    .vector-feature-zebra-design-enabled
                        .vector-pinnable-element
                        .mw-list-item
                        a:not(.mw-selflink):visited,
                    .vector-feature-zebra-design-enabled
                        .vector-dropdown-content
                        .mw-list-item
                        a:not(.mw-selflink):visited,
                    .uls-language-block a,
                    .lang-list-button,
                    .fancycaptcha-reload,
                    #pt-userpage-2 a:not(.mw-selflink),
                    .vector-pinnable-element .mw-list-item a,
                    .vector-pinnable-element .mw-list-item a:not(.mw-selflink):visited,
                    .vector-toc .vector-toc-link,
                    .oo-ui-buttonElement-frameless.oo-ui-widget-enabled.oo-ui-flaggedElement-progressive
                        > .oo-ui-buttonElement-button,
                    .oo-ui-buttonElement-frameless.oo-ui-widget-enabled.oo-ui-flaggedElement-progressive
                        > .oo-ui-buttonElement-button:hover,
                    .vector-dropdown-content .mw-list-item a,
                    .vector-dropdown-content .mw-list-item a:not(.mw-selflink):visited {
                        color: @accent;
                    }

                    .cdx-button:enabled.cdx-button--weight-primary.cdx-button--action-progressive,
                    .cdx-button.cdx-button--fake-button--enabled.cdx-button--weight-primary.cdx-button--action-progressive,
                    .mw-ui-button.mw-ui-progressive:not(:disabled),
                    .mw-ui-button.mw-ui-progressive:not(:disabled):hover {
                        background-color: @accent;
                        border-color: @accent;
                        color: @base;
                    }

                    .mw-message-box-warning,
                    .boilerplate {
                        border-color: @accent !important;
                        background-color: fade(@accent, 25%) !important;
                        color: @text;
                    }

                    .vector-feature-zebra-design-enabled .vector-sticky-pinned-container::after,
                    .vector-sticky-pinned-container::after {
                        background: none;
                    }

                    .vector-feature-zebra-design-enabled .vector-pinnable-header-toggle-button {
                        background-color: @surface0;
                        color: @text;
                        &:hover {
                            background-color: @base;
                        }
                    }

                    .vector-feature-zebra-design-enabled .vector-pinnable-header,
                    .vector-pinnable-header,
                    .vector-pinnable-element .vector-menu-heading {
                        border-bottom-color: @surface0;
                    }

                    hr {
                        border-bottom-color: @base;
                    }

                    .central-featured-lang strong:hover,
                    .link-box:hover,
                    .central-featured-lang :hover,
                    .other-project-link:hover,
                    .lang-list-container {
                        background-color: @surface0;
                    }

                    .vector-page-toolbar-container {
                        box-shadow: 0 1px @surface1;
                    }

                    .mw-parser-output .navbox-even {
                        background-color: @surface1;
                    }

                    .vector-feature-zebra-design-enabled .vector-page-titlebar::after,
                    .mw-parser-output .wikipedia-languages-prettybars,
                    .vector-page-titlebar::after {
                        background-color: @surface2 !important;
                    }

                    table.expanded:nth-child(2) > tbody:nth-child(1) > tr:nth-child(2) {
                        background-color: fade(@accent, 20%) !important;
                    }

                    .client-js .mw-content-ltr .mw-editsection-bracket:first-of-type,
                    .client-js .mw-content-ltr .mw-editsection-bracket:not(:first-of-type),
                    .mw-collapsible-toggle-default::before,
                    .mw-collapsible-toggle-default::after {
                        color: @subtext1;
                    }

                    .infobox,
                    .mw-parser-output .navbox,
                    .catlinks,
                    .mw-parser-output #mp-topbanner,
                    .mw-parser-output .sidebar,
                    .fancycaptcha-captcha-container,
                    .fancycaptcha-captcha-and-reload,
                    .cdx-checkbox__icon,
                    .mw-message-box,
                    .uls-menu .uls-no-results-view .uls-no-found-more,
                    .client-js
                        .vector-below-page-title
                        .vector-page-titlebar-toc
                        > label:nth-child(2),
                    .mw-parser-output .ombox,
                    code,
                    .oo-ui-buttonElement-framed.oo-ui-widget-enabled
                        > .oo-ui-buttonElement-button,
                    .mw-mmv-label,
                    #page-secondary-actions > a,
                    .mw-parser-output .ambox,
                    td[class="sidebar-navbar"],
                    textarea,
                    .mw-parser-output .side-box {
                        background-color: @surface0 !important;
                        color: @text !important;
                        border-color: @surface2 !important;
                    }

                    #pagehistory li.selected {
                        background-color: @surface0 !important;
                        color: @text !important;
                        border-color: @surface2 !important;
                        outline-color: @surface2 !important;
                    }

                    .cdx-checkbox__icon {
                        border-color: @accent !important;
                    }

                    .fancycaptcha-captcha-container .mw-ui-inputو .mw-ui-input:not(:disabled) {
                        background-color: @base !important;
                        color: @text !important;
                        border-color: @surface1;
                    }

                    .mw-ui-input:not(:disabled),
                    .mw-ui-button:not(:disabled) {
                        background-color: @base !important;
                        color: @text !important;
                        border-color: @surface1 !important;
                    }

                    .mw-parser-output .module-shortcutboxplain {
                        background-color: @base !important;
                        color: @text !important;
                        border-color: @surface2;
                    }

                    .sidebar-pretitle,
                    .sidebar-title-with-pretitle,
                    .sidebar-list-title {
                        background-color: fade(@accent, 20%) !important;
                    }

                    .mw-parser-output #mp-bottom,
                    .mw-parser-output .sidebar-collapse .sidebar-below {
                        border-color: @surface2;
                    }

                    .lang-list-content,
                    .bookshelf .text {
                        background-color: @surface0;
                    }

                    .mw-parser-output #mp-bottom .mp-h2,
                    .uls-language-block > ul > li:hover {
                        background: @surface0;
                        border-color: @surface2;
                    }

                    figure[typeof~="mw:File/Thumb"] {
                        background-color: @mantle !important;
                        color: @text !important;
                        border-top-color: @surface2;
                        border-left-color: @surface2;
                        border-right-color: @surface2;
                        > figcaption {
                            background-color: @mantle !important;
                            color: @text !important;
                            border-bottom-color: @surface2;
                            border-left-color: @surface2;
                            border-right-color: @surface2;
                        }
                        > :not(figcaption) .mw-file-element {
                            color: @surface2 !important;
                            border-color: @surface2;
                        }
                    }

                    .mw-parser-output #mp-left,
                    .mw-parser-output #mp-left .mp-h2,
                    th[class="sidebar-title"] {
                        background-color: fade(@green, 10%) !important;
                        border-color: fade(@green, 20%) !important;
                    }

                    .mw-plusminus-pos {
                        color: @green !important;
                    }

                    .mw-parser-output #mp-right,
                    .mw-parser-output #mp-right .mp-h2 {
                        background-color: fade(@blue, 10%) !important;
                        border-color: fade(@blue, 20%) !important;
                    }

                    .mw-parser-output #mp-lower,
                    .mw-parser-output #mp-lower .mp-h2 {
                        background-color: fade(@mauve, 10%) !important;
                        border-color: fade(@mauve, 20%) !important;
                    }

                    .mw-collapsible-toggle-default:active .mw-collapsible-text {
                        color: @peach;
                    }

                    .mw-parser-output #mp-middle,
                    .mw-parser-output #mp-middle .mp-h2 {
                        background-color: fade(@pink, 10%) !important;
                        border-color: fade(@pink, 20%) !important;
                    }

                    .mw-parser-output .navbox-title,
                    .summary,
                    .infobox > tbody:nth-child(1) > tr:nth-child(4) > th:nth-child(1),
                    .infobox > tbody:nth-child(1) > tr:nth-child(6) > th:nth-child(1) {
                        background-color: fade(@accent, 20%) !important;
                    }

                    .infobox > tbody:nth-child(1) > tr:nth-child(2) > td:nth-child(1) {
                        background-color: @surface1 !important;
                    }

                    .mw-parser-output .navbox-group,
                    table.expanded:nth-child(2) > tbody:nth-child(1) > tr:nth-child(3),
                    table.expanded:nth-child(2)
                        > tbody:nth-child(1)
                        > tr:nth-child(4)
                        > td:nth-child(2)
                        > table:nth-child(2)
                        > tbody:nth-child(1)
                        > tr:nth-child(1),
                    table.expanded:nth-child(2) > tbody:nth-child(1) > tr:nth-child(1),
                    table.nowraplinks:nth-child(1)
                        > tbody:nth-child(1)
                        > tr:nth-child(3)
                        > td:nth-child(1)
                        > table:nth-child(2)
                        > tbody:nth-child(1)
                        > tr:nth-child(1),
                    table.nowraplinks:nth-child(1)
                        > tbody:nth-child(1)
                        > tr:nth-child(4)
                        > td:nth-child(1)
                        > table:nth-child(2)
                        > tbody:nth-child(1)
                        > tr:nth-child(1),
                    table.nowraplinks:nth-child(1)
                        > tbody:nth-child(1)
                        > tr:nth-child(5)
                        > td:nth-child(1)
                        > table:nth-child(2)
                        > tbody:nth-child(1)
                        > tr:nth-child(1),
                    .navbox-abovebelow {
                        background-color: @surface1 !important;
                    }

                    .mw-parser-output .tracklist > tbody {
                        color: inherit;

                        > .tracklist-total-length * {
                            background-color: @overlay1;
                            color: @base;
                        }
                    }

                    .mw-content-ltr
                        > table:nth-child(20)
                        > tbody:nth-child(1)
                        > tr:nth-child(2)
                        > td:nth-child(2) {
                        border-color: @surface2 !important;
                        background-color: @surface0 !important;
                    }

                    .noarticletext,
                    #noarticletext {
                        background-color: @base !important;
                    }

                    #sisterproject {
                        background-color: @mantle !important;
                    }

                    [style="color:#02a64f;line-height:initial"] {
                        color: @green !important;
                    }

                    [style="color:#f78e1e;line-height:initial"] {
                        color: @peach !important;
                    }

                    [style="color:#77278b;line-height:initial"] {
                        color: @mauve !important;
                    }

                    [style="color:#87746a;line-height:initial"] {
                        color: @maroon !important;
                    }

                    [style="color:#009aC8;line-height:initial"] {
                        color: @sky !important;
                    }

                    [style="color:#ffd520;line-height:initial"] {
                        color: @yellow !important;
                    }

                    [style="color:#0060a9;line-height:initial"] {
                        color: @blue !important;
                    }

                    table.nowraplinks:nth-child(4) > tbody:nth-child(1) > tr:nth-child(1),
                    .navbox-list-with-group.navbox-list.navbox-odd {
                        background-color: @surface0 !important;
                    }

                    .mw-parser-output tr + tr > .navbox-abovebelow {
                        border-color: @base;
                    }

                    .catlinks li {
                        border-left-color: @surface2;
                    }

                    .plainlinks a.external {
                        background: none !important;
                    }

                    .panel-heading,
                    .mw-pt-languages-list,
                    .mw-pt-languages-label {
                        color: @text;
                        background-color: @base;
                    }
                    .oo-ui-dropdownWidget.oo-ui-widget-enabled .oo-ui-dropdownWidget-handle,
                    .oo-ui-inputWidget-input,
                    .mw-widget-dateInputWidget-handle,
                    .oo-ui-menuSelectWidget {
                        background-color: @mantle !important;
                        color: @text !important;
                    }
                    .oo-ui-menuOptionWidget:hover {
                        background-color: @surface1;
                        color: @text;
                    }
                    .cdx-search-input__end-button {
                        background-color: @crust !important;
                    }
                    .mw-pt-languages {
                        border-bottom-color: @surface0;
                    }
                    .mw-pt-progress--complete::after,
                    .mw-pt-progress--high::after {
                        border-color: @accent;
                        background: conic-gradient(@text 0, @accent 0);
                    }
                    pre,
                    .oo-ui-panelLayout-framed {
                        border-color: @surface0;
                    }
                    #vector-page-titlebar-toc-label {
                        background-color: @mantle;
                        color: @subtext0 !important;
                        border-color: @subtext0 !important;
                    }
                    tbody * {
                        background-color: @surface0 !important;
                        border-color: @surface2 !important;
                    }

                    [style*="padding: 0.5em; margin: 0.50em 0; background-color: #C1E5FF; border: thin solid #1D99F3; overflow: hidden;"] {
                        background-color: @sapphire !important;
                        color: @mantle !important;
                    }
                    [style*="padding: 0.5em; margin: 0.50em 0; background-color: #F6F6F6; border: thin solid #31363B; overflow: hidden;"] {
                        background-color: @rosewater !important;
                        color: @mantle !important;
                    }
                }
            }
        '';
    in lib.aeon.generators.stylesheets.fromCatppuccin.intoDynamicStylesheet {
        name = "wiki.nixos.org";
        inherit metadata stylesheet theme;
    };
}
