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
Complete results are available in /data/\_ipfs_gtwy_analysis.xlsx file. Below is a summary for VM environment - the general conclusions are similar for both environments though VM having better connectivity speed wasn't a bottlneck for testing gateways' max throughput.

## Smaller files A (8.9MB) and B (30MB)	
 \* Throughput in MegaBytes per second	
 
 \** % of total 20 requests (10 per file)

|                        | Avg Throughput<br>(MB/s)\* | Min   | Max   | Avg Latency<br>(ms) | Content-length | % Downloads failed\*\* |
| ---------------------- | -------------------------- | ----- | ----- | ------------------- | -------------- | ---------------------- |
|  |
| cf-ipfs.com            | 15,74                      | 10,61 | 22,25 | 150                 | No             | 0%                     |
| gateway.ipfs.io        | 15,61                      | 11,97 | 18,68 | 109                 | Yes            | 0%                     |
| cloudflare-ipfs.com    | 14,85                      | 4,69  | 20,07 | 73                  | No             | 0%                     |
| 10.via0.com            | 13,30                      | 0,12  | 27,69 | 216                 | Yes            | 0%                     |
| gateway.pinata.cloud   | 11,97                      | 2,20  | 18,68 | 246                 | Yes            | 0%                     |
| ipfs.cf-ipfs.com       | 11,60                      | 4,09  | 18,76 | 123                 | No             | 0%                     |
| ipfs.io                | 8,36                       | 2,98  | 13,09 | 148                 | Yes            | 0%                     |
| ipfs.sloppyta.co       | 7,69                       | 3,15  | 11,57 | 239                 | Yes            | 0%                     |
| ipfs.best-practice.se  | 7,51                       | 0,31  | 15,54 | 1091                | Yes            | 20%                    |
| snap1.d.tube           | 7,34                       | 2,61  | 12,94 | 322                 | Yes            | 0%                     |
| ipfs.greyh.at          | 7,13                       | 2,15  | 11,49 | 471                 | Yes            | 0%                     |
| ipfs.drink.cafe        | 6,19                       | 0,92  | 10,63 | 626                 | Yes            | 0%                     |
| ipfs.2read.net         | 5,99                       | 0,23  | 13,85 | 165                 | Yes            | 0%                     |
| robotizing.net         | 5,65                       | 2,18  | 10,56 | 640                 | Yes            | 0%                     |
| dweb.link              | 5,64                       | 0,06  | 10,44 | 1267                | Yes            | 0%                     |
| ninetailed.ninja       | 5,44                       | 1,97  | 9,21  | 393                 | Yes            | 0%                     |
| ipfs.telos.miami       | 4,91                       | 0,84  | 8,45  | 1363                | Yes            | 0%                     |
| ipfs.oceanprotocol.com | 4,87                       | 2,18  | 7,03  | 334                 | Yes            | 70%                    |
| ipfs.fleek.co          | 4,74                       | 2,07  | 7,68  | 929                 | Yes            | 0%                     |
| ipfs.overpi.com        | 4,15                       | 2,66  | 6,52  | 1162                | Yes            | 0%                     |
| ipfs.infura.io         | 2,49                       | 0,87  | 9,43  | 1734                | Yes            | 0%                     |
| jacl.tech              | 2,38                       | 0,81  | 4,85  | 2331                | Yes            | 0%                     |
| ipfs.yt                | 1,70                       | 0,18  | 7,28  | 4736                | No             | 0%                     |
| ipfs.runfission.com    | 0,99                       | 0,18  | 3,06  | 6959                | Yes            | 0%                     |
| trusti.id              | 0,15                       | 0,07  | 0,46  | 1791                | Yes            | 5%                     |
| ipfs.k1ic.com          | 0,13                       | 0,01  | 0,20  | 3476                | Yes            | 20%                    |
| gateway.ravenland.org  | Never connected            |
| hardbin.com            | Never connected            |
| ipfs.jbb.one           | Never connected            |
