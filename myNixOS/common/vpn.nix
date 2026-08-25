{ config, pkgs, ... }: {
  environment.systemPackages = [ pkgs.openvpn];

  services.openvpn.servers = {
    htb = {
        config  = "config /home/aswdxtbyyn/.openvpn/htb/starting_points_eu-starting-point-2-dhcp.ovpn";
        autoStart = false;
      };
  };
}
#to start use sudo systemctl start openvpn-htb
#to stop use sudo systemctl stop openvpn-htb
#and to check status systemctl status openvpn-htb
