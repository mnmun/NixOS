{
  programs.kitty = {
    enable = true;
    themeFile = "gruvbox-dark";
    font = {
      name = "JetBrainsMono Nerd Font Mono";
      size = 12;
    };
    settings = {
      confirm_os_window_close = 0;
      active_border_color = "none";
    };
    keybindings = {
      "ctrl+shift+right" = "no_op";
      "ctrl+shift+left" = "no_op";
    };
  };
}
