# Public IPFS HTTP Gateways Research
There're various HTTP gaways availble on the internet. Lists can be found here (https://luke.lol/ipfs.php) and here (https://ipfs.github.io/public-gateway-checker/). No resonable review of publicly available gayeways was found on the internet, the mentioned lists simply show if a certain gateway is available/alive or not. This research is aimed at providing performance ranking and insights into these gateways. Should you be puzzled about which gateways to choose for your  project to reliably access IPFS data without running a node but over the Web/HTTP this research can be a starting point.
# Research Design
A total of 29 gateways were chosen in late February 2021 from the list at https://luke.lol/ipfs.php (those green ones at the time of access).
2 IPFS nodes were set-up on Raspberry Pi (located in different towns), both sitting behind NAT: ipfs-go version 0.8.0, AutoRelay option turned on. 4 files were pinned to this nodes, file sizes: 8.9, 30, 75.4 and 415.9 megabytes (files reffered to as A, B, C and D accordingly).
A Dart script was written (*download_stats.dart*) which enumerates thorough the 29 gateways, requests seuentialy every of the four files by it's hash/CID (https://{gatways-address}/ipfs/{CID}) and measures:
- latency in milliseconds (time to first bytes) 
- average throughput (file size divided by time it took to complete download)
- checks if **content-length** header is returned in response
- logs failures (no response, receivning respone interrupted by server side or killed by client on 400 seconds timeout)
- saves test run results (29*4=126 rows per run) to CSV to be further analyzed
The script was executed on Linux VM in a datacenter in Ireland and on Windows PC in Belarus for the course of 4 days, a total of 10 runs per environment was conducted.
# Results
Complete results are available in /data/_ipfs_gtwy_analysis.xlsx_ file. Below is a summary for VM environment - the general conclusions are similar for both environments though VM having better connectivity speed wasn't a bottlneck for testing gateways' max throughput.
