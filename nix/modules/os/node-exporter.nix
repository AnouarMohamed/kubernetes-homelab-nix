_: {
  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [
      "systemd"
      "processes"
    ];
    port = 9100;
    openFirewall = false;
  };
}
