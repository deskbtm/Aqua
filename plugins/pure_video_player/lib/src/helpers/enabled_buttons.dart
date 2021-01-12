/// this class helps you to hide some player buttons
class EnabledButtons {
  final bool playPauseAndRepeat, rewindAndfastForward, muteAndSound, pip, fullscreen;

  const EnabledButtons({
    this.playPauseAndRepeat = true,
    this.rewindAndfastForward = true,
    this.muteAndSound = true,
    this.pip = true,
    this.fullscreen = true,
  });
}
