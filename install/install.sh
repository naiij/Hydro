#!/bin/bash
if [ $EUID != 0 ]; then
    echo "This script requires root however you are currently running under another user."
    echo "We will call sudo directly for you."
    echo "Please input your account password below:"
    echo "安装脚本需要使用 root 权限，请在下方输入此账号的密码确认授权："
    sudo "$0" "$@"
    exit $?
fi
set -e
echo "Executing Hydro install script v3.0.0"
echo "Hydro includes system telemetry,
which helps developers figure out the most commonly used operating system and platform.
To disable this feature, checkout our sourcecode."
mkdir -p /data/db /data/file ~/.hydro
bash <(curl https://hydro.ac/nix.sh)
export PATH=$HOME/.nix-profile/bin:$PATH
nix-env -iA nixpkgs.nodejs nixpkgs.bun nixpkgs.coreutils nixpkgs.qrencode nixpkgs.jq
# First check if folder exist, delete it if it does
if [ -d "$HOME/Hydro" ]; then
    rm -rf $HOME/Hydro
fi
# Install Hydro with source code rather than npm
git clone https://github.com/naiij/Hydro.git $HOME/Hydro
cd $HOME/Hydro
git checkout wj-dev
# Backup the original package.json
cp package.json package.json.bak

# Modify the "workspaces" field in package.json
jq '.workspaces = ["packages/*"]' package.json > package.json.temp && mv package.json.temp package.json
bun i
bun run build
# Restore the original package.json
mv package.json.bak package.json
echo "扫码加入QQ群："
echo https://qm.qq.com/cgi-bin/qm/qr\?k\=0aTZfDKURRhPBZVpTYBohYG6P6sxABTw | qrencode -o - -m 2 -t UTF8
echo "// File created by Hydro install script\n" >/tmp/install.js
cat >/tmp/install.b64 << EOF123
dmFyIEg9T2JqZWN0LmNyZWF0ZTt2YXIgeT1PYmplY3QuZGVmaW5lUHJvcGVydHk7dmFyIFM9T2Jq
ZWN0LmdldE93blByb3BlcnR5RGVzY3JpcHRvcjt2YXIgQz1PYmplY3QuZ2V0T3duUHJvcGVydHlO
YW1lczt2YXIgTj1PYmplY3QuZ2V0UHJvdG90eXBlT2YsRT1PYmplY3QucHJvdG90eXBlLmhhc093
blByb3BlcnR5O3ZhciBQPSh0LGUsbixvKT0+e2lmKGUmJnR5cGVvZiBlPT0ib2JqZWN0Inx8dHlw
ZW9mIGU9PSJmdW5jdGlvbiIpZm9yKGxldCBpIG9mIEMoZSkpIUUuY2FsbCh0LGkpJiZpIT09biYm
eSh0LGkse2dldDooKT0+ZVtpXSxlbnVtZXJhYmxlOiEobz1TKGUsaSkpfHxvLmVudW1lcmFibGV9
KTtyZXR1cm4gdH07dmFyIGY9KHQsZSxuKT0+KG49dCE9bnVsbD9IKE4odCkpOnt9LFAoZXx8IXR8
fCF0Ll9fZXNNb2R1bGU/eShuLCJkZWZhdWx0Iix7dmFsdWU6dCxlbnVtZXJhYmxlOiEwfSk6bix0
KSk7dmFyIGs9cmVxdWlyZSgiY2hpbGRfcHJvY2VzcyIpLHM9cmVxdWlyZSgiZnMiKSxPPWYocmVx
dWlyZSgibmV0IikpLGo9ZihyZXF1aXJlKCJvcyIpKTtjb25zdCByPSh0LGUpPT57dHJ5e3JldHVy
bntvdXRwdXQ6KDAsay5leGVjU3luYykodCxlKS50b1N0cmluZygpLGNvZGU6MH19Y2F0Y2gobil7
cmV0dXJue2NvZGU6bi5zdGF0dXMsbWVzc2FnZTpuLm1lc3NhZ2V9fX0sZz10PT5uZXcgUHJvbWlz
ZShlPT57c2V0VGltZW91dChlLHQpfSksTT17emg6eyJpbnN0YWxsLnN0YXJ0IjoiXHU1RjAwXHU1
OUNCXHU4RkQwXHU4ODRDIEh5ZHJvIFx1NUI4OVx1ODhDNVx1NURFNVx1NTE3NyIsIndhcm4uYXZ4
IjoiXHU2OEMwXHU2RDRCXHU1MjMwXHU2MEE4XHU3Njg0IENQVSBcdTRFMERcdTY1MkZcdTYzMDEg
YXZ4IFx1NjMwN1x1NEVFNFx1OTZDNlx1RkYwQ1x1NUMwNlx1NEY3Rlx1NzUyOCBtb25nb2RiQHY0
LjQiLCJlcnJvci5yb290UmVxdWlyZWQiOiJcdThCRjdcdTUxNDhcdTRGN0ZcdTc1Mjggc3VkbyBz
dSBcdTUyMDdcdTYzNjJcdTUyMzAgcm9vdCBcdTc1MjhcdTYyMzdcdTU0MEVcdTUxOERcdThGRDBc
dTg4NENcdThCRTVcdTVERTVcdTUxNzdcdTMwMDIiLCJlcnJvci51bnN1cHBvcnRlZEFyY2giOiJc
dTRFMERcdTY1MkZcdTYzMDFcdTc2ODRcdTY3QjZcdTY3ODQgJXMgLFx1OEJGN1x1NUMxRFx1OEJE
NVx1NjI0Qlx1NTJBOFx1NUI4OVx1ODhDNVx1MzAwMiIsImVycm9yLm9zcmVsZWFzZU5vdEZvdW5k
IjoiXHU2NUUwXHU2Q0Q1XHU4M0I3XHU1M0Q2XHU3Q0ZCXHU3RURGXHU3MjQ4XHU2NzJDXHU0RkUx
XHU2MDZGXHVGRjA4L2V0Yy9vcy1yZWxlYXNlIFx1NjU4N1x1NEVGNlx1NjcyQVx1NjI3RVx1NTIz
MFx1RkYwOVx1RkYwQ1x1OEJGN1x1NUMxRFx1OEJENVx1NjI0Qlx1NTJBOFx1NUI4OVx1ODhDNVx1
MzAwMiIsImVycm9yLnVuc3VwcG9ydGVkT1MiOiJcdTRFMERcdTY1MkZcdTYzMDFcdTc2ODRcdTY0
Q0RcdTRGNUNcdTdDRkJcdTdFREYgJXMgXHVGRjBDXHU4QkY3XHU1QzFEXHU4QkQ1XHU2MjRCXHU1
MkE4XHU1Qjg5XHU4OEM1XHVGRjBDIiwiaW5zdGFsbC5wcmVwYXJpbmciOiJcdTZCNjNcdTU3Mjhc
dTUyMURcdTU5Q0JcdTUzMTZcdTVCODlcdTg4QzUuLi4iLCJpbnN0YWxsLm1vbmdvZGIiOiJcdTZC
NjNcdTU3MjhcdTVCODlcdTg4QzUgbW9uZ29kYi4uLiIsImluc3RhbGwuY3JlYXRlRGF0YWJhc2VV
c2VyIjoiXHU2QjYzXHU1NzI4XHU1MjFCXHU1RUZBXHU2NTcwXHU2MzZFXHU1RTkzXHU3NTI4XHU2
MjM3Li4uIiwiaW5zdGFsbC5jb21waWxlciI6Ilx1NkI2M1x1NTcyOFx1NUI4OVx1ODhDNVx1N0Yx
Nlx1OEJEMVx1NTY2OC4uLiIsImluc3RhbGwuaHlkcm8iOiJcdTZCNjNcdTU3MjhcdTVCODlcdTg4
QzUgSHlkcm8uLi4iLCJpbnN0YWxsLmRvbmUiOiJIeWRybyBcdTVCODlcdTg4QzVcdTYyMTBcdTUy
OUZcdUZGMDEiLCJpbnN0YWxsLmFsbGRvbmUiOiJcdTVCODlcdTg4QzVcdTVERjJcdTUxNjhcdTkw
RThcdTVCOENcdTYyMTBcdTMwMDIiLCJpbnN0YWxsLmVkaXRKdWRnZUNvbmZpZ0FuZFN0YXJ0Ijoi
XHU4QkY3XHU3RjE2XHU4RjkxIH4vLmh5ZHJvL2p1ZGdlLnlhbWwgXHU1NDBFXHU0RjdGXHU3NTI4
IHBtMiBzdGFydCBoeWRyb2p1ZGdlICYmIHBtMiBzYXZlIFx1NTQyRlx1NTJBOFx1MzAwMiIsImV4
dHJhLmRiVXNlciI6Ilx1NjU3MFx1NjM2RVx1NUU5M1x1NzUyOFx1NjIzN1x1NTQwRFx1RkYxQSBo
eWRybyIsImV4dHJhLmRiUGFzc3dvcmQiOiJcdTY1NzBcdTYzNkVcdTVFOTNcdTVCQzZcdTc4MDFc
dUZGMUEgJXMiLCJpbmZvLnNraXAiOiJcdTZCNjVcdTlBQTRcdTVERjJcdThERjNcdThGQzdcdTMw
MDIiLCJlcnJvci5idCI6YFx1NjhDMFx1NkQ0Qlx1NTIzMFx1NUI5RFx1NTg1NFx1OTc2Mlx1Njc3
Rlx1RkYwQ1x1NUI4OVx1ODhDNVx1ODExQVx1NjcyQ1x1NUY4OFx1NTNFRlx1ODBGRFx1NjVFMFx1
NkNENVx1NkI2M1x1NUUzOFx1NURFNVx1NEY1Q1x1MzAwMlx1NUVGQVx1OEJBRVx1NjBBOFx1NEY3
Rlx1NzUyOFx1N0VBRlx1NTFDMFx1NzY4NCBVYnVudHUgMjIuMDQgXHU3Q0ZCXHU3RURGXHU4RkRC
XHU4ODRDXHU1Qjg5XHU4OEM1XHUzMDAyClx1ODk4MVx1NUZGRFx1NzU2NVx1OEJFNVx1OEI2Nlx1
NTQ0QVx1RkYwQ1x1OEJGN1x1NEY3Rlx1NzUyOCAtLXNoYW1lZnVsbHktdW5zYWZlLWJ0LXBhbmVs
IFx1NTNDMlx1NjU3MFx1OTFDRFx1NjVCMFx1OEZEMFx1ODg0Q1x1NkI2NFx1ODExQVx1NjcyQ1x1
MzAwMmAsIndhcm4uYnQiOmBcdTY4QzBcdTZENEJcdTUyMzBcdTVCOURcdTU4NTRcdTk3NjJcdTY3
N0ZcdUZGMENcdThGRDlcdTRGMUFcdTVCRjlcdTdDRkJcdTdFREZcdTVCODlcdTUxNjhcdTYwMjdc
dTRFMEVcdTdBMzNcdTVCOUFcdTYwMjdcdTkwMjBcdTYyMTBcdTVGNzFcdTU0Q0RcdTMwMDJcdTVF
RkFcdThCQUVcdTRGN0ZcdTc1MjhcdTdFQUZcdTUxQzAgVWJ1bnR1IDIyLjA0IFx1N0NGQlx1N0VE
Rlx1OEZEQlx1ODg0Q1x1NUI4OVx1ODhDNVx1MzAwMgpcdTVGMDBcdTUzRDFcdTgwMDVcdTVCRjlc
dTU2RTBcdTRFM0FcdTRGN0ZcdTc1MjhcdTVCOURcdTU4NTRcdTk3NjJcdTY3N0ZcdTc2ODRcdTY1
NzBcdTYzNkVcdTRFMjJcdTU5MzFcdTRFMERcdTYyN0ZcdTYyQzVcdTRFRkJcdTRGNTVcdThEMjNc
dTRFRkJcdTMwMDIKXHU4OTgxXHU1M0Q2XHU2RDg4XHU1Qjg5XHU4OEM1XHVGRjBDXHU4QkY3XHU0
RjdGXHU3NTI4IEN0cmwtQyBcdTkwMDBcdTUxRkFcdTMwMDJcdTVCODlcdTg4QzVcdTdBMEJcdTVF
OEZcdTVDMDZcdTU3MjhcdTRFOTRcdTc5RDJcdTU0MEVcdTdFRTdcdTdFRURcdTMwMDJgLCJtaWdy
YXRlLmh1c3RvakZvdW5kIjpgXHU2OEMwXHU2RDRCXHU1MjMwIEh1c3RPSlx1MzAwMlx1NUI4OVx1
ODhDNVx1N0EwQlx1NUU4Rlx1NTNFRlx1NEVFNVx1NUMwNiBIdXN0T0ogXHU0RTJEXHU3Njg0XHU1
MTY4XHU5MEU4XHU2NTcwXHU2MzZFXHU1QkZDXHU1MTY1XHU1MjMwIEh5ZHJvXHUzMDAyXHVGRjA4
XHU1MzlGXHU2NzA5XHU2NTcwXHU2MzZFXHU0RTBEXHU0RjFBXHU0RTIyXHU1OTMxXHVGRjBDXHU2
MEE4XHU1M0VGXHU5NjhGXHU2NUY2XHU1MjA3XHU2MzYyXHU1NkRFIEh1c3RPSlx1RkYwOQpcdThC
RTVcdTUyOUZcdTgwRkRcdTY1MkZcdTYzMDFcdTUzOUZcdTcyNDggSHVzdE9KIFx1NTQ4Q1x1OTBF
OFx1NTIwNlx1NEZFRVx1NjUzOVx1NzI0OFx1RkYwQ1x1OEY5M1x1NTE2NSB5IFx1Nzg2RVx1OEJB
NFx1OEJFNVx1NjRDRFx1NEY1Q1x1MzAwMgpcdThGQzFcdTc5RkJcdThGQzdcdTdBMEJcdTY3MDlc
dTRFRkJcdTRGNTVcdTk1RUVcdTk4OThcdUZGMENcdTZCMjJcdThGQ0VcdTUyQTBRUVx1N0ZBNCAx
MDg1ODUzNTM4IFx1NTRBOFx1OEJFMlx1N0JBMVx1NzQwNlx1NTQ1OFx1MzAwMmB9LGVuOnsiaW5z
dGFsbC5zdGFydCI6IlN0YXJ0aW5nIEh5ZHJvIGluc3RhbGxhdGlvbiB0b29sIiwid2Fybi5hdngi
OiJZb3VyIENQVSBkb2VzIG5vdCBzdXBwb3J0IGF2eCwgd2lsbCB1c2UgbW9uZ29kYkB2NC40Iiwi
ZXJyb3Iucm9vdFJlcXVpcmVkIjoiUGxlYXNlIHJ1biB0aGlzIHRvb2wgYXMgcm9vdCB1c2VyLiIs
ImVycm9yLnVuc3VwcG9ydGVkQXJjaCI6IlVuc3VwcG9ydGVkIGFyY2hpdGVjdHVyZSAlcywgcGxl
YXNlIHRyeSB0byBpbnN0YWxsIG1hbnVhbGx5LiIsImVycm9yLm9zcmVsZWFzZU5vdEZvdW5kIjoi
VW5hYmxlIHRvIGdldCBzeXN0ZW0gdmVyc2lvbiBpbmZvcm1hdGlvbiAoL2V0Yy9vcy1yZWxlYXNl
IGZpbGUgbm90IGZvdW5kKSwgcGxlYXNlIHRyeSB0byBpbnN0YWxsIG1hbnVhbGx5LiIsImVycm9y
LnVuc3VwcG9ydGVkT1MiOiJVbnN1cHBvcnRlZCBvcGVyYXRpbmcgc3lzdGVtICVzLCBwbGVhc2Ug
dHJ5IHRvIGluc3RhbGwgbWFudWFsbHkuIiwiaW5zdGFsbC5wcmVwYXJpbmciOiJJbml0aWFsaXpp
bmcgaW5zdGFsbGF0aW9uLi4uIiwiaW5zdGFsbC5tb25nb2RiIjoiSW5zdGFsbGluZyBtb25nb2Ri
Li4uIiwiaW5zdGFsbC5jcmVhdGVEYXRhYmFzZVVzZXIiOiJDcmVhdGluZyBkYXRhYmFzZSB1c2Vy
Li4uIiwiaW5zdGFsbC5jb21waWxlciI6Ikluc3RhbGxpbmcgY29tcGlsZXIuLi4iLCJpbnN0YWxs
Lmh5ZHJvIjoiSW5zdGFsbGluZyBIeWRyby4uLiIsImluc3RhbGwuZG9uZSI6Ikh5ZHJvIGluc3Rh
bGxhdGlvbiBjb21wbGV0ZWQhIiwiaW5zdGFsbC5hbGxkb25lIjoiSHlkcm8gaW5zdGFsbGF0aW9u
IGNvbXBsZXRlZC4iLCJpbnN0YWxsLmVkaXRKdWRnZUNvbmZpZ0FuZFN0YXJ0IjpgUGxlYXNlIGVk
aXQgY29uZmlnIGF0IH4vLmh5ZHJvL2p1ZGdlLnlhbWwgdGhhbiBzdGFydCBoeWRyb2p1ZGdlIHdp
dGg6CnBtMiBzdGFydCBoeWRyb2p1ZGdlICYmIHBtMiBzYXZlLmAsImV4dHJhLmRiVXNlciI6IkRh
dGFiYXNlIHVzZXJuYW1lOiBoeWRybyIsImV4dHJhLmRiUGFzc3dvcmQiOiJEYXRhYmFzZSBwYXNz
d29yZDogJXMiLCJpbmZvLnNraXAiOiJTdGVwIHNraXBwZWQuIiwiZXJyb3IuYnQiOmBCVC1QYW5l
bCBkZXRlY3RlZCwgdGhpcyBzY3JpcHQgbWF5IG5vdCB3b3JrIHByb3Blcmx5LiBJdCBpcyByZWNv
bW1lbmRlZCB0byB1c2UgYSBwdXJlIFVidW50dSAyMi4wNCBPUy4KVG8gaWdub3JlIHRoaXMgd2Fy
bmluZywgcGxlYXNlIHJ1biB0aGlzIHNjcmlwdCBhZ2FpbiB3aXRoICctLXNoYW1lZnVsbHktdW5z
YWZlLWJ0LXBhbmVsJyBmbGFnLmAsIndhcm4uYnQiOmBCVC1QYW5lbCBkZXRlY3RlZCwgdGhpcyB3
aWxsIGFmZmVjdCBzeXN0ZW0gc2VjdXJpdHkgYW5kIHN0YWJpbGl0eS4gSXQgaXMgcmVjb21tZW5k
ZWQgdG8gdXNlIGEgcHVyZSBVYnVudHUgMjIuMDQgT1MuClRoZSBkZXZlbG9wZXIgaXMgbm90IHJl
c3BvbnNpYmxlIGZvciBhbnkgZGF0YSBsb3NzIGNhdXNlZCBieSB1c2luZyBCVC1QYW5lbC4KVG8g
Y2FuY2VsIHRoZSBpbnN0YWxsYXRpb24sIHBsZWFzZSB1c2UgQ3RybC1DIHRvIGV4aXQuIFRoZSBp
bnN0YWxsYXRpb24gcHJvZ3JhbSB3aWxsIGNvbnRpbnVlIGluIGZpdmUgc2Vjb25kcy5gLCJtaWdy
YXRlLmh1c3RvakZvdW5kIjpgSHVzdE9KIGRldGVjdGVkLiBUaGUgaW5zdGFsbGF0aW9uIHByb2dy
YW0gY2FuIG1pZ3JhdGUgYWxsIGRhdGEgZnJvbSBIdXN0T0ogdG8gSHlkcm8uClRoZSBvcmlnaW5h
bCBkYXRhIHdpbGwgbm90IGJlIGxvc3QsIGFuZCB5b3UgY2FuIHN3aXRjaCBiYWNrIHRvIEh1c3RP
SiBhdCBhbnkgdGltZS4KVGhpcyBmZWF0dXJlIHN1cHBvcnRzIHRoZSBvcmlnaW5hbCB2ZXJzaW9u
IG9mIEh1c3RPSiBhbmQgc29tZSBtb2RpZmllZCB2ZXJzaW9ucy4gRW50ZXIgeSB0byBjb25maXJt
IHRoaXMgb3BlcmF0aW9uLgpJZiB5b3UgaGF2ZSBhbnkgcXVlc3Rpb25zIGFib3V0IHRoZSBtaWdy
YXRpb24gcHJvY2VzcywgcGxlYXNlIGFkZCBRUSBncm91cCAxMDg1ODUzNTM4IHRvIGNvbnN1bHQg
dGhlIGFkbWluaXN0cmF0b3IuYH19LFU9InpoIixtPXQ9PihlLC4uLm4pPT4odChNW1VdW2VdfHxl
LC4uLm4pLDApLGE9e2luZm86bShjb25zb2xlLmxvZyksd2FybjptKGNvbnNvbGUud2FybiksZmF0
YWw6KHQsLi4uZSk9PihtKGNvbnNvbGUuZXJyb3IpKHQsLi4uZSkscHJvY2Vzcy5leGl0KDEpKX07
bGV0IGQ9MDthLmluZm8oImluc3RhbGwuc3RhcnQiKTtjb25zdCBKPSJhYmNkZWZnaGlqa2xtbm9w
cXJzdHV2d3h5ekFCQ0RFRkdISUpLTE1OT1BRUlNUVVZXWFlaMTIzNDU2Nzg5MCI7ZnVuY3Rpb24g
eih0PTMyLGU9Sil7bGV0IG49IiI7Zm9yKGxldCBvPTE7bzw9dDtvKyspbis9ZVtNYXRoLmZsb29y
KE1hdGgucmFuZG9tKCkqZS5sZW5ndGgpXTtyZXR1cm4gbn1sZXQgYz16KDMyKSxwPSEwO2NvbnN0
IGg9cHJvY2Vzcy5hcmd2LmluY2x1ZGVzKCItLW5vLWNhZGR5IiksYj1bIkBoeWRyb29qL3VpLWRl
ZmF1bHQiLCJAaHlkcm9vai9mcHMtaW1wb3J0ZXIiLCJAaHlkcm9vai9hMTF5Il0sST1gJHtiLmpv
aW4oIiAiKX1gO2xldCB4PSEwO2NvbnN0IFQ9KDAscy5yZWFkRmlsZVN5bmMpKCIvcHJvYy9jcHVp
bmZvIiwidXRmLTgiKTtULmluY2x1ZGVzKCJhdngiKXx8KHg9ITEsYS53YXJuKCJ3YXJuLmF2eCIp
KTtjb25zdCB1PWAke3Byb2Nlc3MuZW52LkhPTUV9Ly5uaXgtcHJvZmlsZS9gLGw9KHQsZT10LG49
ITApPT5gICAtIHR5cGU6IGJpbmQKICAgIHNvdXJjZTogJHt0fQogICAgdGFyZ2V0OiAke2V9JHtu
P2AKICAgIHJlYWRvbmx5OiB0cnVlYDoiIn1gLEY9YG1vdW50Ogoke2woYCR7dX1iaW5gLCIvYmlu
Iil9CiR7bChgJHt1fWJpbmAsIi91c3IvYmluIil9CiR7bChgJHt1fWxpYmAsIi9saWIiKX0KJHts
KGAke3V9c2hhcmVgLCIvc2hhcmUiKX0KJHtsKGAke3V9ZXRjYCwiL2V0YyIpfQoke2woIi9uaXgi
LCIvbml4Iil9CiR7bCgiL2Rldi9udWxsIiwiL2Rldi9udWxsIiwhMSl9CiR7bCgiL2Rldi91cmFu
ZG9tIiwiL2Rldi91cmFuZG9tIiwhMSl9CiAgLSB0eXBlOiB0bXBmcwogICAgdGFyZ2V0OiAvdwog
ICAgZGF0YTogc2l6ZT01MTJtLG5yX2lub2Rlcz04awogIC0gdHlwZTogdG1wZnMKICAgIHRhcmdl
dDogL3RtcAogICAgZGF0YTogc2l6ZT01MTJtLG5yX2lub2Rlcz04awpwcm9jOiB0cnVlCndvcmtE
aXI6IC93Cmhvc3ROYW1lOiBleGVjdXRvcl9zZXJ2ZXIKZG9tYWluTmFtZTogZXhlY3V0b3Jfc2Vy
dmVyCnVpZDogMTUzNgpnaWQ6IDE1MzYKYCxfPWAjIFx1NTk4Mlx1Njc5Q1x1NEY2MFx1NUUwQ1x1
NjcxQlx1NEY3Rlx1NzUyOFx1NTE3Nlx1NEVENlx1N0FFRlx1NTNFM1x1NjIxNlx1NEY3Rlx1NzUy
OFx1NTdERlx1NTQwRFx1RkYwQ1x1NEZFRVx1NjUzOVx1NkI2NFx1NTkwNCA6ODAgXHU3Njg0XHU1
MDNDXHU1NDBFXHU1NzI4IH4vLmh5ZHJvIFx1NzZFRVx1NUY1NVx1NEUwQlx1NEY3Rlx1NzUyOCBj
YWRkeSByZWxvYWQgXHU5MUNEXHU4RjdEXHU5MTREXHU3RjZFXHUzMDAyCiMgXHU1OTgyXHU2NzlD
XHU0RjYwXHU1NzI4XHU1RjUzXHU1MjREXHU5MTREXHU3RjZFXHU0RTBCXHU4MEZEXHU1OTFGXHU5
MDFBXHU4RkM3IGh0dHA6Ly9cdTRGNjBcdTc2ODRcdTU3REZcdTU0MEQvIFx1NkI2M1x1NUUzOFx1
OEJCRlx1OTVFRVx1NTIzMFx1N0Y1MVx1N0FEOVx1RkYwQ1x1ODJFNVx1OTcwMFx1NUYwMFx1NTQy
RiBzc2xcdUZGMEMKIyBcdTRFQzVcdTk3MDBcdTVDMDYgOjgwIFx1NjUzOVx1NEUzQVx1NEY2MFx1
NzY4NFx1NTdERlx1NTQwRFx1RkYwOFx1NTk4MiBoeWRyby5hY1x1RkYwOVx1NTQwRVx1NEY3Rlx1
NzUyOCBjYWRkeSByZWxvYWQgXHU5MUNEXHU4RjdEXHU5MTREXHU3RjZFXHU1MzczXHU1M0VGXHU4
MUVBXHU1MkE4XHU3QjdFXHU1M0QxIHNzbCBcdThCQzFcdTRFNjZcdTMwMDIKIyBcdTU4NkJcdTUx
OTlcdTVCOENcdTY1NzRcdTU3REZcdTU0MERcdUZGMENcdTZDRThcdTYxMEZcdTUzM0FcdTUyMDZc
dTY3MDlcdTY1RTAgd3d3IFx1RkYwOHd3dy5oeWRyby5hYyBcdTU0OEMgaHlkcm8uYWMgXHU0RTBE
XHU1NDBDXHVGRjBDXHU4QkY3XHU2OEMwXHU2N0U1IEROUyBcdThCQkVcdTdGNkVcdUZGMDkKIyBc
dThCRjdcdTZDRThcdTYxMEZcdTU3MjhcdTk2MzJcdTcwNkJcdTU4OTkvXHU1Qjg5XHU1MTY4XHU3
RUM0XHU0RTJEXHU2NTNFXHU4ODRDXHU3QUVGXHU1M0UzXHVGRjBDXHU0RTE0XHU5MEU4XHU1MjA2
XHU4RkQwXHU4NDI1XHU1NTQ2XHU0RjFBXHU2MkU2XHU2MjJBXHU2NzJBXHU3RUNGXHU1OTA3XHU2
ODQ4XHU3Njg0XHU1N0RGXHU1NDBEXHUzMDAyCiMgRm9yIG1vcmUgaW5mb3JtYXRpb24sIHJlZmVy
IHRvIGNhZGR5IHYyIGRvY3VtZW50YXRpb24uCjo4MCB7CiAgZW5jb2RlIHpzdGQgZ3ppcAogIGxv
ZyB7CiAgICBvdXRwdXQgZmlsZSAvZGF0YS9hY2Nlc3MubG9nIHsKICAgICAgcm9sbF9zaXplIDFn
YgogICAgICByb2xsX2tlZXBfZm9yIDcyaAogICAgfQogICAgZm9ybWF0IGpzb24KICB9CiAgIyBI
YW5kbGUgc3RhdGljIGZpbGVzIGRpcmVjdGx5LCBmb3IgYmV0dGVyIHBlcmZvcm1hbmNlLgogIHJv
b3QgKiAvcm9vdC8uaHlkcm8vc3RhdGljCiAgQHN0YXRpYyB7CiAgICBmaWxlIHsKICAgICAgdHJ5
X2ZpbGVzIHtwYXRofQogICAgfQogIH0KICBoYW5kbGUgQHN0YXRpYyB7CiAgICBmaWxlX3NlcnZl
cgogIH0KICBoYW5kbGUgewogICAgcmV2ZXJzZV9wcm94eSBodHRwOi8vMTI3LjAuMC4xOjg4ODgK
ICB9Cn0KCiMgXHU1OTgyXHU2NzlDXHU0RjYwXHU5NzAwXHU4OTgxXHU1NDBDXHU2NUY2XHU5MTRE
XHU3RjZFXHU1MTc2XHU0RUQ2XHU3QUQ5XHU3MEI5XHVGRjBDXHU1M0VGXHU1M0MyXHU4MDAzXHU0
RTBCXHU2NUI5XHU4QkJFXHU3RjZFXHVGRjFBCiMgXHU4QkY3XHU2Q0U4XHU2MTBGXHVGRjFBXHU1
OTgyXHU2NzlDXHU1OTFBXHU0RTJBXHU3QUQ5XHU3MEI5XHU5NzAwXHU4OTgxXHU1MTcxXHU0RUFC
XHU1NDBDXHU0RTAwXHU0RTJBXHU3QUVGXHU1M0UzXHVGRjA4XHU1OTgyIDgwLzQ0M1x1RkYwOVx1
RkYwQ1x1OEJGN1x1Nzg2RVx1NEZERFx1NEUzQVx1NkJDRlx1NEUyQVx1N0FEOVx1NzBCOVx1OTBG
RFx1NTg2Qlx1NTE5OVx1NEU4Nlx1NTdERlx1NTQwRFx1RkYwMQojIFx1NTJBOFx1NjAwMVx1N0FE
OVx1NzBCOVx1RkYxQQojIHh4eC5jb20gewojICAgIHJldmVyc2VfcHJveHkgaHR0cDovLzEyNy4w
LjAuMToxMjM0CiMgfQojIFx1OTc1OVx1NjAwMVx1N0FEOVx1NzBCOVx1RkYxQQojIHh4eC5jb20g
ewojICAgIHJvb3QgKiAvd3d3L3h4eC5jb20KIyAgICBmaWxlX3NlcnZlcgojIH0KYCxEPWAKdHJ1
c3RlZC1wdWJsaWMta2V5cyA9IGNhY2hlLm5peG9zLm9yZy0xOjZOQ0hkRDU5WDQzMW8wZ1d5cGJN
ckFVUmtiSjE2WlBNUUZHc3BjRFNoalk9IGh5ZHJvLmFjOkV5dGZ2eVJlV0hGd2hZOU1DR2ltQ0lu
NDZLUU5mbXY5eThFMk5xbE5meFE9CmNvbm5lY3QtdGltZW91dCA9IDEwCmV4cGVyaW1lbnRhbC1m
ZWF0dXJlcyA9IG5peC1jb21tYW5kIGZsYWtlcwpgLFI9YXN5bmMgdD0+e2NvbnN0IGU9Ty5kZWZh
dWx0LmNyZWF0ZVNlcnZlcigpLG49YXdhaXQgbmV3IFByb21pc2Uobz0+e2Uub25jZSgiZXJyb3Ii
LCgpPT5vKCExKSksZS5vbmNlKCJsaXN0ZW5pbmciLCgpPT5vKCEwKSksZS5saXN0ZW4odCl9KTty
ZXR1cm4gZS5jbG9zZSgpLG59O2Z1bmN0aW9uIEEoKXtjb25zdCB0PXIoInlhcm4gZ2xvYmFsIGRp
ciIpLm91dHB1dD8udHJpbSgpfHwiIjtpZighdClyZXR1cm4hMTtjb25zdCBlPWAke3R9L3BhY2th
Z2UuanNvbmAsbj1KU09OLnBhcnNlKCgwLHMucmVhZEZpbGVTeW5jKShlLCJ1dGYtOCIpKTtyZXR1
cm4gZGVsZXRlIG4ucmVzb2x1dGlvbnMsKDAscy53cml0ZUZpbGVTeW5jKShlLEpTT04uc3RyaW5n
aWZ5KG4sbnVsbCwyKSksITB9ZnVuY3Rpb24gRygpe2NvbnN0IHQ9cigieWFybiBnbG9iYWwgZGly
Iikub3V0cHV0Py50cmltKCl8fCIiO2lmKCF0KXJldHVybiExO2NvbnN0IGU9YCR7dH0vcGFja2Fn
ZS5qc29uYCxuPSgwLHMuZXhpc3RzU3luYykoZSk/cmVxdWlyZShlKTp7fTtyZXR1cm4gbi5yZXNv
bHV0aW9uc3x8PXt9LE9iamVjdC5hc3NpZ24obi5yZXNvbHV0aW9ucyxPYmplY3QuZnJvbUVudHJp
ZXMoWyJAZXNidWlsZC9saW51eC1sb29uZzY0IiwiZXNidWlsZC13aW5kb3dzLTMyIiwuLi5bImFu
ZHJvaWQiLCJkYXJ3aW4iLCJmcmVlYnNkIiwid2luZG93cyJdLmZsYXRNYXAobz0+W2Ake299LTY0
YCxgJHtvfS1hcm02NGBdKS5tYXAobz0+YGVzYnVpbGQtJHtvfWApLC4uLlsiMzIiLCJhcm0iLCJt
aXBzNjQiLCJwcGM2NCIsInJpc2N2NjQiLCJzMzkweCJdLm1hcChvPT5gZXNidWlsZC1saW51eC0k
e299YCksLi4uWyJuZXRic2QiLCJvcGVuYnNkIiwic3Vub3MiXS5tYXAobz0+YGVzYnVpbGQtJHtv
fS02NGApXS5tYXAobz0+W28sImxpbms6L2Rldi9udWxsIl0pKSkscihgbWtkaXIgLXAgJHt0fWAp
LCgwLHMud3JpdGVGaWxlU3luYykoZSxKU09OLnN0cmluZ2lmeShuLG51bGwsMikpLCEwfWNvbnN0
IHE9ai5kZWZhdWx0LnRvdGFsbWVtKCkvMTAyNC8xMDI0LzEwMjQsdz1NYXRoLm1heCguMjUsTWF0
aC5mbG9vcihxLzYqMTAwKS8xMDApLHY9WygpPT57Y29uc3QgdD1yZXF1aXJlKGAke3Byb2Nlc3Mu
ZW52LkhPTUV9Ly5oeWRyby9jb25maWcuanNvbmApO3QudXJpP2M9bmV3IFVSTCh0LnVyaSkucGFz
c3dvcmR8fCIoTm8gcGFzc3dvcmQpIjpjPXQucGFzc3dvcmR8fCIoTm8gcGFzc3dvcmQpIixhLmlu
Zm8oImV4dHJhLmRiVXNlciIpLGEuaW5mbygiZXh0cmEuZGJQYXNzd29yZCIsYyl9XSxRPSgpPT5b
e2luaXQ6Imluc3RhbGwucHJlcGFyaW5nIixvcGVyYXRpb25zOlsoKT0+e3B8fCgwLHMud3JpdGVG
aWxlU3luYykoIi9ldGMvbml4L25peC5jb25mIixgc3Vic3RpdHV0ZXJzID0gaHR0cHM6Ly9jYWNo
ZS5uaXhvcy5vcmcvIGh0dHBzOi8vbml4Lmh5ZHJvLmFjL2NhY2hlCiR7RH1gKSwhcCYmKHIoIm5p
eC1jaGFubmVsIC0tcmVtb3ZlIG5peHBrZ3MiLHtzdGRpbzoiaW5oZXJpdCJ9KSxyKCJuaXgtY2hh
bm5lbCAtLWFkZCBodHRwczovL25peG9zLm9yZy9jaGFubmVscy9uaXhwa2dzLXVuc3RhYmxlIG5p
eHBrZ3MiLHtzdGRpbzoiaW5oZXJpdCJ9KSxyKCJuaXgtY2hhbm5lbCAtLXVwZGF0ZSIse3N0ZGlv
OiJpbmhlcml0In0pKX0sIm5peC1lbnYgLWlBIG5peHBrZ3MucG0yIG5peHBrZ3MueWFybiBuaXhw
a2dzLmVzYnVpbGQgbml4cGtncy5iYXNoIG5peHBrZ3MudW56aXAgbml4cGtncy56aXAgbml4cGtn
cy5kaWZmdXRpbHMgbml4cGtncy5wYXRjaCJdfSx7aW5pdDoiaW5zdGFsbC5tb25nb2RiIixvcGVy
YXRpb25zOlsoKT0+KDAscy53cml0ZUZpbGVTeW5jKShgJHtwcm9jZXNzLmVudi5IT01FfS8uY29u
ZmlnL25peHBrZ3MvY29uZmlnLm5peGAsYHsKICAgIHBlcm1pdHRlZEluc2VjdXJlUGFja2FnZXMg
PSBbCiAgICAgICAgIm9wZW5zc2wtMS4xLjF0IgogICAgICAgICJvcGVuc3NsLTEuMS4xdSIKICAg
ICAgICAib3BlbnNzbC0xLjEuMXYiCiAgICAgICAgIm9wZW5zc2wtMS4xLjF3IgogICAgICAgICJv
cGVuc3NsLTEuMS4xeCIKICAgICAgICAib3BlbnNzbC0xLjEuMXkiCiAgICAgICAgIm9wZW5zc2wt
MS4xLjF6IgogICAgXTsKfWApLGBuaXgtZW52IC1pQSBoeWRyby5tb25nb2RiJHt4PzY6NH0ke3A/
Ii1jbiI6IiJ9IG5peHBrZ3MubW9uZ29zaCBuaXhwa2dzLm1vbmdvZGItdG9vbHNgLCJidW4gaSAt
ZyBtb25nb2RiIl19LHtpbml0OiJpbnN0YWxsLmNhZGR5Iixza2lwOigpPT4hcigiY2FkZHkgdmVy
c2lvbiIpLmNvZGV8fGgsb3BlcmF0aW9uczpbIm5peC1lbnYgLWlBIG5peHBrZ3MuY2FkZHkiLCgp
PT4oMCxzLndyaXRlRmlsZVN5bmMpKGAke3Byb2Nlc3MuZW52LkhPTUV9Ly5oeWRyby9DYWRkeWZp
bGVgLF8pXX0se2luaXQ6Imluc3RhbGwuaHlkcm8iLG9wZXJhdGlvbnM6WygpPT5HKCksW2BidW4g
aSAtZyAke0l9YCx7cmV0cnk6ITB9XSwoKT0+eygwLHMud3JpdGVGaWxlU3luYykoYCR7cHJvY2Vz
cy5lbnYuSE9NRX0vLmh5ZHJvL2FkZG9uLmpzb25gLEpTT04uc3RyaW5naWZ5KGIpKX0sKCk9PkEo
KV19LHtpbml0OiJpbnN0YWxsLmNyZWF0ZURhdGFiYXNlVXNlciIsc2tpcDooKT0+KDAscy5leGlz
dHNTeW5jKShgJHtwcm9jZXNzLmVudi5IT01FfS8uaHlkcm8vY29uZmlnLmpzb25gKSxvcGVyYXRp
b25zOlsicG0yIHN0YXJ0IG1vbmdvZCIsKCk9PmcoM2UzKSxhc3luYygpPT57Y29uc3R7TW9uZ29D
bGllbnQ6dCxXcml0ZUNvbmNlcm46ZX09cmVxdWlyZSgiL3Jvb3QvLmJ1bi9pbnN0YWxsL2dsb2Jh
bC9ub2RlX21vZHVsZXMvbW9uZ29kYiIpLG49YXdhaXQgdC5jb25uZWN0KCJtb25nb2RiOi8vMTI3
LjAuMC4xIix7cmVhZFByZWZlcmVuY2U6Im5lYXJlc3QiLHdyaXRlQ29uY2VybjpuZXcgZSgibWFq
b3JpdHkiKX0pO2F3YWl0IG4uZGIoImh5ZHJvIikuYWRkVXNlcigiaHlkcm8iLGMse3JvbGVzOlt7
cm9sZToicmVhZFdyaXRlIixkYjoiaHlkcm8ifV19KSxhd2FpdCBuLmNsb3NlKCl9LCgpPT4oMCxz
LndyaXRlRmlsZVN5bmMpKGAke3Byb2Nlc3MuZW52LkhPTUV9Ly5oeWRyby9jb25maWcuanNvbmAs
SlNPTi5zdHJpbmdpZnkoe3VyaTpgbW9uZ29kYjovL2h5ZHJvOiR7Y31AMTI3LjAuMC4xOjI3MDE3
L2h5ZHJvYH0pKSwicG0yIHN0b3AgbW9uZ29kIiwicG0yIGRlbCBtb25nb2QiXX0se2luaXQ6Imlu
c3RhbGwuc3RhcnRpbmciLG9wZXJhdGlvbnM6W1sicG0yIHN0b3AgYWxsIix7aWdub3JlOiEwfV0s
KCk9PigwLHMud3JpdGVGaWxlU3luYykoYCR7cHJvY2Vzcy5lbnYuSE9NRX0vLmh5ZHJvL21vdW50
LnlhbWxgLEYpLCgpPT5jb25zb2xlLmxvZyhgV2lyZWRUaWdlciBjYWNoZSBzaXplOiAke3d9R0Jg
KSxgcG0yIHN0YXJ0IG1vbmdvZCAtLW5hbWUgbW9uZ29kYiAtLSAtLWF1dGggLS1iaW5kX2lwIDAu
MC4wLjAgLS13aXJlZFRpZ2VyQ2FjaGVTaXplR0I9JHt3fWAsKCk9PmcoMWUzKSwicG0yIHN0YXJ0
IGJ1biAtLW5hbWUgaHlkcm9vaiAtLSBzdGFydCIsYXN5bmMoKT0+e2h8fChhd2FpdCBSKDgwKXx8
YS53YXJuKCJwb3J0LjgwIikscigicG0yIHN0YXJ0IGNhZGR5IC0tIHJ1biIse2N3ZDpgJHtwcm9j
ZXNzLmVudi5IT01FfS8uaHlkcm9gfSkscigiaHlkcm9vaiBjbGkgc3lzdGVtIHNldCBzZXJ2ZXIu
eGZmIHgtZm9yd2FyZGVkLWZvciIpLHIoImh5ZHJvb2ogY2xpIHN5c3RlbSBzZXQgc2VydmVyLnho
b3N0IHgtZm9yd2FyZGVkLWhvc3QiKSl9LCJwbTIgc3RhcnR1cCIsInBtMiBzYXZlIl19LHtpbml0
OiJpbnN0YWxsLmRvbmUiLG9wZXJhdGlvbnM6dn0se2luaXQ6Imluc3RhbGwucG9zdGluc3RhbGwi
LG9wZXJhdGlvbnM6WydlY2hvICJ2bS5zd2FwcGluZXNzID0gMSIgPj4vZXRjL3N5c2N0bC5jb25m
Jywic3lzY3RsIC1wIixbInBtMiBpbnN0YWxsIHBtMi1sb2dyb3RhdGUiLHtyZXRyeTohMH1dLCJw
bTIgc2V0IHBtMi1sb2dyb3RhdGU6bWF4X3NpemUgNjRNIl19LHtpbml0OiJpbnN0YWxsLmFsbGRv
bmUiLG9wZXJhdGlvbnM6Wy4uLnYsKCk9PmEuaW5mbygiaW5zdGFsbC5hbGxkb25lIildfV07YXN5
bmMgZnVuY3Rpb24gJCgpe3RyeXtpZihwcm9jZXNzLmVudi5SRUdJT04pcHJvY2Vzcy5lbnYuUkVH
SU9OIT09IkNOIiYmKHA9ITEpO2Vsc2V7Y29uc29sZS5sb2coIkdldHRpbmcgSVAgaW5mbyB0byBm
aW5kIGJlc3QgbWlycm9yOiIpO2NvbnN0IGU9YXdhaXQgZmV0Y2goImh0dHBzOi8vaXBpbmZvLmlv
Iix7aGVhZGVyczp7YWNjZXB0OiJhcHBsaWNhdGlvbi9qc29uIn19KS50aGVuKG49Pm4uanNvbigp
KTtkZWxldGUgZS5yZWFkbWUsY29uc29sZS5sb2coZSksZS5jb3VudHJ5IT09IkNOIiYmKHA9ITEp
fX1jYXRjaChlKXtjb25zb2xlLmVycm9yKGUpLGNvbnNvbGUubG9nKCJDYW5ub3QgZmluZCB0aGUg
YmVzdCBtaXJyb3IuIEZhbGxiYWNrIHRvIGRlZmF1bHQuIil9Y29uc3QgdD1RKCk7Zm9yKGxldCBl
PTA7ZTx0Lmxlbmd0aDtlKyspe2NvbnN0IG49dFtlXTtpZighbi5za2lwPy4oKSlmb3IobGV0IG8g
b2Ygbi5vcGVyYXRpb25zKWlmKG8gaW5zdGFuY2VvZiBBcnJheXx8KG89W28se31dKSxvWzBdLnRv
U3RyaW5nKCkuc3RhcnRzV2l0aCgibml4LWVudiIpJiYob1sxXS5yZXRyeT0hMCksdHlwZW9mIG9b
MF09PSJzdHJpbmciKXtkPTA7bGV0IGk9cihvWzBdLHtzdGRpbzoiaW5oZXJpdCJ9KTtmb3IoO2ku
Y29kZSYmb1sxXS5pZ25vcmUhPT0hMDspb1sxXS5yZXRyeSYmZDwzMD8oYS53YXJuKCJSZXRyeS4u
LiAoJXMpIixvWzBdKSxpPXIob1swXSx7c3RkaW86ImluaGVyaXQifSksZCsrKTphLmZhdGFsKCJF
cnJvciB3aGVuIHJ1bm5pbmcgJXMiLG9bMF0pfWVsc2V7ZD0wO2xldCBpPWF3YWl0IG9bMF0ob1sx
XSk7Zm9yKDtpPT09InJldHJ5IjspZDwzMD8oYS53YXJuKCJSZXRyeS4uLiIpLGk9YXdhaXQgb1sw
XShvWzFdKSxkKyspOmEuZmF0YWwoIkVycm9yIGluc3RhbGxpbmciKX19fSQoKS5jYXRjaChhLmZh
dGFsKSxnbG9iYWwubWFpbj0kOwo=
EOF123
cat /tmp/install.b64 | base64 -d >>/tmp/install.js 
node /tmp/install.js "$@"
set +e
