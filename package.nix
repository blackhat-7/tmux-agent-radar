{
  lib,
  stdenv,
  makeWrapper,
  bash,
  coreutils,
  fzf,
  gawk,
  gnugrep,
  gnused,
  tmux,
  procps,
  tmuxPlugins,
}:

let
  pluginName = "tmux-agent-radar";
  runtimePath = lib.makeBinPath (
    [
      bash
      coreutils
      fzf
      gawk
      gnugrep
      gnused
      tmux
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [ procps ]
  );
in
tmuxPlugins.mkTmuxPlugin {
  inherit pluginName;
  version = "0.1.0";
  rtpFilePath = "radar.tmux";

  src = lib.cleanSource ./.;

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    chmod +x "$target/radar.tmux" "$target/bin/tmux-agent-radar"

    wrapProgram "$target/bin/tmux-agent-radar" \
      --prefix PATH : "${runtimePath}"

    mkdir -p "$out/bin" "$out/share/doc/${pluginName}"
    ln -s "$target/bin/tmux-agent-radar" "$out/bin/tmux-agent-radar"
    ln -s "$target/README.md" "$out/share/doc/${pluginName}/README.md"
  '';

  meta = {
    description = "tmux/fzf popup for finding CLI coding-agent panes";
    homepage = "https://github.com/blackhat-7/tmux-agent-radar";
    license = lib.licenses.mit;
    mainProgram = "tmux-agent-radar";
    platforms = lib.platforms.unix;
  };
}
