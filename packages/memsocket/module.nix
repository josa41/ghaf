# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  stdenv,
  lib,
  kernel,
  fetchFromGitHub,
  shmSlots,
  ...
}:
stdenv.mkDerivation {
  inherit shmSlots;
  name = "ivshmem-driver-${kernel.version}";

  src = fetchFromGitHub {
    owner = "tiiuae";
    repo = "shmsockproxy";
    rev = "79a119205a427b5eac0c4e1ae4275763601016c5";
    sha256 = "sha256-GXdgYEVr4fDEDUZRrjfiihRTl+BZEC+hUj8jPkp77xs=";
  };

  sourceRoot = "source/module";
  hardeningDisable = [
    "pic"
    "format"
  ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "MODULEDIR=$(out)/lib/modules/${kernel.modDirVersion}/kernel/drivers/char"
    "CFLAGS_kvm_ivshmem.o=\"-DCONFIG_KVM_IVSHMEM_SHM_SLOTS=${builtins.toString shmSlots}\""
  ];

  meta = with lib; {
    description = "Shared memory Linux kernel module";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
