import 'dart:io';

class Result {
  final String url;
  final DateTime started;
  final DateTime ended;
  final int totalTimeMs;
  final int ttfbMs;
  final int redirects;
  final int contentLength;
  final int downloadedLength;
  double get downloadSpeedMbps =>
      downloadedLength / (totalTimeMs - ttfbMs) * 1000 / 1024 / 1024;
  double get downloadSpeedWithTtfbMbps =>
      downloadedLength / (totalTimeMs) * 1000 / 1024 / 1024;
  final String error;

  Result(this.url, this.started, this.ended, this.totalTimeMs, this.ttfbMs,
      this.redirects, this.contentLength, this.downloadedLength, this.error) {}

  String toCsv() {
    return this.url +
        ',' +
        this.started.toString() +
        ',' +
        this.ended.toString() +
        ',' +
        totalTimeMs.toString() +
        ',' +
        ttfbMs.toString() +
        ',' +
        redirects.toString() +
        ',' +
        contentLength.toString() +
        ',' +
        downloadedLength.toString() +
        ',' +
        downloadSpeedMbps.toString() +
        ',' +
        downloadSpeedWithTtfbMbps.toString() +
        ',' +
        error;
  }
}

void throwIfErrorStatus(int code) {
  if (code > 399) throw 'HTTP status code ' + code.toString();
}

Future<Result> download(String url) async {
  stdout.writeln('Downloading ${url}');

  var started = DateTime.now();
  var totalSw = Stopwatch();
  var redirects = 0;
  var ttfbMs = -1;
  var accum = 0;
  var cl = -1;
  var err = '';
  HttpClient client;

  var progress = 0;
  var prevAccum = 0;
  var throughput = -1.0;

  totalSw.start();

  try {
    client = HttpClient();
    client.connectionTimeout = Duration(seconds: 10);
    var request = await client.getUrl(Uri.parse(url));
    request.followRedirects = false;

    var response = await request.close();
    throwIfErrorStatus(response.statusCode);

    if (response.isRedirect) {
      redirects++;
      var location = response.headers['Location'].first;
      request = await client.getUrl(Uri.parse(location));
      response = await request.close();
      throwIfErrorStatus(response.statusCode);

      if (response.isRedirect) {
        redirects++;
        return Result(url, started, DateTime.now(), totalSw.elapsedMilliseconds,
            ttfbMs, redirects, cl, accum, '');
      }
    }
    cl = response.contentLength;

    ttfbMs = totalSw.elapsedMilliseconds;
    var prevMs = ttfbMs;

    await for (var val in response) {
      accum += val.length;
      var p = (accum / cl * 100).round();
      var el = totalSw.elapsedMilliseconds;
      if (p != progress || (el - prevMs > 500)) {
        progress = p;
        if (el - prevMs > 500) {
          throughput = (accum - prevAccum) / 1024 / 1024 / (el - prevMs) * 1000;
          prevAccum = accum;
          prevMs = el;
        }
        clearLine();
        stdout.write(
            '${cl != -1 ? p.toString() : '-'}% - ${throughput > 0 ? throughput.toStringAsFixed(2) : '-'}MB/s');
      }
    }

    clearLine();
    stdout.write(
        ' Avg. down. speed ${(accum / 1024 / 1024 / (totalSw.elapsedMilliseconds - ttfbMs) * 1000).toStringAsFixed(2)}MB/s, '
        'total time: ${(totalSw.elapsedMilliseconds / 1000).toStringAsFixed(1)}s');
  } catch (e) {
    err = e.toString();
  }
  totalSw.stop();
  client?.close();
  return Result(url, started, DateTime.now(), totalSw.elapsedMilliseconds,
      ttfbMs, redirects, cl, accum, err);
}

