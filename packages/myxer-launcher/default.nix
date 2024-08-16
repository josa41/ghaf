# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  myxer,
  writeShellApplication,
  lib,
  ...
}:
writeShellApplication {
  name = "myxer-launcher";

  text = ''
    export PULSE_SERVER="tcp:audio-vm:4713"
    ${myxer}/bin/myxer
  '';

  meta = {
    description = "Script to launch myxer to configure pulseaudio of audiovm over TCP.";
    platforms = lib.platforms.linux;
  };
}
