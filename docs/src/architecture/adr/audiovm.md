<!--
    Copyright 2023 TII (SSRC) and the Ghaf contributors
    SPDX-License-Identifier: CC-BY-SA-4.0
-->

# audiovm-Audio support Virtual Machine

## Status

Proposed, partially implemented for development and testing.

*audiovm* reference declaration will be available at [audiovm/default.nix](TODO)

## Context

Ghaf high-level design target is to secure a monolithic OS by modularizing
the OS. The key security target is to limit user data leakage between OS,
applications and components. This isolates audio data between virtual
machines and allows better control over which virtual machine gets access
to audio peripherals.

## Decision

The two main goals are to isolate the virtual machine audio streams to prevent
audio data leakage between virtual machines and allow separate control over
which virtual machine is allowed to use audio peripherals at given time. The
other goal is to isolate the audio stream processing to a separate virtual
machine from the host to reduce size of trusted computing base in the host.

Separating the audio processing away from the host is needed because some
guest virtual machines need direct access to the main audio stream controls
and allowing a direct connection from guests to host services would not be
ideal for security perspective.

On the host, the audio device is passed through to a dedicated Audio virtual
machine. Audio virtual machine provides a service to let virtual machines
to use the audio peripherals. Letting the application virtual machines to
connect to the audioVM backend directly might allow the application virtual
machies to have full controll of all audio data including audio of other
virtual machines. For this reason the application virtual machine audio is
routed through the virtual machine manager. Each application virtual machine
gets its own virtualized sound card device from the virtual machine manager.
The virtual machine manager routes the Application virtual machines virtual
sound card data to actual sound service on audio virtual machine.

                      ┌─────────────────┐                 ┌──────────────────┐
                      │                 │                 │                  │
                      │                 │                 │                  │
        Direct Audio  │     GuiVM       │                 │      AppVM2      │
           ┌──────────┤                 │                 │                  │
           │          │                 │         ┌──────►│                  │
           │          └─────────────────┘         │       └──────────────────┘
           │                                      │     Virtual Audio Device
           │                                      │
           │                                      │
    ┌──────▼──────────┐                           │       ┌──────────────────┐
    │                 │                           │       │                  │
    │                 │    VM Audio               │       │                  │
    │     AudioVM     ◄─────────────┐             │       │      AppVM1      │
    │                 │             │             │       │                  │
    │                 │             │             │       │                  │
    └──────────────▲──┘             │             │       └─────────▲────────┘
                   │            ┌───┴─────────────┴─┐               │
                   │            │                   │               │
      Audio device │            │    VM Manager     ├───────────────┘
       passthrough │            │                   │   Virtual Audio Device
                  ┌┴────────────┼───────────────────┤
                  │             └───────────────────┤
                  │                                 │
                  │               Host              │
                  │                                 │
                  │                                 │
                  └─────────────────────────────────┘


## Consequences

As with most passthroughs there may be some hardware dependencies which need
to be handeled case by case. As with our reference device Lenovo X1 laptop the
integrated sound card is set in the same VFIO group with the USB controller.
This practically forces the sound card to be passed through together with the
USB controller to the same virtual machine. Having multiple services (audio
and USB in this case) in the same virtual machine makes the system components
as a whole less isolated and allows one incident to spread to other components
more easily. However, this is the reference hardware design related consequence.
Hardware designs with device and device group connections that support device
isolation - either pass through or paravirtualized - do not require sharing
in the same virtual machine.

The GUI virtual machine practically has a lot of control over all the separate
virtual machine sound channels and possibly also over the sound data. The
level of control over the sound data should be reviewed as that depends on
which sound subsystem is being used on Audio virtual machine.
