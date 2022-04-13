# Public IPFS HTTP Gateways Research
There're various HTTP gateways availble on the internet. Lists can be found here (https://luke.lol/ipfs.php) and here (https://ipfs.github.io/public-gateway-checker/). Though no in-depth review of publicly available gayeways was found on the internet, the mentioned lists simply show if a certain gateway is available/alive or not. This research is aimed at providing performance ranking and insights into these gateways. Should you be puzzled about which gateways to choose for your project to reliably access IPFS data (without running a full IPFS node) over the Web/HTTP this research can be a starting point.

# Research Design
A total of 29 gateways were chosen in late February 2021 from the list at https://luke.lol/ipfs.php (those green ones at the time of access).
2 IPFS nodes were set-up on Raspberry Pi (located in different towns), both sitting behind NAT: ipfs-go version 0.8.0, AutoRelay option turned on. 4 files were pinned to these nodes, file sizes: 8.9, 30, 75.4 and 415.9 megabytes (files reffered to as A, B, C and D accordingly).
A Dart script was written (*download_stats.dart*) which enumerated through the 29 gateways, sequentialy requested each of the four files by hash/CID (https://{gateway-address}/ipfs/{CID}) and measured:
- latency in milliseconds (time to first byte) 
- average throughput (file size divided by time it took to complete download, time includes latency)
- checks if **content-length** header is returned in response. Content length determines if download progress is shown and if one can pause/resume the download
- logs failures (no response, response being interrupted by server side or killed by client after 400 seconds timeout)
- saves test run results (29*4=116 rows per run) to CSV to be further analyzed
The script was executed on Linux VM in a datacenter in Ireland and on Windows PC in Belarus for the course of 4 days, a total of 10 runs per environment was conducted. Before starting the first accountable run the files were requested several times from various gateways which allowed gateways to setup connections to IPFS nodes and warm up- at this stage it was typical to observe gatways hanging or failing to fetch given CIDs.

# Running the Tests
1. Install Dart SDK (https://dart.dev/get-dart)
2. Updated *download_stats.dart* script with your own CIDs of test files -go to *generateUrls()* method and change *const fileHashes*. You can also alter the list of tested gateways via *const fromLukeLol*
3. Run the script via *dart download_stats.dart*
4. When the test is complete the results will be saved to a CSV file and name of the file will be printed on the screen

# Results
Complete results are available in /data/\_ipfs_gtwy_analysis.xlsx file. Below is a summary for VM environment - the general conclusions are similar for both environments though VM having better connectivity speed wasn't a bottlneck for testing gateways' max throughput.

## Smaller files A (8.9MB) and B (30MB)	
 \* Throughput in MegaBytes per second	
 
 \** % of total 20 requests (10 per file)

|                        | Avg Throughput<br>(MB/s)\* | Min<br>(MB/s)   | Max<br>(MB/s)   | Avg Latency<br>(ms) | Content-length | % Downloads failed\*\* |
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

## Lager files C (75.4MB) and D (415.9MB)

\* latency for C and D issupposed to be lower since the files are downloaded right after A and B

\** larger files' downloads are more prone to be interrupted, also there was 400 seconds timeout to complete download (slow downloads were interrupted on client sides)

|                        | Avg Throughput<br>(MB/s) | Min<br>(MB/s) | Max<br>(MB/s) | Avg Latency<br>(ms)\* | Content-length | % Downloads failed \*\* |
| ---------------------- | ------------------------ | ------------- | ------------- | --------------------- | -------------- | ----------------------- |
|  |
| cloudflare-ipfs.com    | 29,66                    | 19,26         | 43,11         | 51                    | No             | 0%                      |
| cf-ipfs.com            | 27,85                    | 19,06         | 39,68         | 87                    | No             | 0%                      |
| 10.via0.com            | 27,79                    | 0,08          | 43,12         | 131                   | Yes            | 10%                     |
| ipfs.cf-ipfs.com       | 20,99                    | 5,47          | 41,87         | 120                   | No             | 0%                      |
| gateway.ipfs.io        | 17,05                    | 0,21          | 21,25         | 99                    | Yes            | 0%                      |
| ipfs.greyh.at          | 14,46                    | 5,44          | 19,33         | 459                   | Yes            | 0%                      |
| ipfs.drink.cafe        | 12,95                    | 4,69          | 19,8          | 632                   | Yes            | 0%                      |
| ipfs.sloppyta.co       | 10,87                    | 3,55          | 13,55         | 210                   | Yes            | 0%                      |
| ipfs.io                | 9,68                     | 3,26          | 12,87         | 104                   | Yes            | 0%                      |
| snap1.d.tube           | 9,22                     | 3,37          | 13,88         | 138                   | Yes            | 0%                      |
| ipfs.telos.miami       | 9,10                     | 3,10          | 12,89         | 795                   | Yes            | 0%                      |
| robotizing.net         | 8,81                     | 3,49          | 12,99         | 450                   | Yes            | 0%                      |
| ipfs.fleek.co          | 8,61                     | 2,69          | 13,9          | 919                   | Yes            | 15%                     |
| ipfs.oceanprotocol.com | 8,55                     | 8,07          | 9,124         | 333                   | Yes            | 70%                     |
| ipfs.overpi.com        | 7,91                     | 3,26          | 11,85         | 1020                  | Yes            | 0%                      |
| ipfs.best-practice.se  | 6,59                     | 0,74          | 20,69         | 1325                  | Yes            | 35%                     |
| dweb.link              | 6,32                     | 0,37          | 10,16         | 2077                  | Yes            | 0%                      |
| jacl.tech              | 6,12                     | 1,31          | 12,79         | 2249                  | Yes            | 0%                      |
| ninetailed.ninja       | 5,89                     | 2,26          | 10,15         | 474                   | Yes            | 35%                     |
| ipfs.infura.io         | 3,80                     | 1,01          | 12,38         | 1756                  | Yes            | 40%                     |
| ipfs.yt                | 1,75                     | 0,61          | 4,766         | 2680                  | No             | 10%                     |
| gateway.pinata.cloud   | 1,67                     | 1,00          | 2,542         | 415                   | Yes            | 10%                     |
| ipfs.runfission.com    | 1,57                     | 0,18          | 3,587         | 5116                  | Yes            | 15%                     |
| ipfs.2read.net         | 0,19                     | 0,15          | 0,749         | 161                   | Yes            | 55%                     |
| trusti.id              | 0,16                     | 0,06          | 0,592         | 2094                  | Yes            | 50%                     |
| ipfs.k1ic.com          | 0,12                     | 0,00          | 0,194         | 2948                  | Yes            | 60%                     |
| gateway.ravenland.org  | Never connected          |
| hardbin.com            | Never connected          |
| ipfs.jbb.one           | Never connected          |
