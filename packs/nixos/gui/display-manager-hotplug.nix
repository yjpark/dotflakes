{ pkgs, ... }:
# Bring the login screen up when a monitor is plugged in.
#
# On a headless boot the greeter has no output to draw on and exits at once,
# so the display manager burns through its restart limit and stays failed
# (seen on edger with cosmic-greeter). Nothing retries it later, so plugging in
# a monitor showed nothing. A DRM hotplug event now (re)starts it, but only
# when it is not already active, so a running greeter or session is untouched.
let
  systemctl = "${pkgs.systemd}/bin/systemctl";
in
{
  systemd.services.display-manager-hotplug = {
    description = "Start the display manager after a display hotplug";
    serviceConfig.Type = "oneshot";
    script = ''
      if ! ${systemctl} is-active --quiet display-manager.service; then
        # Give the connector a moment to settle before the greeter probes it.
        sleep 2
        ${systemctl} reset-failed display-manager.service
        ${systemctl} start --no-block display-manager.service
      fi
    '';
  };

  # The kernel sets HOTPLUG=1 on the card's change event when a connector is
  # plugged or unplugged. Synthetic events carry their arguments as SYNTH_ARG_*,
  # so the second rule lets the path be exercised by hand (`udevadm trigger -p`
  # is rejected by the kernel here as "incorrect uevent action arguments"):
  #   echo "change $(cat /proc/sys/kernel/random/uuid) HOTPLUG=1" \
  #     | sudo tee /sys/class/drm/card1/uevent
  services.udev.extraRules = ''
    ACTION=="change", SUBSYSTEM=="drm", ENV{HOTPLUG}=="1", RUN+="${systemctl} --no-block start display-manager-hotplug.service"
    ACTION=="change", SUBSYSTEM=="drm", ENV{SYNTH_ARG_HOTPLUG}=="1", RUN+="${systemctl} --no-block start display-manager-hotplug.service"
  '';
}