List<String> generateUrls() {
  //https://luke.lol/ipfs.php
  const fromLukeLol = [
    'https://10.via0.com/ipfs/',
    'https://cf-ipfs.com/ipfs/',
    'https://cloudflare-ipfs.com/ipfs/',
    'https://gateway.ipfs.io/ipfs/',
    'https://gateway.pinata.cloud/ipfs/',
    'https://gateway.ravenland.org/ipfs/',
    'https://hardbin.com/ipfs/',
    'https://ipfs.2read.net/ipfs/',
    'https://ipfs.best-practice.se/ipfs/',
    'https://ipfs.cf-ipfs.com/ipfs/',
    'https://ipfs.drink.cafe/ipfs/',
    'https://ipfs.fleek.co/ipfs/',
    'https://ipfs.greyh.at/ipfs/',
    'https://ipfs.infura.io/ipfs/',
    'https://ipfs.io/ipfs/',
    'https://jacl.tech/ipfs/',
    'https://ipfs.jbb.one/ipfs/',
    'https://ipfs.k1ic.com/ipfs/',
    'https://ipfs.overpi.com/ipfs/',
    'https://ipfs.runfission.com/ipfs/',
    'https://ipfs.sloppyta.co/ipfs/',
    'https://ipfs.telos.miami/ipfs/',
    'https://ipfs.yt/ipfs/',
    'https://robotizing.net/ipfs/',
    'https://trusti.id/ipfs/',
    'https://snap1.d.tube/ipfs/',
    'https://dweb.link/ipfs/',
    'https://ninetailed.ninja/ipfs/',
    'https://ipfs.oceanprotocol.com/ipfs/',
  ];

  const fileHashes = [
    'QmWbhkXXqg5JgQ45T2iqspfTC17AfE8qEhyE5Snia4TS39',
    'QmZALYrou9d7Yx9afDCPT9fveqxoPRLHnHuo8TyZomGhL1',
    'QmQH4iy5RKKHnT95ziKXjnmEKjBU8aB7hepmCMTNk9p348',
    'QmdhpvRUopXFJCh9x524WM81GJC55JJt1AEbNsML2TwrrZ'
  ];

  var urls = <String>[];

  for (var g in fromLukeLol) {
    for (var h in fileHashes) {
      urls.add(g + h);
    }
  }

  return urls;
}

void main(List<String> arguments) async {
  var sw = Stopwatch();
  sw.start();
  var date = DateTime.now();
  var dateString =
      '${date.day}.${date.month}.${date.year}-${date.hour}.${date.minute}';
  var fileName = 'ipfs gtwys stats ${dateString}.csv';
  var f = File(fileName);

  f.writeAsString(
      '"sep=,"\nurl,started,ended,totalTimeMs,ttfbMs,redirects,contentLength,downloadedLength,downloadSpeedMbps,downloadSpeedWithTtfbMbps,error\n',
      mode: FileMode.write);

  // var urls = [
  //   'https://cloudflare-ipfs.com/ipfs/QmWbhkXXqg5JgQ45T2iqspfTC17AfE8qEhyE5Snia4TS39',
  //   'https://ipfs.infura.io/ipfs/QmWbhkXXqg5JgQ45T2iqspfTC17AfE8qEhyE5Snia4TS39'
  // ];

  var urls = generateUrls();

  for (var i = 0; i < urls.length; i++) {
    var url = urls[i];
    var r = await download(url);
    stdout.writeln('  - ${i + 1}/${urls.length}');
    f.writeAsStringSync(r.toCsv() + '\n', mode: FileMode.append);
  }
  sw.stop();
  stdout.writeln('\nSaved to ${fileName}, ${sw.elapsed.inMinutes}m');
  exit(0);
}

extension Sw on Stopwatch {
  void restart() {
    this.reset();
    this.start();
  }
}

void clearLine() {
  stdout.add([$esc, $lbracket, $2, $k, $cr]);
}

const int $nul = 0x00;

const int $soh = 0x01;

const int $stx = 0x02;

const int $etx = 0x03;

const int $eot = 0x04;

const int $enq = 0x05;

const int $ack = 0x06;

const int $bel = 0x07;

const int $bs = 0x08;

const int $ht = 0x09;

const int $tab = 0x09;

const int $lf = 0x0A;

const int $vt = 0x0B;

const int $ff = 0x0C;

const int $cr = 0x0D;

const int $so = 0x0E;

const int $si = 0x0F;

const int $dle = 0x10;

const int $dc1 = 0x11;

const int $dc2 = 0x12;

const int $dc3 = 0x13;

const int $dc4 = 0x14;

const int $nak = 0x15;

const int $syn = 0x16;

const int $etb = 0x17;

const int $can = 0x18;

const int $em = 0x19;

