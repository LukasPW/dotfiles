environment.systemPackages  =[ pkgs.openvpn];

services.openvpn.servers = {
    htb = {
        config  = "config /home/aswdxtbyyn/.openvpn/htb/";
        autoStart = false;
      };
  };