const int $sub = 0x1A;

const int $esc = 0x1B;

const int $fs = 0x1C;

const int $gs = 0x1D;

const int $rs = 0x1E;

const int $us = 0x1F;

const int $del = 0x7F;

// Visible characters.

const int $space = 0x20;

const int $exclamation = 0x21;

const int $quot = 0x22;

const int $quote = 0x22;

const int $double_quote = 0x22;

const int $quotation = 0x22;

const int $hash = 0x23;

const int $$ = 0x24;

const int $dollar = 0x24;

const int $percent = 0x25;

const int $amp = 0x26;

const int $ampersand = 0x26;

const int $apos = 0x27;

const int $apostrophe = 0x27;

const int $single_quote = 0x27;

const int $lparen = 0x28;

const int $open_paren = 0x28;

const int $open_parenthesis = 0x28;

const int $rparen = 0x29;

const int $close_paren = 0x29;

const int $close_parenthesis = 0x29;

const int $asterisk = 0x2A;

const int $plus = 0x2B;

const int $comma = 0x2C;

const int $minus = 0x2D;

const int $dash = 0x2D;

const int $dot = 0x2E;

const int $fullstop = 0x2E;

const int $slash = 0x2F;

const int $solidus = 0x2F;

const int $division = 0x2F;

const int $0 = 0x30;

const int $1 = 0x31;

const int $2 = 0x32;

const int $3 = 0x33;

const int $4 = 0x34;

const int $5 = 0x35;

const int $6 = 0x36;

const int $7 = 0x37;

const int $8 = 0x38;

const int $9 = 0x39;

const int $colon = 0x3A;

const int $semicolon = 0x3B;

const int $lt = 0x3C;

const int $less_than = 0x3C;

const int $langle = 0x3C;

const int $open_angle = 0x3C;

const int $equal = 0x3D;

const int $gt = 0x3E;

const int $greater_than = 0x3E;

const int $rangle = 0x3E;

const int $close_angle = 0x3E;

const int $question = 0x3F;

const int $at = 0x40;

const int $A = 0x41;

const int $B = 0x42;

const int $C = 0x43;

const int $D = 0x44;

const int $E = 0x45;

const int $F = 0x46;

const int $G = 0x47;

const int $H = 0x48;

const int $I = 0x49;

const int $J = 0x4A;

const int $K = 0x4B;

const int $L = 0x4C;

const int $M = 0x4D;

const int $N = 0x4E;

const int $O = 0x4F;

const int $P = 0x50;

const int $Q = 0x51;

const int $R = 0x52;

const int $S = 0x53;

const int $T = 0x54;

const int $U = 0x55;

const int $V = 0x56;

const int $W = 0x57;

const int $X = 0x58;

const int $Y = 0x59;

const int $Z = 0x5A;

const int $lbracket = 0x5B;

const int $open_bracket = 0x5B;

const int $backslash = 0x5C;

const int $rbracket = 0x5D;

const int $close_bracket = 0x5D;

const int $circumflex = 0x5E;

const int $caret = 0x5E;

const int $hat = 0x5E;

const int $_ = 0x5F;

const int $underscore = 0x5F;

const int $underline = 0x5F;

const int $backquote = 0x60;

const int $grave = 0x60;

const int $a = 0x61;

const int $b = 0x62;

const int $c = 0x63;

const int $d = 0x64;

const int $e = 0x65;

const int $f = 0x66;

const int $g = 0x67;

const int $h = 0x68;

const int $i = 0x69;

const int $j = 0x6A;

const int $k = 0x6B;

const int $l = 0x6C;

const int $m = 0x6D;

const int $n = 0x6E;

const int $o = 0x6F;

const int $p = 0x70;

const int $q = 0x71;

const int $r = 0x72;

const int $s = 0x73;

const int $t = 0x74;

const int $u = 0x75;

const int $v = 0x76;

const int $w = 0x77;

const int $x = 0x78;

const int $y = 0x79;

const int $z = 0x7A;

const int $lbrace = 0x7B;

const int $open_brace = 0x7B;

const int $pipe = 0x7C;

const int $bar = 0x7C;

const int $rbrace = 0x7D;

const int $close_brace = 0x7D;

const int $tilde = 0x7E;
